import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';          // <-- Nur für MainScreen-Import. Pfad anpassen!
import 'first_time_page.dart'; // <-- Pfad anpassen, falls nötig

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

  Future<void> _checkFirstLaunch() async {
    final settingsBox = Hive.box('settings');
    // "hasLaunched" könnte bool sein, default: false
    final hasLaunched = settingsBox.get('hasLaunched', defaultValue: false) as bool;

    setState(() {
      _firstLaunch = !hasLaunched; 
      // Wenn hasLaunched = false => _firstLaunch = true => Onboarding
      // Wenn hasLaunched = true  => _firstLaunch = false => MainScreen
    });
  }

  // Wird aufgerufen, wenn User auf "Ich bin bereit" drückt
  void _finishOnboarding() {
    final settingsBox = Hive.box('settings');
    settingsBox.put('hasLaunched', true);

    setState(() {
      _firstLaunch = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Laden wir noch? Dann Circle Progress
    if (_firstLaunch == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Ist es der erste Start => "FirstTimePage" anzeigen
    if (_firstLaunch == true) {
      return FirstTimePage(
        onFinish: _finishOnboarding, // Button-Klick => Onboarding fertig
      );
    }

    // Ansonsten direkt ins MainScreen
    return const MainScreen();
  }
}
