import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Lokale Imports
import '../services/db_service.dart';
import '../services/flow_timer_service.dart';
import '../widgets/ad_wrapper.dart';
import '../l10n/generated/l10n.dart';
// Importiere das Datenmodell mit Alias, damit wir die richtige Task nutzen:
import '../models/data_models.dart' as models;
// Importiere todo_list.dart und blende die dortige Task-Klasse aus:
import 'todo_list.dart' hide Task;
import 'flow_stats_page.dart';
import 'habit_tracker.dart';
import 'streak_info_page.dart';
import 'subscription_page.dart';
import 'native_ad_section.dart';

// Import der ausgelagerten Widgets:
import 'motivation_banner.dart';
import 'stats_row.dart';
import 'fundamentals_section.dart';
import 'tasks_section.dart';
import 'weekly_progress_section.dart';
import '../utils/dashboard_utils.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final DBService _dbService = DBService();
  final Uuid _uuid = const Uuid();

  // State Variablen
  int _streak = 0;
  List<DateTime> _weekDates = [];
  int? _weeklyFlowSeconds;
  // Verwende models.DailyCheckModel aus den Datenmodellen
  models.DailyCheckModel _todayCheck = models.DailyCheckModel(date: DateTime.now());
  late AnimationController _animationController;
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _initWeekDates();
    _loadStreakFromHive();
    _loadWeeklyFlowSeconds();
    _loadTodayChecks().then((_) => _handleNewDayAndScheduleInsult());

    // Nur laden, wenn der User kein Premium hat
    final isPremium = Hive.box('settings').get('isPremium', defaultValue: false);
    if (!isPremium) {
      _loadNativeAd();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }

  void _initWeekDates() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    _weekDates = [];
    for (int i = 1; i <= 7; i++) {
      final date = now.subtract(Duration(days: dayOfWeek - i));
      _weekDates.add(date);
    }
  }

  void _loadStreakFromHive() {
    setState(() {
      _streak = Hive.box('settings').get('streak', defaultValue: 0);
    });
  }

  Future<void> _loadWeeklyFlowSeconds() async {
    final weekSeconds =
        await _dbService.getWeeklyFlowSeconds(_weekDates.first, _weekDates.last);
    setState(() => _weeklyFlowSeconds = weekSeconds);
  }

  Future<void> _loadTodayChecks() async {
    final today = DateTime.now();
    final check = await _dbService.getTodayCheck(today);
    setState(() {
      _todayCheck = check ?? models.DailyCheckModel(date: today);
    });
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-2524075415669673/6403722860',
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() => _isNativeAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Native Ad Error: ${error.message}');
        },
      ),
    );
    _nativeAd!.load();
  }

  void _saveTodayChecks() async {
    await _dbService.saveDailyCheck(_todayCheck);
    _checkAndUpdateStreak();
  }

  void _checkAndUpdateStreak() {
    if (_todayCheck.allCompleted()) {
      _dbService.markDateAsCompleted(_todayCheck.date);
      _loadStreakFromHive();
    }
  }

  void _handleNewDayAndScheduleInsult() {
    final lastOpenDate = Hive.box('settings').get('lastOpenDate');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (lastOpenDate == null) {
      Hive.box('settings').put('lastOpenDate', today.toString());
      return;
    }
    final lastDate = DateTime.parse(lastOpenDate);
    if (!isSameDay(lastDate, today)) {
      final random = Random().nextInt(100);
      if (random < 30) {
        Future.delayed(const Duration(minutes: 2), () {
          if (mounted) {
            _showMotivationalInsult();
          }
        });
      }
    }
    Hive.box('settings').put('lastOpenDate', today.toString());
  }

  void _showMotivationalInsult() {
    final motivations = S.of(context).motivationalInsults.split('||');
    final randomMotivation = motivations[Random().nextInt(motivations.length)];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color.fromARGB(255, 223, 27, 27),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              randomMotivation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(S.of(context).iWillDoIt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Callback für FundamentalsSection, um Änderungen zu speichern
  void _onFundamentalToggle(String key, bool value) {
    setState(() {
      switch (key) {
        case 'gym':
          _todayCheck.gym = value;
          break;
        case 'mental':
          _todayCheck.mental = value;
          break;
        case 'noPorn':
          _todayCheck.noPorn = value;
          break;
        case 'healthyEating':
          _todayCheck.healthyEating = value;
          break;
        case 'helpOthers':
          _todayCheck.helpOthers = value;
          break;
      }
    });
    _saveTodayChecks();
  }

  // Callback für Explanation Dialog aus FundamentalsSection
  void _showExplanationDialog(String title, String explanation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF212121),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                explanation,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(S.of(context).understood),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Callback für Task Toggle – nutze models.Task
  void _toggleTask(models.Task task) async {
    final box = await Hive.openBox<Map>(DBService.tasksBoxName);
    final tasks = box.values.toList();
    final index = tasks.indexWhere((element) => element['id'] == task.id);
    if (index == -1) return;
    task.completed = !task.completed;
    final updatedData = {
      'id': task.id,
      'title': task.title,
      'completed': task.completed,
      'deadline': task.deadline.millisecondsSinceEpoch,
      'description': task.description,
      'priority': task.priority,
    };
    await _dbService.updateTask(index, updatedData);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final flowTimer = context.watch<FlowTimerService>();
    // Hole Premium-Status
    final isPremium = Hive.box('settings').get('isPremium', defaultValue: false);
    final isRunning = flowTimer.isRunning;
    final secondsLeft = flowTimer.secondsLeft;
    final m = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (secondsLeft % 60).toString().padLeft(2, '0');
    final timeString = '$m:$s';

    return AdWrapper(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF121212), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Eigene AppBar
                _buildAppBar(),
                Expanded(
                  child: FadeTransition(
                    opacity: _animationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOutQuart,
                        ),
                      ),
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await _loadTodayChecks();
                          await _loadWeeklyFlowSeconds();
                          setState(() {});
                        },
                        color: const Color.fromARGB(255, 223, 27, 27),
                        backgroundColor: const Color(0xFF2A2A2A),
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            // SliverPadding um den unteren SafeArea-Bereich zu berücksichtigen
                            SliverPadding(
                              padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).padding.bottom),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    const MotivationBanner(),
                                    const SizedBox(height: 24),
                                    StatsRow(
                                      isRunning: isRunning,
                                      timeString: timeString,
                                      streak: _streak,
                                      weeklyFlowTime: formatWeeklyFlowTime(_weeklyFlowSeconds),
                                      onStreakTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => StreakInfoPage(streak: _streak),
                                          ),
                                        );
                                      },
                                      onProductiveTimeTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const FlowStatsPage(),
                                          ),
                                        );
                                      },
                                      onFlowTimerTap: () {
                                        HapticFeedback.mediumImpact();
                                        if (isRunning) {
                                          flowTimer.pauseTimer();
                                        } else {
                                          flowTimer.startTimer();
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    FundamentalsSection(
                                      todayCheck: _todayCheck,
                                      onToggle: _onFundamentalToggle,
                                      onExplanation: _showExplanationDialog,
                                    ),
                                    const SizedBox(height: 24),
                                    TasksSection(
                                      dbService: _dbService,
                                      toggleTask: _toggleTask,
                                    ),
                                    const SizedBox(height: 24),
                                    // Nur anzeigen, wenn der User kein Premium hat
                                    if (!isPremium) ...[
                                      NativeAdSection(
                                        nativeAd: _nativeAd,
                                        isNativeAdLoaded: _isNativeAdLoaded,
                                        onGoPremium: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const SubscriptionPage(),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                    WeeklyProgressSection(
                                      weekDates: _weekDates,
                                      dbService: _dbService,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Neues Icon statt des ursprünglichen Emojis
          const Icon(
            Icons.trending_up,
            color: Color.fromARGB(255, 223, 27, 27),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              S.of(context).dashboardTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
