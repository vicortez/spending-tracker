import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/config/config_name.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/expense/expense.dart';

class ConfigState extends ChangeNotifier {
  Map<ConfigName, dynamic> config = {ConfigName.theme: "dark", ConfigName.seeAllMonths: true};
  String PERSIST_NAME = 'config';

  SharedPreferences? prefs;

  void loadFromLocalStorage(SharedPreferences prefs) {
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
      updateLocalStorage();
    }
    notifyListeners();
  }

  void updateLocalStorage() {
    Map<String, dynamic> encodableMap = Map.fromEntries(
      config.entries.map((entry) => MapEntry(entry.key.name, entry.value)),
    );
    prefs?.setString(PERSIST_NAME, json.encode(encodableMap));
  }

  Map<ConfigName, dynamic> decode(String configStr) {
    var decodedMap = json.decode(configStr) as Map<String, dynamic>;
    Map<ConfigName, dynamic> map = Map.fromEntries(
      decodedMap.entries.map((entry) {
        ConfigName configName = ConfigName.values.firstWhere((e) => e.name == entry.key);
        return MapEntry(configName, entry.value);
      }),
    );
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

  String getExportDataFilename() => "spending-tracker-export-${DateTime.now().toString().substring(0, 10)}";

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

  void setAllDataFromJson(Map<String, dynamic> jsonData) {
    prefs?.setString(CategoryEntity.PERSIST_NAME, jsonData[CategoryEntity.PERSIST_NAME]!);
    prefs?.setString(ExpenseEntity.PERSIST_NAME, jsonData[ExpenseEntity.PERSIST_NAME]!);
    notifyListeners();
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
