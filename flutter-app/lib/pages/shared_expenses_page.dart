import 'package:flutter/material.dart';
import 'package:spending_tracker/repository/services/api_service.dart';

class SharedExpensesPage extends StatefulWidget {
  const SharedExpensesPage({super.key});

  @override
  State<SharedExpensesPage> createState() => _SharedExpensesPageState();
}

class _SharedExpensesPageState extends State<SharedExpensesPage> {
  final ApiService _apiService = ApiService();
  String _content = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await _apiService.get('/test');
      if (mounted) {
        setState(() {
          _content = response.data.toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _content = 'Error fetching data: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shared Expenses')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(child: Text(_content)),
      ),
    );
  }
}
