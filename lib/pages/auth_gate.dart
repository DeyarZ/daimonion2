import 'package:daimonion_app/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Firebase & AuthService fliegt raus:
// import 'package:firebase_auth/firebase_auth.dart';
// import '/services/auth_service.dart';
// import 'login_page.dart';
// import 'dashboard.dart';

import 'first_time_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _firstLaunch;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  // Prüfen, ob "firstLaunch" in SharedPrefs noch nicht gesetzt ist
  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('hasLaunched') ?? false;
    if (!seen) {
      // Erstmals => wir zeigen "FirstTimePage"
      setState(() {
        _firstLaunch = true;
      });
    } else {
      setState(() {
        _firstLaunch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Falls wir firstLaunch noch nicht kennen => Ladebildschirm
    if (_firstLaunch == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Falls firstLaunch => FirstTimePage
    if (_firstLaunch == true) {
      return FirstTimePage(
        onFinish: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('hasLaunched', true);
          setState(() {
            _firstLaunch = false;
          });
        },
      );
    }

    // Ansonsten direkt MainScreen
    return const MainScreen();
  }
}
