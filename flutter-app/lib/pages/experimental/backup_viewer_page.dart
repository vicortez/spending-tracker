import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/services/backup_service.dart';
import 'package:spending_tracker/utils/toast_utils.dart';

class BackupViewerPage extends StatefulWidget {
  const BackupViewerPage({super.key});

  @override
  State<BackupViewerPage> createState() => _BackupViewerPageState();
}

class _BackupViewerPageState extends State<BackupViewerPage> {
  Map<String, dynamic> _backups = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    final prefs = await SharedPreferences.getInstance();
    final String? backupsStr = prefs.getString(BackupService.BACKUP_KEY);
    if (backupsStr != null) {
      try {
        setState(() {
          _backups = json.decode(backupsStr) as Map<String, dynamic>;
        });
      } catch (e) {
        debugPrint('Error decoding backups: $e');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  int _getCount(dynamic data) {
    if (data == null) return 0;
    if (data is String) {
      try {
        final decoded = json.decode(data);
        if (decoded is List) return decoded.length;
      } catch (_) {
        return 0;
      }
    }
    if (data is List) return data.length;
    return 0;
  }

  Future<void> _importBackup(String date, Map<String, dynamic> backupData) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Import'),
        content: Text(
          'Are you sure you want to import the backup from $date? This will overwrite your current data.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;

      final categoryProvider = context.read<CategoryProvider>();
      final expenseProvider = context.read<ExpenseProvider>();
      final domainProvider = context.read<DomainProvider>();

      try {
        // Backup data values are typically JSON strings as per BackupService.runDailyBackup
        await categoryProvider.setDataFromImport(backupData[CategoryEntity.PERSIST_NAME]);
        await expenseProvider.setDataFromImport(backupData[ExpenseEntity.PERSIST_NAME]);
        await domainProvider.setDataFromImport(backupData[DomainEntity.PERSIST_NAME]);

        if (mounted) {
          showToast(context, 'Backup from $date imported successfully');
          Navigator.pop(context); // Go back to experimental page
        }
      } catch (e) {
        if (mounted) {
          showToast(context, 'Import failed: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = _backups.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('Backups Viewer')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _backups.isEmpty
          ? const Center(child: Text('No backups found'))
          : ListView.builder(
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final data = _backups[date] as Map<String, dynamic>;

                final categoryCount = _getCount(data[CategoryEntity.PERSIST_NAME]);
                final expenseCount = _getCount(data[ExpenseEntity.PERSIST_NAME]);
                final domainCount = _getCount(data[DomainEntity.PERSIST_NAME]);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Backup: $date',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCountInfo('Domains', domainCount),
                            _buildCountInfo('Categories', categoryCount),
                            _buildCountInfo('Expenses', expenseCount),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: CoolButton(
                            text: 'Import this backup',
                            type: ButtonType.normal,
                            onPressed: () => _importBackup(date, data),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCountInfo(String label, int count) {
    return Column(
      children: [
        Text(count.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
