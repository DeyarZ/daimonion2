import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';
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

  // Helper zum Parsen von Datum: Akzeptiert int und String
  DateTime _parseDate(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      return DateTime.parse(value);
    } else {
      return DateTime.now();
    }
  }

  // Helper zum Parsen der Priorität: Akzeptiert int oder String und gibt int zurück (0: low, 1: medium, 2: high)
  int _parsePriority(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'low':
          return 0;
        case 'high':
          return 2;
        case 'medium':
        default:
          return 1;
      }
    }
    return 1;
  }

  // Konvertiert die Tasks-Box in eine Liste von Tasks
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
      final deadline = _parseDate(data['deadline']);
      
      // Filter: Nur Tasks, deren Deadline heute ist
      if (deadline.year == today.year &&
          deadline.month == today.month &&
          deadline.day == today.day) {
        tasks.add(models.Task(
          id: id,
          title: title,
          completed: completed,
          deadline: deadline,
          description: data['description'], // Hier wird die Beschreibung übergeben
          priority: _parsePriority(data['priority']),
          tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
        ));
      }
    }
    // Sort tasks by priority (high to low) and completion status
    tasks.sort((a, b) {
      // Completed tasks go to the bottom
      if (a.completed && !b.completed) return 1;
      if (!a.completed && b.completed) return -1;
      // Sort by priority for tasks with the same completion status
      return (b.priority ?? 1) - (a.priority ?? 1);
    });
    return tasks;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Platzhalter für Lottie-Animation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt,
              size: 60,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            S.of(context).noTasksToday,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Enjoy your free time or create a new task",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ToDoListPage()),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
            label: Text(S.of(context).addNewTask),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 223, 27, 27),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, models.Task task) {
    final priorityValue = task.priority ?? 1;
    final Color priorityColor = getPriorityColor(priorityValue);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.completed ? Colors.grey.shade800 : priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Beim Tap auf den Task wird die TaskDetailsPage aufgerufen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TaskDetailsPage(task: task)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Checkbox mit Animation
                GestureDetector(
                  onTap: () => toggleTask(task),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.completed ? Colors.green : priorityColor.withOpacity(0.1),
                      border: Border.all(
                        color: task.completed ? Colors.green : priorityColor,
                        width: 2,
                      ),
                      boxShadow: task.completed
                          ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: task.completed ? 1.0 : 0.0,
                        child: const Icon(Icons.check, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Task Details (kurze Vorschau)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: task.completed ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.grey,
                          decorationThickness: 2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.description != null && task.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            task.description!,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                              decoration: task.completed ? TextDecoration.lineThrough : null,
                              decorationColor: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Priority Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: task.completed
                        ? Colors.grey.shade800
                        : priorityColor.withOpacity(0.2),
                  ),
                  child: Text(
                    getPriorityText(priorityValue),
                    style: TextStyle(
                      color: task.completed ? Colors.grey : priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<models.Task> tasks) {
    if (tasks.isEmpty) {
      return _buildEmptyState(context);
    }

    final visibleTasks = tasks.length > 3 ? tasks.sublist(0, 3) : tasks;
    final remainingCount = tasks.length - visibleTasks.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.checklist_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${tasks.length} ${tasks.length == 1 ? 'task' : 'tasks'} today',
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                '${tasks.where((task) => task.completed).length}/${tasks.length} completed',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleTasks.length,
          itemBuilder: (context, index) {
            return _buildTaskItem(context, visibleTasks[index]);
          },
        ),
        if (remainingCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 8),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ToDoListPage()),
                );
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: Text(
                '$remainingCount ${remainingCount == 1 ? 'more task' : S.of(context).moreTasks}',
                style: const TextStyle(
                  color: Color.fromARGB(255, 223, 27, 27),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 223, 27, 27).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(0, 4),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Text(
                      S.of(context).todaysTasks,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ToDoListPage()),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromARGB(255, 223, 27, 27).withOpacity(0.2),
                        ),
                        child: Row(
                          children: [
                            Text(
                              S.of(context).viewAll,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 223, 27, 27),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Color.fromARGB(255, 223, 27, 27),
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, height: 1, indent: 20, endIndent: 20),
              _buildTaskList(context, tasks),
            ],
          ),
        );
      },
    );
  }
}
