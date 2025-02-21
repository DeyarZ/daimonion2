// lib/pages/dashboard.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

// Google Mobile Ads
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Services & Pages (anpassen an deine Ordnerstruktur)
import '../services/db_service.dart';
import '../services/flow_timer_service.dart';
import '../pages/todo_list.dart';
import '../pages/habit_tracker.dart';
import 'flow_stats_page.dart';
import '../widgets/ad_wrapper.dart';
import 'streak_info_page.dart';  // <--- NEU: StreakInfoPage

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
    'assets/images/hustle_rari.png',
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

  // ------------------------------------------------
  // NEU: NativeAd
  // ------------------------------------------------
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;

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

    // Native Ad laden
    _loadNativeAd();
  }

  // Lädt die erweiterte native Anzeige
void _loadNativeAd() {
  _nativeAd = NativeAd(
    adUnitId: 'ca-app-pub-2524075415669673/6403722860', // Deine echte ID!
    factoryId: 'listTile',
    request: const AdRequest(),
    listener: NativeAdListener(
      onAdLoaded: (ad) {
        setState(() {
          _isNativeAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        debugPrint('⚠️ Native Ad konnte nicht geladen werden: ${error.message}');
      },
    ),
  );

  _nativeAd!.load();
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
    final totalFlowMinutes =
        filtered.fold<int>(0, (sum, fs) => sum + fs.minutes);
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Colors.grey.shade900,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Custom-AppBar
                Container(
                  height: 56,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Row(
                    children: [
                      Text(
                        S.of(context).dashboardTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Haupt-Scroll-Bereich
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // TOP-ROW (Flow, Streak, Timer)
                        Row(
                          children: [
                            Expanded(child: _buildWeeklyFlowTimeCard()),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStreakCard()),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildFlowTimerCard(isRunning, '$m:$s'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // FUNDAMENTALS
                        _buildFundamentalsSection(),
                        const SizedBox(height: 16),

                        // MOTIVATION
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _pickRandomImage();
                              final quotes =
                                  S.of(context).motivationQuotes.split('||');
                              _randomQuote =
                                  quotes[Random().nextInt(quotes.length)];
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF2A2A2A),
                                  const Color(0xFF1A1A1A),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  offset: const Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: _buildMotivationSection(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // // NEU: Native Ad Section
                        // _buildNativeAdSection(),

                        const SizedBox(height: 16),

                        // TASKS & WEEKLY CHART
                        ValueListenableBuilder(
                          valueListenable: _dbService.listenableTasks(),
                          builder: (context, taskBox, _) {
                            final tasks = _boxToTaskList(taskBox as Box);
                            final now = DateTime.now();

                            final todayTasks = tasks
                                .where((t) => _isSameDay(t.deadline, now))
                                .toList();
                            final totalTasks = todayTasks.length;
                            final doneTasks =
                                todayTasks.where((t) => t.completed).length;
                            final tasksPercent = (totalTasks == 0)
                                ? 0.0
                                : (doneTasks / totalTasks);

                            final dailyPercents =
                                _calculateWeeklyPercents(tasks);

                            return Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2A2A2A),
                                        Color(0xFF1A1A1A),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        offset: const Offset(0, 2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: _buildTodayAndPieRow(
                                      tasksPercent,
                                      todayTasks,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ToDoListPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2A2A2A),
                                          Color(0xFF1A1A1A),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black.withOpacity(0.4),
                                          offset: const Offset(0, 2),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child:
                                        _buildWeeklyProgressChart(dailyPercents),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // HABIT CHEER
                        ValueListenableBuilder(
                          valueListenable: _dbService.listenableHabits(),
                          builder: (context, habitBox, _) {
                            final habits = _boxToHabitList(habitBox as Box);
                            final cheer = _calculateCheerMessage(habits);
                            if (cheer == null) return const SizedBox();
                            return Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2A2A2A),
                                    Color(0xFF1A1A1A),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    offset: const Offset(0, 2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                cheer,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        ),
                      ],
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

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  FUNDAMENTALS: NEUE SECTION (Horizontal Scroller)
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildFundamentalsSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2A2A2A),
            Color(0xFF1A1A1A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Überschrift & kurze Erklärung
          Text(
            S.of(context).dailyFundamentalsTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Optional: Kurzbeschreibung, falls du in .arb .json hast
          // Text(
          //   S.of(context).dailyFundamentalsDescription,
          //   style: const TextStyle(color: Colors.white70, fontSize: 12),
          // ),
          // const SizedBox(height: 8),

          // Horizontal scroller mit den 6 Fundamentals
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFundamentalChip(
                  label: S.of(context).shortCheckGym,
                  explanation: S.of(context).fullCheckGym,
                  isDone: _todayCheck.gym,
                  onToggle: (val) {
                    setState(() => _todayCheck.gym = val);
                    _saveTodayChecks();
                  },
                  icon: Icons.fitness_center,
                ),
                _buildFundamentalChip(
                  label: S.of(context).shortCheckMental,
                  explanation: S.of(context).fullCheckMental,
                  isDone: _todayCheck.mental,
                  onToggle: (val) {
                    setState(() => _todayCheck.mental = val);
                    _saveTodayChecks();
                  },
                  icon: Icons.self_improvement,
                ),
                _buildFundamentalChip(
                  label: S.of(context).shortCheckNoPorn,
                  explanation: S.of(context).fullCheckNoPorn,
                  isDone: _todayCheck.noPorn,
                  onToggle: (val) {
                    setState(() => _todayCheck.noPorn = val);
                    _saveTodayChecks();
                  },
                  icon: Icons.block,
                ),
                _buildFundamentalChip(
                  label: S.of(context).shortCheckHealthyEating,
                  explanation: S.of(context).fullCheckHealthyEating,
                  isDone: _todayCheck.healthyEating,
                  onToggle: (val) {
                    setState(() => _todayCheck.healthyEating = val);
                    _saveTodayChecks();
                  },
                  icon: Icons.restaurant,
                ),
                _buildFundamentalChip(
                  label: S.of(context).shortCheckHelpOthers,
                  explanation: S.of(context).fullCheckHelpOthers,
                  isDone: _todayCheck.helpOthers,
                  onToggle: (val) {
                    setState(() => _todayCheck.helpOthers = val);
                    _saveTodayChecks();
                  },
                  icon: Icons.volunteer_activism,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  FUNDAMENTAL CHIP (Circle Toggle + Label + Info)
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildFundamentalChip({
    required String label,
    required String explanation,
    required bool isDone,
    required ValueChanged<bool> onToggle,
    required IconData icon,
  }) {
    final circleColor = isDone ? Colors.green : Colors.grey;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () => onToggle(!isDone),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              // Wichtig, damit nichts abgeschnitten wird:
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor.withOpacity(0.2),
                    border: Border.all(color: circleColor, width: 2),
                  ),
                  child: Icon(
                    isDone ? Icons.check : icon,
                    color: isDone ? Colors.green : Colors.white70,
                    size: 24,
                  ),
                ),
                // Den Info-Button knapp am Rand
                Positioned(
                  right: -5,
                  top: 0,
                  child: InkWell(
                    onTap: () {
                      // separate Info-Dialog
                      _showExplanationDialog(label, explanation);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.white70,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 60,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  Info-Dialog
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Future<void> _showExplanationDialog(String title, String explanation) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content:
              Text(explanation, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "OK",
                style: TextStyle(color: Color.fromARGB(255, 223, 27, 27)),
              ),
            ),
          ],
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

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FlowStatsPage()),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weeklyTimeHHMM,
                style: const TextStyle(
                  fontFamily: 'Digital',
                  fontSize: 28,
                  color: Color.fromARGB(255, 223, 27, 27),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                S.of(context).productiveTimeWeek,
                textAlign: TextAlign.center,
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
    return InkWell(
      onTap: _goToStreakInfo,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
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
                  color: Color.fromARGB(255, 223, 27, 27),
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
      ),
    );
  }

  void _goToStreakInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StreakInfoPage(streak: _streak)),
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
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
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
                    color: const Color.fromARGB(255, 223, 27, 27),
                    size: 24,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeString,
                    style: const TextStyle(
                      fontFamily: 'Digital',
                      fontSize: 28,
                      color: Color.fromARGB(255, 223, 27, 27),
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
  //  NativeAd Section
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildNativeAdSection() {
    // Wenn die Ad noch nicht geladen ist, einfach nix oder "Loading..."
    if (!_isNativeAdLoaded || _nativeAd == null) {
      return Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Upgrade to Premium for no ads',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    // Ad ist da => zeig sie
    return Container(
      alignment: Alignment.center,
      // Höhe anpassen je nach Layout
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: AdWidget(ad: _nativeAd!),
    );
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
              child: _buildPieChart(
                tasksPercent,
                title: S.of(context).tasks,
                size: 120,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ToDoListPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPieChart(
                _calculateHabitsPercent(),
                title: S.of(context).habits,
                size: 120,
                onTap: () {
                  final isPremium = Hive.box('settings')
                      .get('isPremium', defaultValue: false);
                  if (!isPremium) {
                    _showPaywallDialog();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HabitTrackerPage()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

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

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  Today’s Tasks
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildTodaysTaskCard(List<Task> tasks) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2A2A2A),
            Color(0xFF1A1A1A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: tasks.isEmpty
          ? Center(
              child: Text(
                S.of(context).noTasksToday,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).todaysTasks,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
                          task.completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
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
                          MaterialPageRoute(
                            builder: (_) => const ToDoListPage(),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  PIE CHART
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildPieChart(
    double completionPercent, {
    required String title,
    required double size,
    required VoidCallback onTap,
  }) {
    final percentage = (completionPercent * 100).toStringAsFixed(0);
    final primaryColor =
        (completionPercent >= 1.0) ? Colors.green : const Color.fromARGB(255, 223, 27, 27);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2A2A2A),
              Color(0xFF1A1A1A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
                          color: primaryColor,
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
                      style:
                          const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  WEEKLY BAR CHART
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
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
                              color: Colors.white, fontSize: 10),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              barGroups: List.generate(7, (index) {
                final val = dailyPercents[index];
                final barColor =
                    val >= 100.0 ? Colors.green : const Color.fromARGB(255, 223, 27, 27);
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: val,
                      color: barColor,
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

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  CHEER MSG
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  UTILS
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  String _formatWeeklyFlowTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }

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
      final tasksForDay =
          tasks.where((t) => _isSameDay(t.deadline, dayDate)).toList();
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
