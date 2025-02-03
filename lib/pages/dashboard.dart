import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

// Services & Pages (anpassen an deine Ordnerstruktur)
import '../services/db_service.dart';
import '../services/flow_timer_service.dart';
import '../pages/todo_list.dart';
import '../pages/habit_tracker.dart';
import 'flow_stats_page.dart';
import '../widgets/ad_wrapper.dart';

// Importiere Lokalisierung
import '../l10n/generated/l10n.dart';

// ------------------------------------------------
// Lokale Notifications Plugin
// ------------------------------------------------
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ------------------------------------------------
// MODELDATEN für Flow-Sessions
// ------------------------------------------------
class FlowSession {
  final DateTime date;
  final int minutes;
  FlowSession({required this.date, required this.minutes});
}

// ------------------------------------------------
// TASK / HABIT MODEL
// ------------------------------------------------
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

// ------------------------------------------------
// DAILY CHECK MODELL
// ------------------------------------------------
class DailyCheckModel {
  bool gym;
  bool mental;
  bool noPorn;
  bool healthyEating;
  bool helpOthers;
  bool natureTime;

  DailyCheckModel({
    this.gym = false,
    this.mental = false,
    this.noPorn = false,
    this.healthyEating = false,
    this.helpOthers = false,
    this.natureTime = false,
  });

  Map<String, bool> toMap() {
    return {
      'gym': gym,
      'mental': mental,
      'noPorn': noPorn,
      'healthyEating': healthyEating,
      'helpOthers': helpOthers,
      'natureTime': natureTime,
    };
  }

  factory DailyCheckModel.fromMap(Map map) {
    return DailyCheckModel(
      gym: map['gym'] ?? false,
      mental: map['mental'] ?? false,
      noPorn: map['noPorn'] ?? false,
      healthyEating: map['healthyEating'] ?? false,
      helpOthers: map['helpOthers'] ?? false,
      natureTime: map['natureTime'] ?? false,
    );
  }

  /// Wie viele NICHT erledigt?
  int get missedCount {
    int c = 0;
    if (!gym) c++;
    if (!mental) c++;
    if (!noPorn) c++;
    if (!healthyEating) c++;
    if (!helpOthers) c++;
    if (!natureTime) c++;
    return c;
  }
}

// ------------------------------------------------
// Hive Keys
// ------------------------------------------------
const String dailyChecksBoxKey = 'dailyChecksBoxKey';
const String dailyCheckDateKey = 'dailyCheckDateKey';

