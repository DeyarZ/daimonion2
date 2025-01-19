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

// Services
import 'services/flow_timer_service.dart';
import 'services/db_service.dart';
import '../services/openai_service.dart';

// Pages
import 'pages/dashboard.dart';
import 'pages/chatbot.dart';
import 'pages/tools.dart';
import 'pages/profile.dart';

// Globale Notification-Plugin Instanz
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // AdMob initialisieren
  await MobileAds.instance.initialize();

  // Hive init
  await Hive.initFlutter();
  await Hive.openBox<Map>(DBService.tasksBoxName);
  await Hive.openBox<Map>(DBService.habitsBoxName);
  await Hive.openBox<Map>(DBService.journalBoxName);
  await Hive.openBox('settings');

  // ----------------------------------------------------------
  // RevenueCat konfigurieren
  // ----------------------------------------------------------
  final revenueCatApiKey = dotenv.env['REVENUECAT_API_KEY'];
  if (revenueCatApiKey == null) {
    throw Exception("RevenueCat API Key fehlt in der .env-Datei");
  }
  await Purchases.configure(PurchasesConfiguration(revenueCatApiKey));

  // Checken, ob User bereits Premium hat (Entitlements)
  try {
    final customerInfo = await Purchases.getCustomerInfo();
    final isPremium = customerInfo.entitlements.all['premium']?.isActive ?? false;
    if (isPremium) {
      Hive.box('settings').put('isPremium', true);
    }
  } catch (e) {
    debugPrint("Fehler beim Entitlement-Check: $e");
  }

  // ----------------------------------------------------------
  // STREAK handling
  // ----------------------------------------------------------
  final settingsBox = Hive.box('settings');
  final now = DateTime.now();
  final lastOpenedMillis = settingsBox.get('lastOpened', defaultValue: 0);

  if (lastOpenedMillis == 0) {
    // erster Start
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

  // ----------------------------------------------------------
  // Timezone + flutter_local_notifications initialisieren
  // ----------------------------------------------------------
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Berlin'));

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher'); 
      // Passe das an dein App-Icon an
  const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  // Notification-Klick-Handling (optional)
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) {
      debugPrint('Notification tapped: ${response.payload}');
      // Hier könntest du z.B. auf eine Page navigieren
    },
  );

  // ----------------------------------------------------------
  // App starten
  // ----------------------------------------------------------
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

// Die App-Klasse bleibt wie gehabt
class DaimonionApp extends StatelessWidget {
  const DaimonionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daimonion',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

// ----------------------------------------------------------
// MAIN SCREEN MIT BOTTOM NAV
// ----------------------------------------------------------
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

  // BannerAd-Instanz (AdMob)
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
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.white54,
        backgroundColor: Colors.grey[900],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Tools',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
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
}

// ----------------------------------------------------------
// Funktionen zum Scheduling und Canceln von Notifications
// ----------------------------------------------------------

/// Plant für jeden ausgewählten Wochentag eine weekly Notification.
/// Wird von habit_tracker.dart aufgerufen (wenn user Zeit angegeben hat).
Future<void> scheduleHabitNotifications({
  required String habitId,
  required String habitName,
  required int hour,
  required int minute,
  required Set<int> weekdays,
}) async {
  for (final wday in weekdays) {
    final notifId = habitId.hashCode + wday; 
    final scheduleTime = _nextInstanceOfWeekday(wday, hour, minute);

    const androidDetails = AndroidNotificationDetails(
      'habit_channel_id',
      'Habit Reminders',
      channelDescription: 'Erinnert dich an deine Habit',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // zonedSchedule => weekly
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notifId,
      'Habit Reminder',
      habitName,
      scheduleTime,
      details,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

/// Falls der user die Habit löscht, canceln wir die Notifications.
Future<void> cancelHabitNotifications(String habitId, Set<int> weekdays) async {
  for (final wday in weekdays) {
    final notifId = habitId.hashCode + wday;
    await flutterLocalNotificationsPlugin.cancel(notifId);
  }
}

// ----------------------------------------------------------
// Helper: nächste Instanz eines Wochentags berechnen
// ----------------------------------------------------------
tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);

  // Starte bei heute + (hour, minute)
  var scheduled = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );

  // Solange weekday nicht passt => +1 Tag
  while (scheduled.weekday != weekday) {
    scheduled = scheduled.add(const Duration(days: 1));
  }

  // Falls die Zeit heute schon vorbei => +7 Tage
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 7));
  }

  return scheduled;
}
