// lib/utils/dashboard_utils.dart
import 'package:flutter/material.dart';

String formatWeeklyFlowTime(int? seconds) {
  final value = seconds ?? 0;
  final hours = value ~/ 3600;
  final minutes = (value % 3600) ~/ 60;
  return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
}

Color getPriorityColor(int priority) {
  switch (priority) {
    case 3:
      return Colors.red;
    case 2:
      return Colors.orange;
    case 1:
      return Colors.green;
    default:
      return Colors.grey;
  }
}

String getPriorityText(int priority) {
  switch (priority) {
    case 3:
      return "High";
    case 2:
      return "Medium";
    case 1:
      return "Low";
    default:
      return "None";
  }
}
