import 'dart:convert';

// TODO extends persistable?
class Expense {
  int id;
  int categoryId;
  double amount;
  DateTime date;

  static const PERSIST_NAME = "expenses";

  Expense({required this.id, required this.categoryId, required this.amount, required this.date});

  factory Expense.fromJson(Map<String, dynamic> jsonData) {
    return Expense(
      id: jsonData['id'],
      categoryId: jsonData['categoryId'],
      amount: jsonData['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(jsonData['date']),
    );
  }

  static Map<String, dynamic> toMap(Expense expense) => {
        'id': expense.id,
        'categoryId': expense.categoryId,
        'amount': expense.amount,
        'date': expense.date.millisecondsSinceEpoch
      };

  static String encode(List<Expense> expenses) => json.encode(
        expenses.map<Map<String, dynamic>>((expense) => Expense.toMap(expense)).toList(),
      );

  static List<Expense> decode(String expenses) =>
      (json.decode(expenses) as List<dynamic>).map<Expense>((item) => Expense.fromJson(item)).toList();
}
