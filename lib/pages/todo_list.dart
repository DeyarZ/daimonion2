import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;

import '../services/db_service.dart';
import '../widgets/ad_wrapper.dart';
import '../main.dart'; // für scheduleDailyTodoReminder() und flutterLocalNotificationsPlugin
import '../l10n/generated/l10n.dart';
import '../services/gamification_service.dart';

// Enum für Task-Prioritäten
enum TaskPriority { low, medium, high }

// Task-Klasse mit Tags
class Task {
  final String id;
  String title;
  bool completed;
  DateTime deadline;
  DateTime createdAt;
  TaskPriority priority;
  List<String> tags;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
    required this.deadline,
    required this.createdAt,
    this.priority = TaskPriority.medium,
    this.tags = const ['General'],
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
  TaskPriority? _filterPriority;
  String? _filterTag;
  bool _notificationsOn = false;
  DateTime _newTaskDeadline = DateTime.now();
  TaskPriority _newTaskPriority = TaskPriority.medium;
  List<String> _newTaskTags = ['General']; // Fix: Vorher war hier ['Allgemein']
  final List<String> _defaultTags = ['General', 'Work', 'Private', 'Sport'];

  // Toggle für Benachrichtigungen
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
                _buildCustomTopBar(context, loc),
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
                      final filteredTasks = allTasks.where((t) {
                        if (_hideCompleted && t.completed) return false;
                        if (_filterPriority != null && t.priority != _filterPriority) return false;
                        if (_filterTag != null && !t.tags.contains(_filterTag)) return false;
                        return true;
                      }).toList();

