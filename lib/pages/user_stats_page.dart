// lib/pages/user_stats_page.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../l10n/generated/l10n.dart';
import 'todo_list.dart';

class UserStatsPage extends StatefulWidget {
  const UserStatsPage({Key? key}) : super(key: key);

  @override
  _UserStatsPageState createState() => _UserStatsPageState();
}

class _UserStatsPageState extends State<UserStatsPage>
    with SingleTickerProviderStateMixin {
  final DBService _dbService = DBService();
  DateTime _displayedMonth = DateTime.now();
  late TabController _tabController;
  int _selectedIndex = 0;

  final Color _primaryColor = const Color(0xFFDF1B1B); // Main red color
  final Color _secondaryColor = const Color(0xFF383838); // Dark gray
  final Color _backgroundColor = const Color(0xFF121212); // Very dark background
  final Color _cardColor = const Color(0xFF1E1E1E); // Slightly lighter than background

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Hilfsmethode zum Parsen von Datum: Akzeptiert sowohl int als auch String
  DateTime _parseDate(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      return DateTime.parse(value);
    } else {
      return DateTime.now();
    }
  }

  // Konvertiert die Tasks-Box in eine Liste von Tasks
  List<Task> _boxToTaskList(Box box) {
    final List<Task> tasks = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data == null) continue;

      final id = data['id'] as String? ?? '';
      final title = data['title'] as String? ?? '';
      final completed = data['completed'] as bool? ?? false;
      final deadline = _parseDate(data['deadline']);
      final createdAt = _parseDate(data['createdAt']);

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

  // Berechnet den Anteil abgeschlossener Tasks an einem Tag
  double _calculateCompletionPercentage(DateTime day, List<Task> tasks) {
    final tasksForDay =
        tasks.where((task) => isSameDay(task.deadline, day)).toList();
    if (tasksForDay.isEmpty) return 0.0;
    final completedCount =
        tasksForDay.where((task) => task.completed).length;
    return completedCount / tasksForDay.length;
  }

  // Berechnet den wöchentlichen Abschlussprozentsatz
  Map<String, double> _calculateWeeklyCompletion(List<Task> tasks) {
    final now = DateTime.now();
    final Map<String, double> weeklyData = {};

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final tasksForDay =
          tasks.where((task) => isSameDay(task.deadline, day)).toList();

      double percentage = 0.0;
      if (tasksForDay.isNotEmpty) {
        final completedCount =
            tasksForDay.where((task) => task.completed).length;
        percentage = completedCount / tasksForDay.length;
      }

      // Formatiere als Wochentagskürzel
      final dayName = DateFormat('E').format(day);
      weeklyData[dayName] = percentage;
    }

    return weeklyData;
  }

  // Ermittelt die Gesamtstatistiken für den aktuellen Monat
  Map<String, int> _getMonthlyStats(List<Task> tasks) {
    final tasksThisMonth = tasks.where((task) =>
        task.deadline.year == _displayedMonth.year &&
        task.deadline.month == _displayedMonth.month).toList();

    final totalTasks = tasksThisMonth.length;
    final completedTasks =
        tasksThisMonth.where((task) => task.completed).length;
    final pendingTasks = totalTasks - completedTasks;

    return {
      'total': totalTasks,
      'completed': completedTasks,
      'pending': pendingTasks,
    };
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year &&
        d1.month == d2.month &&
        d1.day == d2.day;
  }

  // Baut das Kalender-Gitter für den aktuellen Monat
  Widget _buildCalendar(List<Task> tasks) {
    final firstDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    int startingWeekday = firstDayOfMonth.weekday;
    List<Widget> dayWidgets = [];

    // Wochentagsüberschriften (internationalisiert)
    final weekdayNames = [
      S.of(context).mondayShort,
      S.of(context).tuesdayShort,
      S.of(context).wednesdayShort,
      S.of(context).thursdayShort,
      S.of(context).fridayShort,
      S.of(context).saturdayShort,
      S.of(context).sundayShort,
    ];
    for (var name in weekdayNames) {
      dayWidgets.add(
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            name,
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    // Leere Felder vor dem 1. Tag
    for (int i = 1; i < startingWeekday; i++) {
      dayWidgets.add(Container());
    }

    // Tage des Monats
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final currentDay =
          DateTime(_displayedMonth.year, _displayedMonth.month, day);
      final percentage = _calculateCompletionPercentage(currentDay, tasks);
      final dayTasks =
          tasks.where((task) => isSameDay(task.deadline, currentDay)).toList();
      final isToday = isSameDay(currentDay, DateTime.now());

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DayTasksPage(
                  tasks: tasks,
                  selectedDay: currentDay,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isToday
                  ? _primaryColor.withOpacity(0.15)
                  : _cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isToday
                  ? Border.all(color: _primaryColor, width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.toString(),
                    style: TextStyle(
                      color: isToday ? _primaryColor : Colors.white,
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (dayTasks.isNotEmpty)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            value: percentage,
                            backgroundColor:
                                _secondaryColor.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              percentage > 0.7
                                  ? Colors.green
                                  : percentage > 0.3
                                      ? Colors.orange
                                      : _primaryColor,
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                        Text(
                          '${(percentage * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: percentage > 0.7
                                ? Colors.green
                                : percentage > 0.3
                                    ? Colors.orange
                                    : _primaryColor,
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _secondaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_box_outline_blank,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${dayTasks.length} ${S.of(context).taskLabel(dayTasks.length)}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      children: dayWidgets,
    );
  }

  // Baut das wöchentliche Fortschrittsdiagramm
  Widget _buildWeeklyProgressChart(Map<String, double> weeklyData) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).weeklyProgress,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${(rod.toY * 100).toInt()}%',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < weeklyData.keys.length) {
                          return Text(
                            weeklyData.keys.elementAt(index),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == 0.5 || value == 1.0) {
                          return Text(
                            '${(value * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: List.generate(weeklyData.length, (index) {
                  final entry = weeklyData.entries.elementAt(index);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: entry.value > 0.7
                            ? Colors.green
                            : entry.value > 0.3
                                ? Colors.orange
                                : _primaryColor,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 1,
                          color: _secondaryColor.withOpacity(0.2),
                        ),
                      ),
                    ],
                  );
                }),
                gridData: FlGridData(
                  show: true,
                  checkToShowHorizontalLine: (value) =>
                      value == 0.5 || value == 1.0,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Baut die monatlichen Statistik-Zusammenfassungen
  Widget _buildMonthlyStatsSummary(Map<String, int> stats) {
    return Row(
      children: [
        _buildStatCard(
          S.of(context).totalTasks,
          stats['total'] ?? 0,
          Icons.assignment,
          Colors.blue,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          S.of(context).completed,
          stats['completed'] ?? 0,
          Icons.check_circle_outline,
          Colors.green,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          S.of(context).pending,
          stats['pending'] ?? 0,
          Icons.pending_actions,
          _primaryColor,
        ),
      ],
    );
  }

  // Baut eine einzelne Statistik-Karte
  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Formatiert den Monat zur Anzeige
  String _formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.viewStats,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: _cardColor,
                  title: Text(
                    loc.aboutStatistics,
                    style: const TextStyle(color: Colors.white),
                  ),
                  content: Text(
                    loc.aboutStatisticsContent,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        loc.gotIt,
                        style: TextStyle(color: _primaryColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _primaryColor,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: Icon(
                Icons.calendar_month,
                color: _selectedIndex == 0 ? _primaryColor : Colors.grey,
              ),
              text: loc.calendarTab,
            ),
            Tab(
              icon: Icon(
                Icons.analytics,
                color: _selectedIndex == 1 ? _primaryColor : Colors.grey,
              ),
              text: loc.analyticsTab,
            ),
          ],
        ),
      ),
      backgroundColor: _backgroundColor,
      body: ValueListenableBuilder(
        valueListenable: _dbService.listenableTasks(),
        builder: (context, Box box, _) {
          final tasks = _boxToTaskList(box);
          final weeklyData = _calculateWeeklyCompletion(tasks);
          final monthlyStats = _getMonthlyStats(tasks);

          return TabBarView(
            controller: _tabController,
            children: [
              // Kalender-Tab
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Monatsnavigation
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: _previousMonth,
                              icon: const Icon(Icons.chevron_left, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: _secondaryColor,
                                minimumSize: const Size(40, 40),
                              ),
                            ),
                            Text(
                              _formatMonth(_displayedMonth),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _nextMonth,
                              icon: const Icon(Icons.chevron_right, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: _secondaryColor,
                                minimumSize: const Size(40, 40),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Kalendergitter
                      Container(
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: _buildCalendar(tasks),
                      ),
                      const SizedBox(height: 20),
                      // Monatliche Zusammenfassung
                      _buildMonthlyStatsSummary(monthlyStats),
                    ],
                  ),
                ),
              ),
              // Analyse-Tab
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.taskCompletionTrends,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildWeeklyProgressChart(weeklyData),
                      const SizedBox(height: 24),
                      Text(
                        loc.monthlyOverview,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMonthlyStatsSummary(monthlyStats),
                      const SizedBox(height: 24),
                      // Productivity Score Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [_cardColor, _primaryColor.withOpacity(0.2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.productivityScore,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    loc.newLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: (monthlyStats['completed'] != null &&
                                      monthlyStats['total'] != null &&
                                      monthlyStats['total']! > 0)
                                  ? monthlyStats['completed']! / monthlyStats['total']!
                                  : 0.0,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              (monthlyStats['completed'] != null &&
                                      monthlyStats['total'] != null &&
                                      monthlyStats['total']! > 0)
                                  ? loc.completedTasksPercentage(
                                      ((monthlyStats['completed']! / monthlyStats['total']!) * 100).toInt())
                                  : loc.noTasksScheduled,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (monthlyStats['pending'] != null && monthlyStats['pending']! > 0)
                                  ? loc.completeMoreTasks(monthlyStats['pending']!)
                                  : (monthlyStats['completed'] != null && monthlyStats['completed']! > 0)
                                      ? loc.allTasksCompleted
                                      : loc.startAddingTasks,
                              style: TextStyle(
                                color: (monthlyStats['pending'] != null && monthlyStats['pending']! > 0)
                                    ? _primaryColor
                                    : Colors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DayTasksPage(
                tasks: _boxToTaskList(_dbService.listenableTasks().value),
                selectedDay: DateTime.now(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add_task),
      ),
    );
  }
}

class DayTasksPage extends StatelessWidget {
  final List<Task> tasks;
  final DateTime selectedDay;

  const DayTasksPage({Key? key, required this.tasks, required this.selectedDay})
      : super(key: key);

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year &&
        d1.month == d2.month &&
        d1.day == d2.day;
  }

  String _formatDate(DateTime date) => '${date.day}.${date.month}.${date.year}';

  @override
  Widget build(BuildContext context) {
    final filteredTasks =
        tasks.where((task) => isSameDay(task.deadline, selectedDay)).toList();
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_formatDate(selectedDay)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: filteredTasks.isEmpty
          ? Center(
              child: Text(
                loc.noTasksForDay(_formatDate(selectedDay)),
                style: const TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Icon(
                      task.completed ? Icons.check_circle : Icons.circle_outlined,
                      color: task.completed ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        color: Colors.white,
                        decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                      loc.dueOn(_formatDate(task.deadline)),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Icon(Icons.edit, color: Colors.white70),
                    onTap: () {
                      // Hier könnte man Edit-Funktionalität hinzufügen
                    },
                  ),
                );
              },
            ),
    );
  }
}
