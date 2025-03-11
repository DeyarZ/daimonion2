// lib/pages/tasks_section.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../l10n/generated/l10n.dart';
import '../services/db_service.dart';
import '../models/data_models.dart' as models;
import 'todo_list.dart';
import '../utils/dashboard_utils.dart';
import 'task_details_page.dart';

class TasksSection extends StatelessWidget {
  final DBService dbService;
  final void Function(models.Task task) toggleTask;

  const TasksSection({
    Key? key,
    required this.dbService,
    required this.toggleTask,
  }) : super(key: key);

  List<models.Task> _boxToTaskList(Box box) {
    final List<models.Task> tasks = [];
    final uuid = const Uuid();
    final DateTime today = DateTime.now();
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data == null) continue;
      final id = data['id'] as String? ?? uuid.v4();
      final title = data['title'] as String? ?? '';
      final completed = data['completed'] as bool? ?? false;
      final deadlineTs = data['deadline'] as int?;
      final deadline = deadlineTs != null
          ? DateTime.fromMillisecondsSinceEpoch(deadlineTs)
          : DateTime.now();
      
      // Filter: Nur Tasks, deren Deadline heute ist
      if (deadline.year == today.year &&
          deadline.month == today.month &&
          deadline.day == today.day) {
        tasks.add(models.Task(
          id: id,
          title: title,
          completed: completed,
          deadline: deadline,
          description: data['description'],
          priority: data['priority'],
        ));
      }
    }
    return tasks;
  }

  Widget _buildTaskList(BuildContext context, List<models.Task> tasks) {
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.grey.shade600, size: 44),
            const SizedBox(height: 16),
            Text(
              S.of(context).noTasksToday,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ToDoListPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(S.of(context).addNewTask),
            ),
          ],
        ),
      );
    }

    final visibleTasks = tasks.length > 3 ? tasks.sublist(0, 3) : tasks;
    final remainingCount = tasks.length - visibleTasks.length;

    return Column(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleTasks.length,
          itemBuilder: (context, index) {
            final task = visibleTasks[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: GestureDetector(
                  onTap: () => toggleTask(task),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.completed ? Colors.green : Colors.grey.shade700,
                      boxShadow: [
                        if (task.completed)
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                      ],
                    ),
                    child: Center(
                      child: task.completed ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                    ),
                  ),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    color: Colors.white,
                    decoration: task.completed ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  task.description ?? '',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: task.priority != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: getPriorityColor(task.priority!).withOpacity(0.2),
                        ),
                        child: Text(
                          getPriorityText(task.priority!),
                          style: TextStyle(color: getPriorityColor(task.priority!), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TaskDetailsPage(task: task)),
                  );
                },
              ),
            );
          },
        ),
        if (remainingCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ToDoListPage()),
                );
              },
              child: Text(
                '+ $remainingCount ${S.of(context).moreTasks}',
                style: const TextStyle(color: Color.fromARGB(255, 223, 27, 27), fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: dbService.listenableTasks(),
      builder: (context, taskBox, _) {
        final tasks = _boxToTaskList(taskBox as Box);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF2A2A2A), Color(0xFF212121)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.4), offset: const Offset(0, 4), blurRadius: 12),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      S.of(context).todaysTasks,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ToDoListPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromARGB(255, 223, 27, 27).withOpacity(0.2),
                        ),
                        child: Row(
                          children: [
                            Text(
                              S.of(context).viewAll,
                              style: const TextStyle(color: Color.fromARGB(255, 223, 27, 27), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios, color: Color.fromARGB(255, 223, 27, 27), size: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, height: 1, indent: 16, endIndent: 16),
              _buildTaskList(context, tasks),
            ],
          ),
        );
      },
    );
  }
}