                      if (filteredTasks.isEmpty) {
                        return Center(
                          child: Text(
                            loc.noMatchingTasks,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      filteredTasks.sort((a, b) => b.deadline.compareTo(a.deadline));
                      final grouped = _groupTasksByDate(filteredTasks);
                      final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

                      return ListView.builder(
                        itemCount: sortedDates.length,
                        padding: const EdgeInsets.only(bottom: 80),
                        itemBuilder: (context, index) {
                          final dateKey = sortedDates[index];
                          var tasksForDate = grouped[dateKey]!
                            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
                                ...tasksForDate.map((task) => _buildTaskCard(task)),
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 223, 27, 27),
          onPressed: _showAddTaskSheet,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // Custom TopBar mit Filter-Menü
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
              IconButton(
                icon: Icon(
                  _notificationsOn ? Icons.notifications_active : Icons.notifications_off,
                  color: Colors.white,
                ),
                onPressed: _toggleNotifications,
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: _showCalendarPicker,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onSelected: (value) {
                  if (value == 'hideDone') {
                    setState(() => _hideCompleted = !_hideCompleted);
                  } else if (value.startsWith('priority_')) {
                    final prio = value.split('_')[1];
                    setState(() => _filterPriority = _stringToPriority(prio));
                  } else if (value.startsWith('tag_')) {
                    final tag = value.split('_')[1];
                    setState(() => _filterTag = tag);
                  }
                },
                itemBuilder: (context) {
                  final tasks = _boxToTaskList(_dbService.listenableTasks().value);
                  final uniqueTags = tasks.expand((t) => t.tags).toSet().toList();

                  return [
                    PopupMenuItem(
                      value: 'hideDone',
                      child: Text(_hideCompleted ? 'Show Done' : 'Hide Done'),
                    ),
                    const PopupMenuDivider(),
                    ...TaskPriority.values.map((p) => PopupMenuItem(
                          value: 'priority_${_priorityToString(p)}',
                          child: Text('Priorität: ${_priorityToString(p)}'),
                        )),
                    const PopupMenuDivider(),
                    ...uniqueTags.map((tag) => PopupMenuItem(
                          value: 'tag_$tag',
                          child: Text('Tag: $tag'),
                        )),
                  ];
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Task-Card
  Widget _buildTaskCard(Task task) {
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
      child: Card(
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
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
              fontSize: 16,
              decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.dueOn(_formatDate(task.deadline)),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Row(
                children: [
                  Icon(
                    _getPriorityIcon(task.priority),
                    color: _getPriorityColor(task.priority),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getPriorityText(task.priority),
                    style: TextStyle(color: _getPriorityColor(task.priority), fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    task.tags.join(', '),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70),
            onPressed: () => _editTask(task),
          ),
        ),
      ),
    );
  }

  // Add Task Bottom Sheet mit Paywall
  void _showAddTaskSheet() {
    final loc = S.of(context);
    final TextEditingController controller = TextEditingController();
    _newTaskDeadline = DateTime.now();
    _newTaskPriority = TaskPriority.medium;
    _newTaskTags = ['General']; // Fix: Wert auf "General" ändern
    final bool isPremium = Hive.box('settings').get('isPremium', defaultValue: false);

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
                Text(loc.newTaskHint, style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: loc.taskTitleLabel,
                    hintStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 223, 27, 27))),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${loc.dueOn(_formatDate(_newTaskDeadline))}', style: const TextStyle(color: Colors.white70)),
                    IconButton(
                      icon: const Icon(Icons.calendar_month, color: Color.fromARGB(255, 223, 27, 27)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _newTaskDeadline,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) {
                          _newTaskDeadline = picked;
                          (ctx as Element).markNeedsBuild();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isPremium)
                  DropdownButtonFormField<TaskPriority>(
                    value: _newTaskPriority,
                    decoration: InputDecoration(labelText: 'Priority', labelStyle: const TextStyle(color: Colors.white)),
                    dropdownColor: Colors.grey[800],
                    items: TaskPriority.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(_getPriorityText(p), style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (val) => _newTaskPriority = val ?? TaskPriority.medium,
                  )
                else
                  const Text(
                    'Priority: Medium (Get Premium for more.)',
                    style: TextStyle(color: Colors.white70),
                  ),
                const SizedBox(height: 12),
                if (isPremium)
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Tags (kommagetrennt)',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 223, 27, 27))),
                    ),
                    onChanged: (val) => _newTaskTags = val.split(',').map((e) => e.trim()).toList(),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _newTaskTags.first,
                    decoration: InputDecoration(labelText: 'Tags (Get Premium for more.)', labelStyle: const TextStyle(color: Colors.white)),
                    dropdownColor: Colors.grey[800],
                    items: _defaultTags.map((tag) {
                      return DropdownMenuItem(value: tag, child: Text(tag, style: const TextStyle(color: Colors.white)));
                    }).toList(),
                    onChanged: (val) => _newTaskTags = [val ?? 'General'],
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 223, 27, 27)),
                  onPressed: () async {
                    final title = controller.text.trim();
                    if (title.isNotEmpty) {
                      await _dbService.addTask({
                        'id': _uuid.v4(),
                        'title': title,
                        'completed': false,
                        'deadline': _newTaskDeadline.millisecondsSinceEpoch,
                        'createdAt': DateTime.now().millisecondsSinceEpoch,
                        'priority': _newTaskPriority.index,
                        'tags': _newTaskTags,
                      });
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(loc.addTask),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Edit Task mit Paywall
  void _editTask(Task task) {
    final loc = S.of(context);
    final editController = TextEditingController(text: task.title);
    TaskPriority _editPriority = task.priority;
    List<String> _editTags = List.from(task.tags); // Kopie der Tags
    final bool isPremium = Hive.box('settings').get('isPremium', defaultValue: false);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(loc.editTaskDialogTitle, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: editController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: loc.taskTitleLabel,
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 223, 27, 27))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 223, 27, 27), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: task.deadline,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (pickedDate != null) task.deadline = pickedDate;
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(loc.changeDeadline),
                  ),
                  const SizedBox(height: 16),
                  if (isPremium)
                    DropdownButtonFormField<TaskPriority>(
                      value: _editPriority,
                      decoration: InputDecoration(labelText: 'Priorität', labelStyle: const TextStyle(color: Colors.white)),
                      dropdownColor: Colors.grey[800],
                      items: TaskPriority.values.map((p) {
                        return DropdownMenuItem(value: p, child: Text(_getPriorityText(p), style: const TextStyle(color: Colors.white)));
                      }).toList(),
                      onChanged: (val) => _editPriority = val ?? TaskPriority.medium,
                    )
                  else
                    const Text(
                      'Priority: Medium (Get Premium for more.)',
                      style: TextStyle(color: Colors.white70),
                    ),
                  const SizedBox(height: 16),
                  if (isPremium)
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Tags (kommagetrennt)',
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 223, 27, 27))),
                      ),
                      controller: TextEditingController(text: _editTags.join(', ')),
                      onChanged: (val) => _editTags = val.split(',').map((e) => e.trim()).toList(),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: _editTags.first,
                      decoration: InputDecoration(labelText: 'Tags (Get Premium for more.)', labelStyle: const TextStyle(color: Colors.white)),
                      dropdownColor: Colors.grey[800],
                      items: _defaultTags.map((tag) {
                        return DropdownMenuItem(value: tag, child: Text(tag, style: const TextStyle(color: Colors.white)));
                      }).toList(),
                      onChanged: (val) => _editTags = [val ?? 'General'],
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(child: Text(loc.cancel, style: const TextStyle(color: Colors.white)), onPressed: () => Navigator.pop(ctx)),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 223, 27, 27), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () async {
                          final newTitle = editController.text.trim();
                          if (newTitle.isNotEmpty) {
                            task.title = newTitle;
                            task.priority = _editPriority;
                            task.tags = _editTags;
                          }
                          final tasks = await _getAllTasksAsModels();
                          final index = tasks.indexWhere((t) => t.id == task.id);
                          if (index != -1) {
                            await _dbService.updateTask(index, {
                              'id': task.id,
                              'title': task.title,
                              'completed': task.completed,
                              'deadline': task.deadline.millisecondsSinceEpoch,
                              'createdAt': task.createdAt.millisecondsSinceEpoch,
                              'priority': task.priority.index,
                              'tags': task.tags,
                            });
                          }
                          Navigator.pop(ctx);
                        },
                        child: Text(loc.save),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Direkter Kalender-Picker
  Future<void> _showCalendarPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      final tasks = await _getAllTasksAsModels();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CalendarViewPage(tasks: tasks, selectedDay: picked),
        ),
      );
    }
  }

  // Utils
  List<Task> _boxToTaskList(Box box) {
    final List<Task> tasks = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data == null) continue;

      final id = data['id'] as String? ?? _uuid.v4();
      final title = data['title'] as String? ?? '';
      final completed = data['completed'] as bool? ?? false;
      final deadlineTimestamp = data['deadline'] as int?;
      final createdAtTimestamp = data['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch;
      final priorityIndex = data['priority'] as int? ?? 1; // Default: medium
      final tags = data['tags'] != null ? List<String>.from(data['tags']) : ['General'];

      final deadline = deadlineTimestamp != null ? DateTime.fromMillisecondsSinceEpoch(deadlineTimestamp) : DateTime.now();
      final createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtTimestamp);

      tasks.add(Task(
        id: id,
        title: title,
        completed: completed,
        deadline: deadline,
        createdAt: createdAt,
        priority: TaskPriority.values[priorityIndex],
        tags: tags,
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

  String _formatDate(DateTime date) => '${date.day}.${date.month}.${date.year}';

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low: return Icons.low_priority;
      case TaskPriority.medium: return Icons.priority_high;
      case TaskPriority.high: return Icons.warning;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low: return Colors.green;
      case TaskPriority.medium: return Colors.orange;
      case TaskPriority.high: return Colors.red;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low: return 'Low';
      case TaskPriority.medium: return 'Medium';
      case TaskPriority.high: return 'High';
    }
  }

  TaskPriority _stringToPriority(String str) {
    switch (str) {
      case 'Low': return TaskPriority.low;
      case 'Medium': return TaskPriority.medium;
      case 'High': return TaskPriority.high;
      default: return TaskPriority.medium;
    }
  }

  String _priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low: return 'Niedrig';
      case TaskPriority.medium: return 'Mittel';
      case TaskPriority.high: return 'Hoch';
    }
  }

  void _toggleTask(Task task) async {
    task.completed = !task.completed;
    final tasks = await _getAllTasksAsModels();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      await _dbService.updateTask(index, {
        'id': task.id,
        'title': task.title,
        'completed': task.completed,
        'deadline': task.deadline.millisecondsSinceEpoch,
        'createdAt': task.createdAt.millisecondsSinceEpoch,
        'priority': task.priority.index,
        'tags': task.tags,
      });
    }
  }

  void _deleteTask(Task task) async {
    final tasks = await _getAllTasksAsModels();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      await _dbService.deleteTask(index);
    }
  }
}

// CalendarViewPage
class CalendarViewPage extends StatelessWidget {
  final List<Task> tasks;
  final DateTime selectedDay;

  const CalendarViewPage({Key? key, required this.tasks, required this.selectedDay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final filtered = tasks.where((t) => _isSameDay(t.deadline, selectedDay)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(loc.calendarViewTitle), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tasks for ${_formatDate(selectedDay)}', // Statischer String statt loc.tasksForDay
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(loc.noTasksForDay(_formatDate(selectedDay)), style: const TextStyle(color: Colors.white)))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final task = filtered[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          leading: Icon(
                            task.completed ? Icons.check_circle : Icons.circle_outlined,
                            color: task.completed ? Colors.green : Colors.grey,
                          ),
                          title: Text(task.title, style: TextStyle(color: Colors.white, decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none)),
                          trailing: Icon(Icons.edit, color: Colors.white70),
                          onTap: () {
                            // Hier könnte man Edit-Funktionalität hinzufügen
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) => d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

  String _formatDate(DateTime date) => '${date.day}.${date.month}.${date.year}';
}