import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/generated/l10n.dart';
import '../models/data_models.dart' as models;

class TaskDetailsPage extends StatelessWidget {
  final models.Task task;

  const TaskDetailsPage({Key? key, required this.task}) : super(key: key);

  String _formatDate(DateTime date) {
    // Formatierung der Deadline
    final formatter = DateFormat.yMMMMd();
    return formatter.format(date);
  }

  Color _getPriorityColor(int priorityValue) {
    // 0: Low, 1: Medium, 2: High
    switch (priorityValue) {
      case 2:
        return const Color(0xFFDF1B1B);
      case 0:
        return Colors.green;
      case 1:
      default:
        return Colors.orange;
    }
  }

  String _getPriorityText(int priorityValue) {
    switch (priorityValue) {
      case 2:
        return "High";
      case 0:
        return "Low";
      case 1:
      default:
        return "Medium";
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final priorityColor = _getPriorityColor(task.priority ?? 1);
    final priorityText = _getPriorityText(task.priority ?? 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.taskDetails ?? "Task Details"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Titel
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Beschreibung (Notizen)
            if (task.description != null && task.description!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.description ?? "Description",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.description!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            // Deadline
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  "${loc.deadline ?? "Deadline"}: ${_formatDate(task.deadline)}",
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Priorität
            Row(
              children: [
                const Icon(Icons.priority_high, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  "${loc.priority ?? "Priority"}: $priorityText",
                  style: TextStyle(fontSize: 16, color: priorityColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tags
            if (task.tags != null && task.tags!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.tags ?? "Tags",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: task.tags!.map((tag) {
                      return Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.grey.shade800,
                      );
                    }).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            // Completion Status
            Row(
              children: [
                Icon(
                  task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: task.completed ? Colors.green : Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  task.completed ? (loc.completed ?? "Completed") : (loc.notCompleted ?? "Not Completed"),
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
