import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMob import
import 'package:uuid/uuid.dart';
import '../services/db_service.dart';

// ------------------------------
// Model: Task
// ------------------------------
class Task {
  final String id;
  String title;
  bool completed;
  DateTime deadline;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
    required this.deadline,
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
  final TextEditingController _controller = TextEditingController();
  final _uuid = const Uuid();
  final DBService _dbService = DBService();

  // Neue Variablen für Ads
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    // AdMob Banner laden
    _loadBannerAd();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bannerAd.dispose(); // Ad-Objekt sauber entfernen
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2524075415669673~7860955987', // Deine Anzeigenblock-ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do-Liste'),
        backgroundColor: Colors.black,
        actions: [
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
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Neue Aufgabe...',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent),
                          ),
                        ),
                        onSubmitted: (val) => _pickDeadlineAndAdd(val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () => _pickDeadlineAndAdd(_controller.text),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _dbService.listenableTasks(),
                  builder: (context, Box box, child) {
                    if (box.isEmpty) {
                      return const Center(
                        child: Text(
                          'Keine Aufgaben',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final allTasks = _boxToTaskList(box);
                    final grouped = _groupTasksByDate(allTasks);
                    final sortedDates = grouped.keys.toList()
                      ..sort((a, b) => a.compareTo(b));

                    return ListView.builder(
                      itemCount: sortedDates.length,
                      itemBuilder: (context, index) {
                        final dateKey = sortedDates[index];
                        final tasksForDate = grouped[dateKey]!;

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
          if (_isAdLoaded)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Deadline wählen & Task anlegen
  // ----------------------------------------------------
  Future<void> _pickDeadlineAndAdd(String taskTitle) async {
    final trimmed = taskTitle.trim();
    if (trimmed.isEmpty) return;
    _controller.clear();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      await _dbService.addTask({
        'id': _uuid.v4(),
        'title': trimmed,
        'completed': false,
        'deadline': picked.millisecondsSinceEpoch,
      });
    }
  }

  // ----------------------------------------------------
  // Ein Task-Item im UI
  // ----------------------------------------------------
  Widget _buildTaskTile(Task task) {
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
            'Fällig am ${_formatDate(task.deadline)}',
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
  // Edit
  // ----------------------------------------------------
  void _editTask(Task task) {
    final editController = TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Aufgabe bearbeiten',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titel
            TextField(
              controller: editController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Titel',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Deadline ändern
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: task.deadline,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (pickedDate != null) {
                  setState(() {
                    task.deadline = pickedDate;
                  });
                }
              },
              child: const Text('Deadline ändern'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Abbrechen', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('Speichern', style: TextStyle(color: Colors.redAccent)),
            onPressed: () async {
              final newTitle = editController.text.trim();
              if (newTitle.isNotEmpty) {
                task.title = newTitle;
              }
              // Update Hive
              final tasks = await _getAllTasksAsModels();
              final index = tasks.indexWhere((t) => t.id == task.id);
              if (index != -1) {
                await _dbService.updateTask(
                  index,
                  {
                    'id': task.id,
                    'title': task.title,
                    'completed': task.completed,
                    'deadline': task.deadline.millisecondsSinceEpoch,
                  },
                );
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Toggle
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
      },
    );
  }

  // ----------------------------------------------------
  // Delete
  // ----------------------------------------------------
  Future<void> _deleteTask(Task task) async {
    final tasks = await _getAllTasksAsModels();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    await _dbService.deleteTask(index);
  }

  // ----------------------------------------------------
  // Box -> List<Task>
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
      final deadline = deadlineTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(deadlineTimestamp)
          : DateTime.now();

      tasks.add(Task(
        id: id,
        title: title,
        completed: completed,
        deadline: deadline,
      ));
    }
    return tasks;
  }

  // ----------------------------------------------------
  // Alle Tasks als Models
  // ----------------------------------------------------
  Future<List<Task>> _getAllTasksAsModels() async {
    final box = await Hive.openBox<Map>(DBService.tasksBoxName);
    return _boxToTaskList(box);
  }

  // ----------------------------------------------------
  // Gruppieren nach Datum
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
// CalendarViewPage
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
    final filtered = widget.tasks
        .where((t) => _isSameDay(t.deadline, _selectedDay))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender-Übersicht'),
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
              child: Text('Tag wählen: ${_formattedDate(_selectedDay)}'),
            ),
          ),

          // Liste der gefilterten Tasks
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'Keine Aufgaben für ${_formattedDate(_selectedDay)}',
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
