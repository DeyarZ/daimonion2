// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// NEU: Lokale Notifications + Timezone
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// NEU: Lokalisierung
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/l10n.dart';

// Dein Härtegrad-Enum (Pfad anpassen, wenn woanders)
import 'package:daimonion_app/haertegrad_enum.dart';

// Services (anpassen an deine Struktur)
import 'services/flow_timer_service.dart';
import 'services/db_service.dart';

// *** NEU: Gamification-Service importieren ***
import 'services/gamification_service.dart';

// Pages (anpassen an deine Struktur)
import 'pages/auth_gate.dart';
import 'pages/dashboard.dart';
import 'pages/chatbot.dart';
import 'pages/tools.dart';
import 'pages/profile.dart';

// Globale Notification-Plugin Instanz
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ----------------------------------------------------------
// CUSTOM SCROLL BEHAVIOR
// ----------------------------------------------------------
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Schwarze Overscroll-Farbe statt hellgrauem Glow
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: Colors.black,
      child: child,
    );
  }
}

// ----------------------------------------------------------
// 1) Timezone-Helfer-Funktion (Weekly Habit Reminder)
// ----------------------------------------------------------
tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  // Solange Wochentag nicht passt => +1 Tag
  while (scheduled.weekday != weekday) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  // Falls schon vorbei => +7 Tage
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 7));
  }
  return scheduled;
}

