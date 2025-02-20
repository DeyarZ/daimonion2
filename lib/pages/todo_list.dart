// lib/pages/todo_list.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../services/db_service.dart';
import '../widgets/ad_wrapper.dart';
import '../main.dart'; // für scheduleDailyTodoReminder()
import '../l10n/generated/l10n.dart';
// Gamification
import '../services/gamification_service.dart';

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

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({Key? key}) : super(key: key);

  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final _uuid = const Uuid();
  final DBService _dbService = DBService();
  bool _hideCompleted = false;
  bool _notificationsOn = false;
  DateTime _newTaskDeadline = DateTime.now();

  // -------------------------------------------------
  // NOTIFICATIONS togglen
  // -------------------------------------------------
  Future<void> _toggleNotifications() async {
    setState(() => _notificationsOn = !_notificationsOn);
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
        // Wir machen KEINE Standard-AppBar => wir bauen uns eine custom top section
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // -----------------------------
                // Obere Custom-Bar (2 Zeilen)
                // -----------------------------
                _buildCustomTopBar(context, loc),

                // -----------------------------
                // Task-Liste
                // -----------------------------
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

                      // Sortierung => neueste Deadline oben
                      filteredTasks.sort((a, b) => b.deadline.compareTo(a.deadline));
                      final grouped = _groupTasksByDate(filteredTasks);
                      final sortedDates = grouped.keys.toList()
                        ..sort((a, b) => b.compareTo(a));

                      return ListView.builder(
                        itemCount: sortedDates.length,
                        padding: const EdgeInsets.only(bottom: 80),
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
                                // Überschrift: Datum
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
                                // Tasks
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
          ),
        ),

        // FAB => Neues To-do
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 223, 27, 27),
          onPressed: _showAddTaskSheet,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 1) Custom TopBar
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildCustomTopBar(BuildContext context, S loc) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.black, Colors.black87],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Z1: Back-Button, Titel, Icons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    loc.todoListTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Notification-Icon
              IconButton(
                icon: Icon(
                  _notificationsOn
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: Colors.white,
                ),
                onPressed: _toggleNotifications,
              ),
              // Calendar-Icon
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
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
          // Z2: "Hide Done" Switch
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  loc.hideDone,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(width: 8),
                Switch(
                  activeColor: const Color.fromARGB(255, 223, 27, 27),
                  value: _hideCompleted,
                  onChanged: (val) => setState(() => _hideCompleted = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 2) Task-Tile
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildTaskTile(Task task) {
    final loc = S.of(context);
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: const Color.fromARGB(255, 223, 27, 27),
        child: const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      onDismissed: (_) => _deleteTask(task),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 48, 48, 48),
              const Color.fromARGB(255, 44, 44, 44),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: ListTile(
          dense: true, // Kompakter
          leading: InkWell(
            onTap: () => _toggleTask(task),
            child: Icon(
              task.completed ? Icons.check_circle : Icons.circle_outlined,
              color: task.completed ? Colors.green : Colors.grey,
              size: 28,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
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

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 3) Add Task Bottom Sheet
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void _showAddTaskSheet() {
    final loc = S.of(context);
    final TextEditingController controller = TextEditingController();
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
                      borderSide: BorderSide(color: Color.fromARGB(255, 223, 27, 27)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${loc.dueOn(_formatDate(_newTaskDeadline))}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month,
                          color: Color.fromARGB(255, 223, 27, 27)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _newTaskDeadline,
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 365)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) {
                          setState(() {
                            _newTaskDeadline = picked;
                          });
                          (ctx as Element).markNeedsBuild();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 223, 27, 27),
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

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 4) Edit Task
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void _editTask(Task task) {
    final loc = S.of(context);
    final editController = TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                      fontWeight: FontWeight.bold,
                    ),
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
                        borderSide: BorderSide(color: Color.fromARGB(255, 223, 27, 27)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 223, 27, 27),
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
                          backgroundColor: const Color.fromARGB(255, 223, 27, 27),
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

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 5) Toggle Task (XP-Feature)
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Future<void> _toggleTask(Task task) async {
    final tasks = await _getAllTasksAsModels();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    final wasCompleted = tasks[index].completed;
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

    // XP vergeben (max 5 am Tag), nur wenn Task jetzt neu auf "completed" springt
    if (!wasCompleted && tasks[index].completed) {
      _awardDailyXP();
    }
  }

  Future<void> _awardDailyXP() async {
    final settingsBox = Hive.box('settings');
    final now = DateTime.now();
    final todayString = '${now.year}-${now.month}-${now.day}';
    final storedDate = settingsBox.get('xpDay', defaultValue: '');
    var dailyCount = settingsBox.get('xpCount', defaultValue: 0) as int;

    if (storedDate != todayString) {
      dailyCount = 0;
      settingsBox.put('xpDay', todayString);
      settingsBox.put('xpCount', dailyCount);
    }

    if (dailyCount < 5) {
      GamificationService().addXPWithStreak(1);
      dailyCount++;
      settingsBox.put('xpCount', dailyCount);

      final left = 5 - dailyCount;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "+1 XP verdient! (Heute: $dailyCount/5, noch $left übrig)",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Tageslimit von 5 XP erreicht! Du willst cheaten? Verarsche dich nicht selbst, Habibi.",
          ),
        ),
      );
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 6) Delete Task
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Future<void> _deleteTask(Task task) async {
    final tasks = await _getAllTasksAsModels();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;
    await _dbService.deleteTask(index);
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // UTILS
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

  Future<List<Task>> _getAllTasksAsModels() async {
    final box = await Hive.openBox<Map>(DBService.tasksBoxName);
    return _boxToTaskList(box);
  }

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

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// CalendarViewPage => wie gehabt
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class CalendarViewPage extends StatefulWidget {
  final List<Task> tasks;

  const CalendarViewPage({Key? key, required this.tasks}) : super(key: key);

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
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 223, 27, 27)),
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
                            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 223, 27, 27)),
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
