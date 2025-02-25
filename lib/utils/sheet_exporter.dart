// lib/services/exercise_exporter.dart

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
    Excel excel = createSheet(domains, categories, expenses);

    // Share file
    final String fileName = 'expenses_${_formatDate(DateTime.now())}.xlsx';
    await exportExcelFile(excel, fileName);
    return fileName;
  }

  Excel createSheet(List<DomainEntity> domains, List<CategoryEntity> categories, List<ExpenseEntity> expenses) {
    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet()!];

    // Add headers
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Domain');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('Category');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue('Total spent');

    int currentRowIndex = 0;
    // Add data
    for (var i = 0; i < domains.length; i++) {
      currentRowIndex += 1;
      final domain = domains[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRowIndex)).value =
          TextCellValue(domain.name);

      final List<CategoryEntity> domainCats = categories.where((cat) => cat.domainId == domain.id).toList();
      for (var j = 0; j < domainCats.length; j++) {
        currentRowIndex += 1;
        final currentCat = domainCats[j];
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRowIndex)).value =
            TextCellValue(currentCat.name);
        final double catExpensesAmount =
            expenses.where((exp) => exp.categoryId == currentCat.id).fold(0.0, (acc, exp) => acc + exp.amount);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRowIndex)).value =
            DoubleCellValue(catExpensesAmount);
      }
    }

    // Auto-fit columns
    sheet.setColumnAutoFit(0);
    sheet.setColumnAutoFit(1);
    return excel;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_padNumber(date.month)}-${_padNumber(date.day)}';
  }

  String _padNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  Future<bool> exportExcelFile(Excel excel, String fileName) async {
    List<int> excelBytes = excel.encode()!;

    if (excelBytes == null) {
      return false;
    }

    try {
      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/$fileName';
      File tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(excelBytes);
      // Share the file
      ShareResult res = await Share.shareXFiles(
        [XFile(tempFilePath)],
        subject: fileName,
        text: 'Sharing Sheet file: $fileName',
      );
      return res.status == ShareResultStatus.success;
    } catch (e) {
      return false;
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
