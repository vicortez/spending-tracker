import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/config/config_name.dart';
import 'package:spending_tracker/repository/interfaces/persistable_store.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/services/backup_service.dart';

class ConfigProvider with ChangeNotifier implements PersistableStore<Map<ConfigName, dynamic>> {
  Map<ConfigName, dynamic> config = {ConfigName.theme: 'dark', ConfigName.developerMode: false};
  String PERSIST_NAME = 'config';

  SharedPreferences? prefs;

  @override
  void set(Map<ConfigName, dynamic> data, {bool syncStorage = true}) {
    config = data;
    notifyListeners();
    if (syncStorage) {
      persistChanges();
    }
  }

  @override
  Future<void> loadFromLocalStorage(SharedPreferences prefs) async {
    this.prefs = prefs;
    final String? configStr = prefs.getString(PERSIST_NAME);
    if (configStr != null) {
      config = decode(configStr);
      notifyListeners();
    }
  }

  dynamic getConfig(ConfigName configName) {
    return config[configName];
  }

  void updateConfig(ConfigName configName, dynamic value) {
    config[configName] = value;

    if (prefs != null) {
      persistChanges();
    }
    notifyListeners();
  }

  @override
  Future<void> persistChanges() async {
    Map<String, dynamic> encodableMap = Map.fromEntries(
      config.entries.map((entry) => MapEntry(entry.key.name, entry.value)),
    );
    prefs?.setString(PERSIST_NAME, json.encode(encodableMap));
  }

  Map<ConfigName, dynamic> decode(String configStr) {
    var decodedMap = json.decode(configStr) as Map<String, dynamic>;
    Map<ConfigName, dynamic> map = {};

    for (var entry in decodedMap.entries) {
      for (var configName in ConfigName.values) {
        if (configName.name == entry.key) {
          map[configName] = entry.value;
          break;
        }
      }
    }
    return map;
  }

  Map<String, dynamic> getAllAppPersistedData() {
    Map<String, dynamic> jsonData = {};
    final String? categoriesStr = prefs?.getString(CategoryEntity.PERSIST_NAME);
    final String? expensesStr = prefs?.getString(ExpenseEntity.PERSIST_NAME);
    final String? domainsStr = prefs?.getString(DomainEntity.PERSIST_NAME);
    jsonData[CategoryEntity.PERSIST_NAME] = categoriesStr;
    jsonData[ExpenseEntity.PERSIST_NAME] = expensesStr;
    jsonData[DomainEntity.PERSIST_NAME] = domainsStr;

    return jsonData;
  }

