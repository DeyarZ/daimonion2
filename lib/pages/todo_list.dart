// lib/pages/todo_list.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../services/db_service.dart';
import '../widgets/ad_wrapper.dart';
import '../main.dart'; // für scheduleDailyTodoReminder()
import '../l10n/generated/l10n.dart';

// ------------------------------
// Model: Task (unverändert)
// ------------------------------
class Task {
  final String id;
  String title;
  bool completed;
  DateTime deadline;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
    required this.deadline,
    required this.createdAt,
  });
}

// ------------------------------
// ToDoListPage
// ------------------------------
class ToDoListPage extends StatefulWidget {
  const ToDoListPage({Key? key}) : super(key: key);

  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final _uuid = const Uuid();
  final DBService _dbService = DBService();
  bool _hideCompleted = false;

  /// NEU: Notification-Toggle-Status
  bool _notificationsOn = false;

  /// NEU: Für Task-Erstellung zwischengespeicherte Deadline
  DateTime _newTaskDeadline = DateTime.now();

  @override
  void dispose() {
    super.dispose();
  }

  // ----------------------------------------------------
  // Notifications togglen
  // ----------------------------------------------------
  Future<void> _toggleNotifications() async {
    setState(() {
      _notificationsOn = !_notificationsOn;
    });
    if (_notificationsOn) {
      await scheduleDailyTodoReminder();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).dailyReminderActivated)),
      );
    } else {
      const notificationId = 5678;
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).dailyReminderDeactivated)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return AdWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.todoListTitle),
          backgroundColor: Colors.black,
          actions: [
            // NEU: Notification Toggle
            IconButton(
              icon: Icon(
                _notificationsOn
                    ? Icons.notifications_active
                    : Icons.notifications_off,
              ),
              onPressed: _toggleNotifications,
            ),
            // Switch zum Ausblenden fertiger Tasks
            Row(
              children: [
                Text(
                  loc.hideDone,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Switch(
                  activeColor: Colors.redAccent,
                  value: _hideCompleted,
                  onChanged: (val) {
                    setState(() {
                      _hideCompleted = val;
                    });
                  },
                ),
              ],
            ),
            // Kalender-Icon (wie gehabt)
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final tasks = await _getAllTasksAsModels();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarViewPage(tasks: tasks),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.black,

        /// NEU: Weg mit dem alten Textfeld in der Kopfzeile.
        /// Wir zeigen direkt die Liste + FAB
        body: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _dbService.listenableTasks(),
                builder: (context, Box box, child) {
                  if (box.isEmpty) {
                    return Center(
                      child: Text(
                        loc.noTasks,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final allTasks = _boxToTaskList(box);
                  final filteredTasks = _hideCompleted
                      ? allTasks.where((t) => !t.completed).toList()
                      : allTasks;

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Text(
                        loc.noMatchingTasks,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  // Sortierung
                  filteredTasks.sort((a, b) => b.deadline.compareTo(a.deadline));
                  final grouped = _groupTasksByDate(filteredTasks);
                  final sortedDates = grouped.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  return ListView.builder(
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final dateKey = sortedDates[index];
                      var tasksForDate = grouped[dateKey]!;
                      tasksForDate.sort(
                          (a, b) => b.createdAt.compareTo(a.createdAt));

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                _formatDate(dateKey),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            ...tasksForDate.map((task) => _buildTaskTile(task))
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),

        /// NEU: Ein FloatingActionButton
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.redAccent,
          onPressed: _showAddTaskSheet,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Neuer Bottom Sheet zum Hinzufügen von Tasks
  // ----------------------------------------------------
  void _showAddTaskSheet() {
    final loc = S.of(context);
    final TextEditingController controller = TextEditingController();
    // Deadline standardmäßig heute
    _newTaskDeadline = DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.newTaskHint,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: loc.taskTitleLabel,
                    hintStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Aktuell gewählte Deadline
                    Text(
                      '${loc.dueOn(_formatDate(_newTaskDeadline))}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month,
                          color: Colors.redAccent),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _newTaskDeadline,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) {
                          setState(() {
                            _newTaskDeadline = picked;
                          });
                          // Modal bleibt offen, also setState() für
                          // den BottomSheet-Context -> use ModalRoute.of(ctx)
                          (ctx as Element).markNeedsBuild();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () async {
                    final title = controller.text.trim();
                    if (title.isNotEmpty) {
                      await _dbService.addTask({
                        'id': _uuid.v4(),
                        'title': title,
                        'completed': false,
                        'deadline': _newTaskDeadline.millisecondsSinceEpoch,
                        'createdAt': DateTime.now().millisecondsSinceEpoch,
                      });
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(loc.addTask),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------
  // Ein Task-Item im UI (unverändert bis auf Kleinigkeiten)
  // ----------------------------------------------------
  Widget _buildTaskTile(Task task) {
    final loc = S.of(context);
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      onDismissed: (_) => _deleteTask(task),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: IconButton(
            icon: Icon(
              task.completed ? Icons.check_circle : Icons.circle_outlined,
              color: task.completed ? Colors.green : Colors.grey,
            ),
            onPressed: () => _toggleTask(task),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              color: Colors.white,
              decoration:
                  task.completed ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
          subtitle: Text(
            loc.dueOn(_formatDate(task.deadline)),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70),
            onPressed: () => _editTask(task),
          ),
          onTap: () => _toggleTask(task),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Edit Task (unverändert)
  // ----------------------------------------------------
  void _editTask(Task task) {
    final loc = S.of(context);
    final editController = TextEditingController(text: task.title);
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loc.editTaskDialogTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: editController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: loc.taskTitleLabel,
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: task.deadline,
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 365)),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365 * 5)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          task.deadline = pickedDate;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(loc.changeDeadline),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          loc.cancel,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          final newTitle = editController.text.trim();
                          if (newTitle.isNotEmpty) {
                            task.title = newTitle;
                          }
                          final tasks = await _getAllTasksAsModels();
                          final index = tasks.indexWhere((t) => t.id == task.id);
                          if (index != -1) {
                            await _dbService.updateTask(
                              index,
                              {
                                'id': task.id,
                                'title': task.title,
                                'completed': task.completed,
                                'deadline':
                                    task.deadline.millisecondsSinceEpoch,
                                'createdAt':
                                    task.createdAt.millisecondsSinceEpoch,
                              },
                            );
                          }
                          Navigator.pop(ctx);
                        },
                        child: Text(loc.save),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------
  // Toggle Task
  // ----------------------------------------------------
  Future<void> _toggleTask(Task task) async {
    final tasks = await _getAllTasksAsModels();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    tasks[index].completed = !tasks[index].completed;

    await _dbService.updateTask(
      index,
      {
        'id': tasks[index].id,
        'title': tasks[index].title,
        'completed': tasks[index].completed,
        'deadline': tasks[index].deadline.millisecondsSinceEpoch,
        'createdAt': tasks[index].createdAt.millisecondsSinceEpoch,
      },
    );
  }

  // ----------------------------------------------------
  // Delete Task
  // ----------------------------------------------------
  Future<void> _deleteTask(Task task) async {
    final tasks = await _getAllTasksAsModels();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    await _dbService.deleteTask(index);
  }

  // ----------------------------------------------------
  // Box -> List<Task> (unverändert)
  // ----------------------------------------------------
  List<Task> _boxToTaskList(Box box) {
    final List<Task> tasks = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data == null) continue;

      final id = data['id'] as String? ?? _uuid.v4();
      final title = data['title'] as String? ?? '';
      final completed = data['completed'] as bool? ?? false;
      final deadlineTimestamp = data['deadline'] as int?;
      final createdAtTimestamp =
          data['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch;

      final deadline = deadlineTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(deadlineTimestamp)
          : DateTime.now();

      final createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtTimestamp);

      tasks.add(Task(
        id: id,
        title: title,
        completed: completed,
        deadline: deadline,
        createdAt: createdAt,
      ));
    }
    return tasks;
  }

  // ----------------------------------------------------
  // Alle Tasks als Models (unverändert)
  // ----------------------------------------------------
  Future<List<Task>> _getAllTasksAsModels() async {
    final box = await Hive.openBox<Map>(DBService.tasksBoxName);
    return _boxToTaskList(box);
  }

  // ----------------------------------------------------
  // Gruppieren nach Datum (unverändert)
  // ----------------------------------------------------
  Map<DateTime, List<Task>> _groupTasksByDate(List<Task> tasks) {
    final Map<DateTime, List<Task>> map = {};
    for (var t in tasks) {
      final dateKey = DateTime(t.deadline.year, t.deadline.month, t.deadline.day);
      map.putIfAbsent(dateKey, () => []);
      map[dateKey]!.add(t);
    }
    return map;
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

// ----------------------------------------------------
// CalendarViewPage (unverändert)
// ----------------------------------------------------
class CalendarViewPage extends StatefulWidget {
  final List<Task> tasks;

  const CalendarViewPage({
    Key? key,
    required this.tasks,
  }) : super(key: key);

  @override
  _CalendarViewPageState createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends State<CalendarViewPage> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final filtered = widget.tasks
        .where((t) => _isSameDay(t.deadline, _selectedDay))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.calendarViewTitle),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Datum wählen
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: _pickDate,
              child: Text(loc.chooseDay(_formattedDate(_selectedDay))),
            ),
          ),
          // Liste der gefilterten Tasks
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      loc.noTasksForDay(_formattedDate(_selectedDay)),
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final task = filtered[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: IconButton(
                            icon: Icon(
                              task.completed
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: task.completed ? Colors.green : Colors.grey,
                            ),
                            onPressed: () => _toggleTask(task),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              color: Colors.white,
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(task),
                          ),
                          onTap: () => _toggleTask(task),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDay = picked);
    }
  }

  void _toggleTask(Task task) {
    setState(() {
      task.completed = !task.completed;
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      widget.tasks.removeWhere((t) => t.id == task.id);
    });
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _formattedDate(DateTime d) => '${d.day}.${d.month}.${d.year}';
}
