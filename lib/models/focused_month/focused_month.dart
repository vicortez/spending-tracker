import 'dart:convert';

class FocusedMonth {
  DateTime month;

  static const PERSIST_NAME = "focused_month";

  FocusedMonth({required this.month});

  factory FocusedMonth.fromDate(int date) {
    return FocusedMonth(
      month: DateTime.fromMillisecondsSinceEpoch(date),
    );
  }

  static String encode(FocusedMonth focusedMonth) => json.encode(focusedMonth.month.millisecondsSinceEpoch);

  static FocusedMonth decode(String focusedMonth) {
    return FocusedMonth.fromDate(json.decode(focusedMonth));
  }
}