// ----------------------------------------------------------
// 2) Notifications: Weekly Habit Reminders
// ----------------------------------------------------------
Future<void> scheduleHabitNotifications({
  required String id,
  required String title,
  required List<int> weekdays,
  required int hour,
  required int minute,
}) async {
  for (final wday in weekdays) {
    final notifId = id.hashCode + wday;
    final scheduleTime = _nextInstanceOfWeekday(wday, hour, minute);

    final androidDetails = AndroidNotificationDetails(
      'habit_channel_id',
      S.current.habitReminderChannelName,
      channelDescription: S.current.habitReminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notifId,
      S.current.habitReminderTitle,
      title,
      scheduleTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

// Cancelt Notifications für alle Wochentage
Future<void> cancelHabitNotifications(String id) async {
  for (int wday = 1; wday <= 7; wday++) {
    final notifId = id.hashCode + wday;
    await flutterLocalNotificationsPlugin.cancel(notifId);
  }
}

// ----------------------------------------------------------
// 3) NEU: Täglicher Todo-Reminder um 20:00
// ----------------------------------------------------------
Haertegrad _getCurrentHaertegrad() {
  final settingsBox = Hive.box('settings');
  final modeString = settingsBox.get('chatbotMode', defaultValue: 'normal');
  switch (modeString) {
    case 'hart':
      return Haertegrad.hart;
    case 'brutalEhrlich':
      return Haertegrad.brutalEhrlich;
    default:
      return Haertegrad.normal;
  }
}

Map<String, String> _getTodoReminderText(Haertegrad grad) {
  switch (grad) {
    case Haertegrad.hart:
      return {
        'title': S.current.todoReminderTitleHard,
        'body': S.current.todoReminderBodyHard,
      };
    case Haertegrad.brutalEhrlich:
      return {
        'title': S.current.todoReminderTitleBrutal,
        'body': S.current.todoReminderBodyBrutal,
      };
    default:
      return {
        'title': S.current.todoReminderTitleNormal,
        'body': S.current.todoReminderBodyNormal,
      };
  }
}

Future<void> scheduleDailyTodoReminder() async {
  final grad = _getCurrentHaertegrad();
  final textMap = _getTodoReminderText(grad);

  final androidDetails = AndroidNotificationDetails(
    'daily_todo_channel',
    S.current.dailyTodoChannelName,
    channelDescription: S.current.dailyTodoChannelDesc,
    importance: Importance.high,
    priority: Priority.high,
  );
  const iosDetails = DarwinNotificationDetails();

  final details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  final now = tz.TZDateTime.now(tz.local);
  var scheduledTime = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    20, // 20:00
    0,
  );
  if (scheduledTime.isBefore(now)) {
    scheduledTime = scheduledTime.add(const Duration(days: 1));
  }

  const notificationId = 5678;

  await flutterLocalNotificationsPlugin.zonedSchedule(
    notificationId,
    textMap['title'],
    textMap['body'],
    scheduledTime,
    details,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    payload: 'dailyTodoPayload',
  );
}

Future<void> cancelDailyTodoReminder() async {
  const notificationId = 5678;
  await flutterLocalNotificationsPlugin.cancel(notificationId);
}

// ----------------------------------------------------------
// 4) Main-Funktion & App-Start
// ----------------------------------------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Env laden
  await dotenv.load(fileName: ".env");

  // AdMob initialisieren
  await MobileAds.instance.initialize();

  // OPTIONAL: Test-Device-IDs konfigurieren
  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: <String>[
        // 'ABCDEF012345' // Example
      ],
    ),
  );

  // Hive init
  await Hive.initFlutter();

  // *** NEU: Adapter für GamificationStats registrieren (falls du so was hast) ***
  Hive.registerAdapter(GamificationStatsAdapter());

  // *** NEU: GamificationService initialisieren ***
  await GamificationService().init();

  // ------------------------------------------------
  // *** Boxen öffnen – WICHTIG vor runApp() ***
  // ------------------------------------------------
  // Achte darauf, dass Boxnamen dem DBService entsprechen
  await Hive.openBox<Map>(DBService.tasksBoxName);
  await Hive.openBox<Map>(DBService.habitsBoxName);
  await Hive.openBox<Map>(DBService.journalBoxName);
  await Hive.openBox<Map>(DBService.flowSessionsBoxName);
  await Hive.openBox('settings'); // Falls du 'settingsBoxName' => openBox('settings') etc.
  await Hive.openBox('trainingPlanBox'); // Falls du den brauchst, wie in deinem Code

  // ------------------------------------------------
  // RevenueCat konfigurieren
  // ------------------------------------------------
  final revenueCatApiKey = dotenv.env['REVENUECAT_API_KEY'];
  if (revenueCatApiKey == null) {
    throw Exception("RevenueCat API Key fehlt in der .env-Datei");
  }
  await Purchases.configure(PurchasesConfiguration(revenueCatApiKey));

  try {
    final customerInfo = await Purchases.getCustomerInfo();
    final isPremium = customerInfo.entitlements.all['premium']?.isActive ?? false;
    if (isPremium) {
      Hive.box('settings').put('isPremium', true);
    }
  } catch (e) {
    debugPrint("Fehler beim Entitlement-Check: $e");
  }

  // Streak Logik (optional)
  final settingsBox = Hive.box('settings');
  final now = DateTime.now();
  final lastOpenedMillis = settingsBox.get('lastOpened', defaultValue: 0);

  if (lastOpenedMillis == 0) {
    settingsBox.put('streak', 1);
    settingsBox.put('lastOpened', now.millisecondsSinceEpoch);
  } else {
    final lastOpenedDate = DateTime.fromMillisecondsSinceEpoch(lastOpenedMillis);
    final differenceInDays = now.difference(lastOpenedDate).inDays;

    if (differenceInDays == 1) {
      final currentStreak = settingsBox.get('streak', defaultValue: 0);
      settingsBox.put('streak', currentStreak + 1);
      settingsBox.put('lastOpened', now.millisecondsSinceEpoch);
    } else if (differenceInDays > 1) {
      settingsBox.put('streak', 1);
      settingsBox.put('lastOpened', now.millisecondsSinceEpoch);
    }
  }

  // Timezone + flutter_local_notifications
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Berlin'));

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) {
      debugPrint('Notification tapped: ${response.payload}');
      // Hier könntest du zur Todo-Liste navigieren
    },
  );

  // runApp mit Providern
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FlowTimerService>(
          create: (_) => FlowTimerService(),
        ),
      ],
      child: const DaimonionApp(),
    ),
  );
}

class DaimonionApp extends StatelessWidget {
  const DaimonionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daimonion',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      debugShowCheckedModeBanner: false,
      // Lokalisierung
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      scrollBehavior: MyCustomScrollBehavior(),
      home: const AuthGate(), // Dein Start-Widget
    );
  }
}

// Haupt-Screen mit BottomNav oder so
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const DashboardPage(),
    const ChatbotPage(),
    ToolsPage(),
    const ProfilePage(),
  ];

  // BannerAd (AdMob)
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2524075415669673/5094652840',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        color: Colors.black,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(iconPath: 'assets/icon/home.png', index: 0),
                _buildNavItem(iconPath: 'assets/icon/chat.png', index: 1),
                _buildNavItem(iconPath: 'assets/icon/tools.png', index: 2),
                _buildNavItem(iconPath: 'assets/icon/profile.png', index: 3),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _isAdLoaded
          ? Container(
              alignment: Alignment.center,
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            )
          : null,
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageIcon(
            AssetImage(iconPath),
            size: 32,
            color: isSelected
                ? const Color.fromARGB(255, 223, 27, 27)
                : Colors.white54,
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 28,
              color: const Color.fromARGB(255, 223, 27, 27),
            ),
        ],
      ),
    );
  }
}
