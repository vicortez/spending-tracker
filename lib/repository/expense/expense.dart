import 'package:spending_tracker/repository/interfaces/mappable.dart';
import 'package:spending_tracker/repository/interfaces/persistable.dart';

class ExpenseEntity implements Mappable, Persistable {
  int id;
  int categoryId;
  double amount;
  DateTime date;

  static const PERSIST_NAME = 'expenses';

  ExpenseEntity({required this.id, required this.categoryId, required this.amount, required this.date});

  factory ExpenseEntity.fromMap(Map<String, dynamic> jsonData) {
    return ExpenseEntity(
      id: jsonData['id'],
      categoryId: jsonData['categoryId'],
      amount: jsonData['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(jsonData['date']),
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'categoryId': categoryId,
        'amount': amount,
        'date': date.millisecondsSinceEpoch,
      };

  @override
  String getPersistenceKey() => PERSIST_NAME;
}
