import 'dart:convert';

class FocusedMonth {
  DateTime month;

  static const PERSIST_NAME = "focused_month";

  FocusedMonth({required this.month});

  factory FocusedMonth.fromJson(Map<String, dynamic> jsonData) {
    return FocusedMonth(
      month: DateTime.fromMillisecondsSinceEpoch(jsonData['month']),
    );
  }

  static String encode(FocusedMonth focusedMonth) => json.encode(
        json.encode(focusedMonth.month.millisecondsSinceEpoch),
      );

  static FocusedMonth decode(String focusedMonth) => FocusedMonth.fromJson(json.decode(focusedMonth));
}