// ------------------------------------------------
// DASHBOARD
// ------------------------------------------------
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final DBService _dbService = DBService();
  final Uuid _uuid = const Uuid();

  int _streak = 0; 
  final List<DateTime> _weekDates = [];
  int? _weeklyFlowSeconds; 
  final List<String> _motivationImages = [
    'assets/images/8bit_squat.png',
    'assets/images/alexander.png',
    'assets/images/arnold.jpg',
    'assets/images/chess.png',
    'assets/images/ferrari.png',
    'assets/images/garage.png',
    'assets/images/gervonta.png',
    'assets/images/gloves.png',
    'assets/images/greek_focus.png',
    'assets/images/gymrack.png',
    'assets/images/hustle_rari-png',
    'assets/images/khabib.png',
    'assets/images/lambo_gelb.png',
    'assets/images/limit.png',
    'assets/images/lion.png',
    'assets/images/matrix.png',
    'assets/images/napoleon.png',
    'assets/images/nate.png',
    'assets/images/rolex.png',
    'assets/images/ronaldo.png',
    'assets/images/spartan.png',
    'assets/images/tate.png',
    'assets/images/wolf.png',
  ];

  late String _randomQuote;
  late String _randomImage;

  // Daily Checks
  DailyCheckModel _todayCheck = DailyCheckModel();

  @override
  void initState() {
    super.initState();
    _initWeekDates();
    _loadStreakFromHive();
    _loadWeeklyFlowSeconds();
    _pickRandomImage();

    // DailyCheck laden
    _loadTodayChecks().then((_) {
      // Neuer Tag => verpasste Checks => Notification
      _handleNewDayAndScheduleInsult();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final quotes = S.of(context).motivationQuotes.split('||');
    _randomQuote = quotes[Random().nextInt(quotes.length)];
  }

  // ------------------------------------------------
  // Neuer Tag => Beleidigungs-Notif
  // ------------------------------------------------
  Future<void> _handleNewDayAndScheduleInsult() async {
    final box = Hive.box('settings');
    final storedDate = box.get(dailyCheckDateKey, defaultValue: '');
    final todayDateKey = _formatDateKey(DateTime.now());

    if (storedDate != todayDateKey && storedDate.isNotEmpty) {
      final missedCount = await _countMissedTasksYesterday(storedDate);
      if (missedCount > 0) {
        await _scheduleInsultNotification(missedCount);
      }
    }
    box.put(dailyCheckDateKey, todayDateKey);
  }

  Future<int> _countMissedTasksYesterday(String dateKey) async {
    final box = Hive.box('settings');
    final map = box.get('$dailyChecksBoxKey\_$dateKey') as Map?;
    if (map == null) {
      return 6; // Alle 6 verpasst
    }
    final model = DailyCheckModel.fromMap(map);
    return model.missedCount;
  }

  Future<void> _scheduleInsultNotification(int missedCount) async {
    final androidDetails = const AndroidNotificationDetails(
      'daily_insult_channel',
      'Daily Insult Channel',
      channelDescription: 'Channel for daily humiliations',
      importance: Importance.high,
      priority: Priority.high,
    );
    final noticeDetails = NotificationDetails(android: androidDetails);

    final title = S.of(context).dailyInsultTitle;
    String body;
    if (missedCount == 6) {
      body = S.of(context).dailyInsultAllMissed;
    } else {
      body = S.of(context).dailyInsultSomeMissed(missedCount.toString());
    }

    const notificationId = 3333;
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 0, 5);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduled,
      noticeDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ------------------------------------------------
  // Daily Checks heute laden
  // ------------------------------------------------
  Future<void> _loadTodayChecks() async {
    final box = Hive.box('settings');
    final todayKey = _formatDateKey(DateTime.now());
    final map = box.get('$dailyChecksBoxKey\_$todayKey') as Map?;

    if (map != null) {
      setState(() {
        _todayCheck = DailyCheckModel.fromMap(map);
      });
    } else {
      setState(() {
        _todayCheck = DailyCheckModel();
      });
    }
  }

  Future<void> _saveTodayChecks() async {
    final box = Hive.box('settings');
    final todayKey = _formatDateKey(DateTime.now());
    await box.put('$dailyChecksBoxKey\_$todayKey', _todayCheck.toMap());
  }

  // ------------------------------------------------
  // Week, Streak, Flow
  // ------------------------------------------------
  void _initWeekDates() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    for (int i = 0; i < 7; i++) {
      _weekDates.add(monday.add(Duration(days: i)));
    }
  }

  void _loadStreakFromHive() {
    final settingsBox = Hive.box('settings');
    _streak = settingsBox.get('streak', defaultValue: 1);
  }

  Future<void> _loadWeeklyFlowSeconds() async {
    final box = await Hive.openBox<Map>('flow_sessions');
    final allSessions = _boxToFlowSessions(box);

    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 6));
    final filtered =
        allSessions.where((fs) => fs.date.isAfter(_startOfDay(from))).toList();
    final totalFlowMinutes = filtered.fold<int>(0, (sum, fs) => sum + fs.minutes);
    final totalSeconds = totalFlowMinutes * 60;

    setState(() {
      _weeklyFlowSeconds = totalSeconds;
    });
  }

  // ------------------------------------------------
  // BUILD
  // ------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final flowTimer = context.watch<FlowTimerService>();
    final isRunning = flowTimer.isRunning;
    final secondsLeft = flowTimer.secondsLeft;
    final m = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (secondsLeft % 60).toString().padLeft(2, '0');

    return AdWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).dashboardTitle),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ------------------------------------
              // TOP-ROW (Flow, Streak, Timer)
              // ------------------------------------
              Row(
                children: [
                  Expanded(child: _buildWeeklyFlowTimeCard()),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStreakCard()),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFlowTimerCard(isRunning, '$m:$s')),
                ],
              ),
              const SizedBox(height: 16),

              // ------------------------------------
              // FUNDAMENTALS
              // ------------------------------------
              Card(
                color: Colors.grey[850],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        S.of(context).dailyFundamentalsTitle, // "FUNDAMENTALS"
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.2,
                        children: [
                          // GYM
                          _buildDailyCheckShortItem(
                            shortLabel: S.of(context).shortCheckGym,     // "Sport"
                            fullText: S.of(context).fullCheckGym,        // "Did you workout..."
                            isDone: _todayCheck.gym,
                            onToggleDirect: () {
                              setState(() {
                                _todayCheck.gym = !_todayCheck.gym;
                              });
                              _saveTodayChecks();
                            },
                            onDialogChanged: (val) {
                              setState(() {
                                _todayCheck.gym = val;
                              });
                              _saveTodayChecks();
                            },
                          ),
                          // MENTAL
                          _buildDailyCheckShortItem(
                            shortLabel: S.of(context).shortCheckMental,
                            fullText: S.of(context).fullCheckMental,
                            isDone: _todayCheck.mental,
                            onToggleDirect: () {
                              setState(() {
                                _todayCheck.mental = !_todayCheck.mental;
                              });
                              _saveTodayChecks();
                            },
                            onDialogChanged: (val) {
                              setState(() {
                                _todayCheck.mental = val;
                              });
                              _saveTodayChecks();
                            },
                          ),
                          // NO PORN
                          _buildDailyCheckShortItem(
                            shortLabel: S.of(context).shortCheckNoPorn,
                            fullText: S.of(context).fullCheckNoPorn,
                            isDone: _todayCheck.noPorn,
                            onToggleDirect: () {
                              setState(() {
                                _todayCheck.noPorn = !_todayCheck.noPorn;
                              });
                              _saveTodayChecks();
                            },
                            onDialogChanged: (val) {
                              setState(() {
                                _todayCheck.noPorn = val;
                              });
                              _saveTodayChecks();
                            },
                          ),
                          // HEALTHY EATING
                          _buildDailyCheckShortItem(
                            shortLabel: S.of(context).shortCheckHealthyEating,
                            fullText: S.of(context).fullCheckHealthyEating,
                            isDone: _todayCheck.healthyEating,
                            onToggleDirect: () {
                              setState(() {
                                _todayCheck.healthyEating =
                                    !_todayCheck.healthyEating;
                              });
                              _saveTodayChecks();
                            },
                            onDialogChanged: (val) {
                              setState(() {
                                _todayCheck.healthyEating = val;
                              });
                              _saveTodayChecks();
                            },
                          ),
                          // HELP OTHERS
                          _buildDailyCheckShortItem(
                            shortLabel: S.of(context).shortCheckHelpOthers,
                            fullText: S.of(context).fullCheckHelpOthers,
                            isDone: _todayCheck.helpOthers,
                            onToggleDirect: () {
                              setState(() {
                                _todayCheck.helpOthers = !_todayCheck.helpOthers;
                              });
                              _saveTodayChecks();
                            },
                            onDialogChanged: (val) {
                              setState(() {
                                _todayCheck.helpOthers = val;
                              });
                              _saveTodayChecks();
                            },
                          ),
                          // NATURE
                          _buildDailyCheckShortItem(
                            shortLabel: S.of(context).shortCheckNature,
                            fullText: S.of(context).fullCheckNature,
                            isDone: _todayCheck.natureTime,
                            onToggleDirect: () {
                              setState(() {
                                _todayCheck.natureTime =
                                    !_todayCheck.natureTime;
                              });
                              _saveTodayChecks();
                            },
                            onDialogChanged: (val) {
                              setState(() {
                                _todayCheck.natureTime = val;
                              });
                              _saveTodayChecks();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ------------------------------------
              // MOTIVATION
              // ------------------------------------
              Card(
                color: Colors.grey[850],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _buildMotivationSection(),
                ),
              ),
              const SizedBox(height: 16),

              // ------------------------------------
              // TASKS & WEEKLY CHART
              // ------------------------------------
              ValueListenableBuilder(
                valueListenable: _dbService.listenableTasks(),
                builder: (context, taskBox, _) {
                  final tasks = _boxToTaskList(taskBox as Box);
                  final now = DateTime.now();

                  final todayTasks = tasks.where((t) => _isSameDay(t.deadline, now)).toList();
                  final totalTasks = todayTasks.length;
                  final doneTasks = todayTasks.where((t) => t.completed).length;
                  final tasksPercent = (totalTasks == 0) ? 0.0 : (doneTasks / totalTasks);

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

              // ------------------------------------
              // HABIT CHEER
              // ------------------------------------
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
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  DAILY CHECK: KURZES ITEM + DIREKTER ICON-TOGGLE
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildDailyCheckShortItem({
    required String shortLabel,
    required String fullText,
    required bool isDone,
    required VoidCallback onToggleDirect, 
    required ValueChanged<bool> onDialogChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // A) TEXT-Bereich => bei Tap => Dialog
          InkWell(
            onTap: () {
              _showCheckDialog(
                fullText: fullText,
                currentValue: isDone,
                onChanged: onDialogChanged,
              );
            },
            child: Text(
              shortLabel,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          // B) ICON => bei Tap => direkter Toggle
          GestureDetector(
            onTap: onToggleDirect,
            child: Icon(
              isDone ? Icons.check_circle : Icons.circle_outlined,
              color: isDone ? Colors.redAccent : Colors.grey[400],
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  DIALOG mit vollem Text + Switch
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Future<void> _showCheckDialog({
    required String fullText,
    required bool currentValue,
    required ValueChanged<bool> onChanged,
  }) async {
    bool tempVal = currentValue;
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(
                fullText,
                style: const TextStyle(color: Colors.white),
              ),
              content: Row(
                children: [
                  const Text("No", style: TextStyle(color: Colors.white)),
                  const Spacer(),
                  Switch(
                    value: tempVal,
                    activeColor: Colors.redAccent,
                    onChanged: (val) {
                      setStateDialog(() {
                        tempVal = val;
                      });
                    },
                  ),
                  const Spacer(),
                  const Text("Yes", style: TextStyle(color: Colors.white)),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
                  onPressed: () => Navigator.pop(ctx),
                ),
                TextButton(
                  child: const Text("OK", style: TextStyle(color: Colors.redAccent)),
                  onPressed: () {
                    onChanged(tempVal);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  Weekly Flow Time Card
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildWeeklyFlowTimeCard() {
    final value = _weeklyFlowSeconds ?? 0;
    final weeklyTimeHHMM = _formatWeeklyFlowTime(value);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FlowStatsPage()),
        );
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
              Text(
                weeklyTimeHHMM,
                style: const TextStyle(
                  fontFamily: 'Digital',
                  fontSize: 28,
                  color: Colors.redAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                S.of(context).productiveTimeWeek,
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  Streak Card
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
            Text(
              S.of(context).streak,
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  Flow Timer Card
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
              Text(
                S.of(context).flowTimer,
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  Motivation Section
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildMotivationSection() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            _randomImage,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _randomQuote,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'BebasNeue',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  void _pickRandomImage() {
    _randomImage = _motivationImages[Random().nextInt(_motivationImages.length)];
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  Today & Pie-Charts
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildTodayAndPieRow(double tasksPercent, List<Task> todayTasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTodaysTaskCard(todayTasks),
        const SizedBox(height: 16),
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
                  title: S.of(context).tasks,
                  size: 120,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final isPremium = Hive.box('settings').get('isPremium', defaultValue: false);
                  if (!isPremium) {
                    _showPaywallDialog();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HabitTrackerPage()),
                    );
                  }
                },
                child: _buildPieChart(
                  _calculateHabitsPercent(),
                  title: S.of(context).habits,
                  size: 120,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -----------------------------------------
  // HABIT PERCENT
  // -----------------------------------------
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

  // -----------------------------------------
  // PAYWALL
  // -----------------------------------------
  void _showPaywallDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(S.of(context).premiumRequired),
          content: Text(S.of(context).premiumSectionUnavailable),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(context).ok),
            ),
          ],
        );
      },
    );
  }

  // -----------------------------------------
  // TODAY TASKS
  // -----------------------------------------
  Widget _buildTodaysTaskCard(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Text(
            S.of(context).noTasksToday,
            style: const TextStyle(color: Colors.white),
          ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).todaysTasks,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.grey),
          ...tasks.map((task) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[700]?.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: ListTile(
                leading: IconButton(
                  icon: Icon(
                    task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: task.completed ? Colors.green : Colors.white,
                  ),
                  onPressed: () => _toggleTask(task),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    color: task.completed ? Colors.grey[400] : Colors.white,
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ToDoListPage()),
                  );
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // -----------------------------------------
  // PIE CHART
  // -----------------------------------------
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

  // -----------------------------------------
  // WEEKLY BAR CHART
  // -----------------------------------------
  Widget _buildWeeklyProgressChart(List<double> dailyPercents) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        Text(
          S.of(context).weeklyProgress,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
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

  // -----------------------------------------
  // CHEER MSG
  // -----------------------------------------
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
      return S.of(context).cheerPerfect;
    } else if (ratio >= 0.5) {
      return S.of(context).cheerHalf;
    } else if (ratio > 0.0) {
      return S.of(context).cheerAlmost;
    } else {
      return S.of(context).cheerStart;
    }
  }

  // -----------------------------------------
  // UTILS
  // -----------------------------------------
  /// z. B. 1800 Sek => "00:30"
  String _formatWeeklyFlowTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }

  /// FLOW-Sessions aus Box
  List<FlowSession> _boxToFlowSessions(Box<Map> box) {
    final List<FlowSession> result = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data == null) continue;
      final dateMs = data['date'] as int?;
      final mins = data['minutes'] as int?;
      if (dateMs == null || mins == null) continue;
      final dt = DateTime.fromMillisecondsSinceEpoch(dateMs);
      result.add(FlowSession(date: dt, minutes: mins));
    }
    return result;
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Tasks
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

  /// Habits
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

  /// z. B. "2025-02-06"
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Weekly Task-Fortschritte
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

  /// Task toggeln
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