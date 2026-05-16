import 'package:spending_tracker/repository/interfaces/mappable.dart';
import 'package:spending_tracker/repository/interfaces/persistable.dart';

class ExpenseEntity implements Mappable, Persistable {
  int id;
  int categoryId;
  double amount;
  DateTime date;
  DateTime createdAt;

  static const PERSIST_NAME = 'expenses';

  ExpenseEntity({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? date;

  factory ExpenseEntity.fromMap(Map<String, dynamic> jsonData) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(jsonData['date']);
    return ExpenseEntity(
      id: jsonData['id'],
      categoryId: jsonData['categoryId'],
      amount: jsonData['amount'],
      date: date,
      createdAt: jsonData['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(jsonData['createdAt'])
          : date,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'categoryId': categoryId,
    'amount': amount,
    'date': date.millisecondsSinceEpoch,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  @override
  String getPersistenceKey() => PERSIST_NAME;
}
