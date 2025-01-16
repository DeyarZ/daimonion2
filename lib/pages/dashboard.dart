import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMob-Import

import '../services/db_service.dart';
import '../services/flow_timer_service.dart';
import '../pages/todo_list.dart';
import '../pages/habit_tracker.dart';

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

class Habit {
  String id;
  String name;
  Map<String, bool?> dailyStatus;
  List<int> selectedWeekdays;

  Habit({
    required this.id,
    required this.name,
    required this.dailyStatus,
    required this.selectedWeekdays,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final DBService _dbService = DBService();
  final Uuid _uuid = const Uuid();

  // Neue Variablen für Ads
  late BannerAd _bannerAd; // AdMob BannerAd
  bool _isAdLoaded = false;

  int _streak = 0; // aus Hive gelesen
  int _flowSessions = 0; // ephemere Zählung (verschwindet beim Restart)
  int _lastFlowIndex = 0; // um Flow-Veränderungen zu erkennen

  final List<DateTime> _weekDates = [];

  @override
  void initState() {
    super.initState();
    _initWeekDates();

    // STREAK-Wert aus settings-Box lesen
    final settingsBox = Hive.box('settings');
    _streak = settingsBox.get('streak', defaultValue: 1);

    // AdMob Banner laden
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd.dispose(); // Ad-Objekt sauber entfernen
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2524075415669673~7860955987',
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

  void _initWeekDates() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    for (int i = 0; i < 7; i++) {
      _weekDates.add(monday.add(Duration(days: i)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final flowTimer = context.watch<FlowTimerService>();
    final isRunning = flowTimer.isRunning;
    final secondsLeft = flowTimer.secondsLeft;
    final m = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (secondsLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildFlowSessionsCard()),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStreakCard()),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFlowTimerCard(isRunning, '$m:$s')),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.grey[850],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _buildMotivationSection(),
                  ),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder(
                  valueListenable: _dbService.listenableTasks(),
                  builder: (context, taskBox, _) {
                    final tasks = _boxToTaskList(taskBox as Box);
                    final now = DateTime.now();

                    final todayTasks = tasks.where((t) => _isSameDay(t.deadline, now)).toList();
                    final totalTasks = todayTasks.length;
                    final doneTasks = todayTasks.where((t) => t.completed).length;
                    final tasksPercent =
                        (totalTasks == 0) ? 0.0 : (doneTasks / totalTasks);

                    final dailyPercents = _calculateWeeklyPercents(tasks);

                    return Column(
                      children: [
                        Card(
                          color: Colors.grey[850],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: _buildTodayAndPieRow(tasksPercent, todayTasks),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          color: Colors.grey[850],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ToDoListPage()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: _buildWeeklyProgressChart(dailyPercents),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder(
                  valueListenable: _dbService.listenableHabits(),
                  builder: (context, habitBox, _) {
                    final habits = _boxToHabitList(habitBox as Box);
                    final cheer = _calculateCheerMessage(habits);
                    if (cheer == null) return const SizedBox();
                    return Card(
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          cheer,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
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
  // ------------------------------------------------
  // FLOW-SESSIONS CARD (statt wasted time)
  // ------------------------------------------------
  Widget _buildFlowSessionsCard() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_flowSessions',
              style: const TextStyle(
                fontFamily: 'Digital',
                fontSize: 28,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'FLOW-SESSIONS',
              style: TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------
  // STREAK
  // ------------------------------------------------
  Widget _buildStreakCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      height: 90,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_streak',
              style: const TextStyle(
                fontFamily: 'Digital',
                fontSize: 28,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'STREAK',
              style: TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------
  // FLOW TIMER
  // ------------------------------------------------
  Widget _buildFlowTimerCard(bool isRunning, String timeString) {
    final flowTimer = context.watch<FlowTimerService>();
    return GestureDetector(
      onTap: () {
        if (isRunning) {
          flowTimer.pauseTimer();
        } else {
          flowTimer.startTimer();
        }
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isRunning ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.redAccent,
                    size: 24,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeString,
                    style: const TextStyle(
                      fontFamily: 'Digital',
                      fontSize: 28,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'FLOW TIMER',
                style: TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------
  // MOTIVATION SECTION
  // ------------------------------------------------
  Widget _buildMotivationSection() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/arnold.jpg',
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Du bist nicht hier, um Durchschnitt zu sein. Jeder Tag ist eine neue Schlacht – also kämpf, bis es keine Grenzen mehr gibt, nur Ergebnisse.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'BebasNeue',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------
  // HOY: Today tasks + (2 circle pies)
  // ------------------------------------------------
  Widget _buildTodayAndPieRow(double tasksPercent, List<Task> todayTasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Heute-Tasks
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ToDoListPage()),
            );
          },
          child: _buildTodaysTaskCard(todayTasks),
        ),

        const SizedBox(height: 16),

        // 2 Circle Charts => Tasks & Habits
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ToDoListPage()),
                  );
                },
                child: _buildPieChart(
                  tasksPercent,
                  title: 'Tasks',
                  size: 120,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HabitTrackerPage()),
                  );
                },
                child: _buildPieChart(
                  _calculateHabitsPercent(),
                  title: 'Habits',
                  size: 120,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------
  // HABITS PERCENT
  // ------------------------------------------------
  double _calculateHabitsPercent() {
    final habitBox = _dbService.getHabitsBox();
    final habits = _boxToHabitList(habitBox);
    final todayWd = DateTime.now().weekday;
    final dayKey = _formatDateKey(DateTime.now());
    int totalHabits = 0, doneHabits = 0;
    for (var h in habits) {
      if (h.selectedWeekdays.contains(todayWd)) {
        totalHabits++;
        final st = h.dailyStatus[dayKey];
        if (st == true) doneHabits++;
      }
    }
    return (totalHabits == 0) ? 0.0 : (doneHabits / totalHabits);
  }

  // ------------------------------------------------
  // CHEER MSG
  // ------------------------------------------------
  String? _calculateCheerMessage(List<Habit> habits) {
    final todayWd = DateTime.now().weekday;
    final dayKey = _formatDateKey(DateTime.now());
    int doneCount = 0, totalCount = 0;
    for (var h in habits) {
      if (h.selectedWeekdays.contains(todayWd)) {
        totalCount++;
        if (h.dailyStatus[dayKey] == true) doneCount++;
      }
    }
    if (totalCount == 0) return null;
    final ratio = doneCount / totalCount;
    if (ratio >= 1.0) {
      return 'Perfekt! Du hast heute alle Gewohnheiten erledigt. Keep pushing!';
    } else if (ratio >= 0.5) {
      return 'Schon über die Hälfte deiner Gewohnheiten geschafft – stark!';
    } else if (ratio > 0.0) {
      return 'Noch nicht fertig, aber du packst das. Nur weitermachen!';
    } else {
      return 'Pack an! Zeit, etwas zu tun!';
    }
  }

  // ------------------------------------------------
  // TODAY TASKS
  // ------------------------------------------------
  Widget _buildTodaysTaskCard(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: const Center(
          child: Text('Keine Aufgaben für heute',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Text(
            'HEUTIGE TASKS',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.grey),
          ...tasks.map((task) {
            return GestureDetector(
              onTap: () => _toggleTask(task),
              child: Row(
                children: [
                  Icon(
                    task.completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: task.completed ? Colors.green : Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        color: task.completed ? Colors.green : Colors.white,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ------------------------------------------------
  // PIE CHART
  // ------------------------------------------------
  Widget _buildPieChart(
    double completionPercent, {
    required String title,
    double size = 100,
  }) {
    final percentage = (completionPercent * 100).toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: size,
            width: size,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 28,
                    sections: [
                      PieChartSectionData(
                        value: completionPercent * 100,
                        color: Colors.redAccent,
                        radius: 22,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: (1 - completionPercent) * 100,
                        color: Colors.grey,
                        radius: 22,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------
  // WEEKLY PROGRESS => BAR CHART
  // ------------------------------------------------
  Widget _buildWeeklyProgressChart(List<double> dailyPercents) {
    final days = ['MO', 'DI', 'MI', 'DO', 'FR', 'SA', 'SO'];

    return Column(
      children: [
        const Text(
          'WOCHENFORTSCHRITT',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              minY: 0,
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white10,
                  strokeWidth: 1,
                ),
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 25,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < 7) {
                        return Text(
                          days[idx],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              barGroups: List.generate(7, (index) {
                final val = dailyPercents[index];
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: val,
                      color: Colors.redAccent,
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------
  // UTILS
  // ------------------------------------------------
  List<Task> _boxToTaskList(Box box) {
    final List<Task> tasks = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data == null) continue;

      final id = data['id'] as String? ?? _uuid.v4();
      final title = data['title'] as String? ?? '';
      final completed = data['completed'] as bool? ?? false;
      final deadlineTs = data['deadline'] as int?;
      final deadline = deadlineTs != null
          ? DateTime.fromMillisecondsSinceEpoch(deadlineTs)
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

  List<Habit> _boxToHabitList(Box box) {
    final List<Habit> habits = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data == null) continue;

      final id = data['id'] as String? ?? _uuid.v4();
      final name = data['name'] as String? ?? '';
      final dailyStatus = Map<String, bool?>.from(data['dailyStatus'] ?? {});
      final selectedWeekdays = List<int>.from(data['selectedWeekdays'] ?? []);

      habits.add(Habit(
        id: id,
        name: name,
        dailyStatus: dailyStatus,
        selectedWeekdays: selectedWeekdays,
      ));
    }
    return habits;
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<double> _calculateWeeklyPercents(List<Task> tasks) {
    final results = <double>[];
    for (int i = 0; i < 7; i++) {
      final dayDate = _weekDates[i];
      final tasksForDay = tasks.where((t) => _isSameDay(t.deadline, dayDate)).toList();
      if (tasksForDay.isEmpty) {
        results.add(0.0);
      } else {
        final done = tasksForDay.where((t) => t.completed).length;
        results.add((done / tasksForDay.length) * 100);
      }
    }
    return results;
  }

  Future<void> _toggleTask(Task task) async {
    final box = await Hive.openBox<Map>(DBService.tasksBoxName);
    final allTasks = _boxToTaskList(box);
    final index = allTasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    allTasks[index].completed = !allTasks[index].completed;

    await _dbService.updateTask(
      index,
      {
        'id': allTasks[index].id,
        'title': allTasks[index].title,
        'completed': allTasks[index].completed,
        'deadline': allTasks[index].deadline.millisecondsSinceEpoch,
      },
    );

    setState(() {});
  }
}