  Future<bool> saveJsonToLocalFile(Map<String, dynamic> jsonMap, String fileName) async {
    try {
      Directory? directory = await getDirectoryToSaveFiles();
      if (directory == null) {
        return false;
      }
      String filePath = '${directory.path}/$fileName.json';
      Uri uri = Uri.parse(filePath);
      filePath = uri.toFilePath(windows: Platform.isWindows);

      File file = File(filePath);
      String jsonString = json.encode(jsonMap);
      await file.writeAsString(jsonString);
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> exportJSONFile(Map<String, dynamic> jsonMap, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/$fileName.json';
      // Save to temporary file
      String jsonString = json.encode(jsonMap);
      File tempFile = File(tempFilePath);
      await tempFile.writeAsString(jsonString);
      // Share the file
      ShareResult res = await Share.shareXFiles(
        [XFile(tempFilePath)],
        subject: fileName,
        text: 'Sharing JSON file: $fileName',
      );
      return res.status == ShareResultStatus.success;
    } catch (e) {
      return false;
    }
  }

  String getExportDataFilename() =>
      'spending-tracker-export-${DateTime.now().toString().substring(0, 10)}';

  Future<Directory?> getDirectoryToSaveFiles() async {
    final Directory? directory;
    if (!Platform.isAndroid) {
      directory = await getDownloadsDirectory();
    } else {
      directory = await getExternalStorageDirectory();
    }
    return directory;
  }

  Future<Map<String, dynamic>?> importJsonDataFile() async {
    try {
      if (kIsWeb) {
        return null;
      }
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null) {
        return null;
      }

      PlatformFile file = result.files.first;

      // Read the file contents as a string
      String jsonString = await File(file.path!).readAsString();

      // Decode the JSON string to a Map
      Map<String, dynamic> jsonData = json.decode(jsonString);

      return jsonData;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> pickMultipleJsonFiles() async {
    try {
      if (kIsWeb) return null;
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: true,
      );
      if (result == null || result.files.length < 2) return null;

      List<Map<String, dynamic>> filesData = [];
      for (var file in result.files) {
        String jsonString = await File(file.path!).readAsString();
        filesData.add(json.decode(jsonString));
      }
      return filesData;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? mergeJsonFiles(List<Map<String, dynamic>> filesData) {
    try {
      Map<int, String> domainIdToName = {};
      Map<String, int> domainNameToId = {};
      Map<int, String> categoryIdToName = {};
      Map<String, int> categoryNameToId = {};

      List<dynamic> allDomains = [];
      List<dynamic> allCategories = [];
      List<dynamic> allExpenses = [];

      int maxExpenseId = 0;

      for (int i = 0; i < filesData.length; i++) {
        var fileData = filesData[i];

        // Process Domains
        var domainsStr = fileData[DomainEntity.PERSIST_NAME] as String?;
        if (domainsStr != null) {
          var domains = json.decode(domainsStr) as List<dynamic>;
          for (var dom in domains) {
            int id = dom['id'];
            String name = dom['name'];
            if (domainNameToId.containsKey(name) && domainNameToId[name] != id) {
              return null; // Inconsistency
            }
            if (domainIdToName.containsKey(id) && domainIdToName[id] != name) {
              return null; // Inconsistency
            }
            if (!domainNameToId.containsKey(name)) {
              domainNameToId[name] = id;
              domainIdToName[id] = name;
              allDomains.add(dom);
            }
          }
        }

        // Process Categories
        var categoriesStr = fileData[CategoryEntity.PERSIST_NAME] as String?;
        if (categoriesStr != null) {
          var categories = json.decode(categoriesStr) as List<dynamic>;
          for (var cat in categories) {
            int id = cat['id'];
            String name = cat['name'];
            if (categoryNameToId.containsKey(name) && categoryNameToId[name] != id) {
              return null; // Inconsistency
            }
            if (categoryIdToName.containsKey(id) && categoryIdToName[id] != name) {
              return null; // Inconsistency
            }
            if (!categoryNameToId.containsKey(name)) {
              categoryNameToId[name] = id;
              categoryIdToName[id] = name;
              allCategories.add(cat);
            }
          }
        }

        // Process Expenses and find initial maxExpenseId
        var expensesStr = fileData[ExpenseEntity.PERSIST_NAME] as String?;
        if (expensesStr != null) {
          var expenses = json.decode(expensesStr) as List<dynamic>;
          for (var exp in expenses) {
            if (i == 0) {
              allExpenses.add(exp);
              if (exp['id'] > maxExpenseId) maxExpenseId = exp['id'];
            } else {
              maxExpenseId++;
              var newExp = Map<String, dynamic>.from(exp);
              newExp['id'] = maxExpenseId;
              allExpenses.add(newExp);
            }
          }
        }
      }

      return {
        DomainEntity.PERSIST_NAME: json.encode(allDomains),
        CategoryEntity.PERSIST_NAME: json.encode(allCategories),
        ExpenseEntity.PERSIST_NAME: json.encode(allExpenses),
      };
    } catch (e) {
      return null;
    }
  }

  void setAllDataFromJson(Map<String, dynamic> jsonData) {
    prefs?.setString(CategoryEntity.PERSIST_NAME, jsonData[CategoryEntity.PERSIST_NAME]!);
    prefs?.setString(ExpenseEntity.PERSIST_NAME, jsonData[ExpenseEntity.PERSIST_NAME]!);
    notifyListeners();
  }

  @override
  Future<void> setDataFromImport(dynamic data) async {
    if (data is Map<String, dynamic>) {
      setAllDataFromJson(data);
    }
  }

  Map<String, dynamic>? getBackupsData() {
    final String? backupsStr = prefs?.getString(BackupService.BACKUP_KEY);
    if (backupsStr == null) return null;

    try {
      final Map<String, dynamic> backups = json.decode(backupsStr) as Map<String, dynamic>;
      if (backups.isEmpty) return null;

      // Ensure we only have the latest 5
      final sortedDates = backups.keys.toList()..sort((a, b) => b.compareTo(a));
      final Map<String, dynamic> latestBackups = {};
      final int count = sortedDates.length > 5 ? 5 : sortedDates.length;
      for (int i = 0; i < count; i++) {
        latestBackups[sortedDates[i]] = backups[sortedDates[i]];
      }
      return latestBackups;
    } catch (e) {
      return null;
    }
  }

  // void toggleTheme() {
  //   if (config['theme'] == "dark") {
  //     config['theme'] = "light";
  //   } else {
  //     config['theme'] = "dark";
  //   }
  //   notifyListeners();
  // }
}
