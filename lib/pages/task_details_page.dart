// lib/pages/task_details_page.dart
import 'package:flutter/material.dart';
import '../models/data_models.dart' as models;

class TaskDetailsPage extends StatelessWidget {
  final models.Task task;
  const TaskDetailsPage({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
      ),
      body: Center(
        child: Text('Details for task: ${task.title}'),
      ),
    );
  }
}
