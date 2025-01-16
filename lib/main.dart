// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMob-Import

// Services
import 'services/flow_timer_service.dart';

// Pages
import 'pages/dashboard.dart';
import 'pages/chatbot.dart';
import 'pages/tools.dart';
import 'pages/profile.dart';
import 'services/db_service.dart';
import '../services/openai_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // AdMob initialisieren
  await MobileAds.instance.initialize(); // <- AdMob SDK initialisieren

  await Hive.initFlutter();
  // Hier öffnest du deine Boxen
  await Hive.openBox<Map>(DBService.tasksBoxName);
  await Hive.openBox<Map>(DBService.habitsBoxName);
  await Hive.openBox<Map>(DBService.journalBoxName);
  // + ggf. 'settings' Box zum Speichern von streak
  await Hive.openBox('settings');

  // STREAK: check, ob der User heute schon drin war
  final settingsBox = Hive.box('settings');
  final now = DateTime.now();
  final lastOpenedMillis = settingsBox.get('lastOpened', defaultValue: 0);

  if (lastOpenedMillis == 0) {
    // Erster App-Start ever
    settingsBox.put('streak', 1);
    settingsBox.put('lastOpened', now.millisecondsSinceEpoch);
  } else {
    final lastOpenedDate = DateTime.fromMillisecondsSinceEpoch(lastOpenedMillis);
    final differenceInDays = now.difference(lastOpenedDate).inDays;

    if (differenceInDays == 0) {
      // Heute schon eingeloggt => kein Update
    } else if (differenceInDays == 1) {
      // Gestern => streak++
      final currentStreak = settingsBox.get('streak', defaultValue: 0);
      settingsBox.put('streak', currentStreak + 1);
      settingsBox.put('lastOpened', now.millisecondsSinceEpoch);
    } else {
      // Länger als 1 Tag => reset
      settingsBox.put('streak', 1);
      settingsBox.put('lastOpened', now.millisecondsSinceEpoch);
    }
  }

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
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

// ------------------------------------------
// MAIN SCREEN MIT BOTTOM NAV
// ------------------------------------------
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
    ToolsPage(), // 'const' entfernt
    const ProfilePage(),
  ];

  // BannerAd-Instanz (AdMob)
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd(); // Banner-Ad laden
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2524075415669673~7860955987', // <- DERZEIT TEST
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
  void dispose() {
    _bannerAd.dispose(); // Ad-Objekt sauber entfernen
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
      // Banner-Ad am unteren Rand anzeigen
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
