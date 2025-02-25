// lib/services/exercise_exporter.dart

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/expense/expense.dart';

class SheetExporter {
  final String? folderPath;

  SheetExporter({this.folderPath});

  Future<String> getFolderPath() async {
    if (folderPath != null) return folderPath!;

    Directory? directory = await getDirectoryToSaveFiles();
    if (directory == null) {
      throw Exception('Could not access external storage directory');
    }
    return directory.path;
  }

  Future<String> exportToExcel(
    List<DomainEntity> domains,
    List<CategoryEntity> categories,
    List<ExpenseEntity> expenses,
  ) async {
    // Create a new Excel document
    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet()!];

    // Add headers
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'Domain';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = 'Category';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = 'Total spent';

    int currentRowIndex = 0;
    // Add data
    for (var i = 0; i < domains.length; i++) {
      currentRowIndex += 1;
      final domain = domains[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRowIndex)).value = domain.name;

      final List<CategoryEntity> domainCats = categories.where((cat) => cat.domainId == domain.id).toList();
      for (var j = 0; j < domainCats.length; j++) {
        currentRowIndex += 1;
        final currentCat = domainCats[j];
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRowIndex)).value = currentCat.name;
        final double catExpensesAmount =
            expenses.where((exp) => exp.categoryId == currentCat.id).fold(0.0, (acc, exp) => acc + exp.amount);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRowIndex)).value = catExpensesAmount;
      }
    }

    // Auto-fit columns
    sheet.setColWidth(0, 20);
    sheet.setColWidth(1, 30);

    // Save file
    final String folderPath = await getFolderPath();
    final String filePath = '$folderPath/expenses_${_formatDate(DateTime.now())}.xlsx';
    await _saveExcelFile(excel, filePath);
    return filePath;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_padNumber(date.month)}-${_padNumber(date.day)}';
  }

  String _padNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  Future<void> _saveExcelFile(Excel excel, String filePath) async {
    final List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
  }

  Future<Directory?> getDirectoryToSaveFiles() async {
    final Directory? directory;
    if (!Platform.isAndroid) {
      directory = await getDownloadsDirectory();
    } else {
      directory = await getExternalStorageDirectory();
    }
    return directory;
  }
}
