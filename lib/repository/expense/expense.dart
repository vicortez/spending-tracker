import 'dart:convert';

// TODO extends persistable?
class ExpenseEntity {
  int id;
  int categoryId;
  double amount;
  DateTime date;

  static const PERSIST_NAME = "expenses";

  ExpenseEntity({required this.id, required this.categoryId, required this.amount, required this.date});

  factory ExpenseEntity.fromJson(Map<String, dynamic> jsonData) {
    return ExpenseEntity(
      id: jsonData['id'],
      categoryId: jsonData['categoryId'],
      amount: jsonData['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(jsonData['date']),
    );
  }

  static Map<String, dynamic> toMap(ExpenseEntity expense) => {
        'id': expense.id,
        'categoryId': expense.categoryId,
        'amount': expense.amount,
        'date': expense.date.millisecondsSinceEpoch
      };

  static String encode(List<ExpenseEntity> expenses) => json.encode(
        expenses.map<Map<String, dynamic>>((expense) => ExpenseEntity.toMap(expense)).toList(),
      );

  static List<ExpenseEntity> decode(String expenses) =>
      (json.decode(expenses) as List<dynamic>).map<ExpenseEntity>((item) => ExpenseEntity.fromJson(item)).toList();
}
