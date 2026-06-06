import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';

class PersistenceViewerPage extends StatefulWidget {
  const PersistenceViewerPage({super.key});

  @override
  State<PersistenceViewerPage> createState() => _PersistenceViewerPageState();
}

class _PersistenceViewerPageState extends State<PersistenceViewerPage> {
  Map<String, dynamic> _storageData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, dynamic> data = {};
    for (String key in keys) {
      final value = prefs.get(key);
      if (value is String) {
        try {
          data[key] = json.decode(value);
        } catch (_) {
          data[key] = value;
        }
      } else {
        data[key] = value;
      }
    }
    setState(() {
      _storageData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final domainProvider = context.watch<DomainProvider>();

    final memoryData = {
      'expenses': expenseProvider.expenses.map((e) => e.toMap()).toList(),
      'categories': categoryProvider.categories.map((c) => c.toMap()).toList(),
      'domains': domainProvider.domains.map((d) => d.toMap()).toList(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Persistence Viewer'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStorage)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('In-Memory Provider State'),
                  _buildJsonViewer(memoryData),
                  const SizedBox(height: 32),
                  _buildSectionTitle('SharedPreferences Storage'),
                  _buildJsonViewer(_storageData),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildJsonViewer(Map<String, dynamic> data) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String prettyJson = encoder.convert(data);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          prettyJson,
          softWrap: false,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.black87),
        ),
      ),
    );
  }
}
