import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'onboarding_todos.dart';

// Globale Notification-Plugin Instanz importieren
import '../main.dart';

class OnboardingNotificationPage extends StatefulWidget {
  const OnboardingNotificationPage({Key? key}) : super(key: key);

  @override
  State<OnboardingNotificationPage> createState() =>
      _OnboardingNotificationPageState();
}

class _OnboardingNotificationPageState
    extends State<OnboardingNotificationPage> {
  bool _permissionGranted = false;
  bool _permissionDenied = false;

  Future<void> _requestNotificationPermission() async {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      final iosPermission = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      setState(() {
        _permissionGranted = iosPermission ?? false;
        _permissionDenied = !(iosPermission ?? false);
      });

      Hive.box('settings').put('notificationsAllowed', _permissionGranted);
    } else {
      final status = await Permission.notification.request();

      setState(() {
        _permissionGranted = status.isGranted;
        _permissionDenied = !status.isGranted;
      });

      Hive.box('settings').put('notificationsAllowed', _permissionGranted);
    }
  }

  void _goNext() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingTodosPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Mach den ersten Schritt",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Stell dir vor, du wirst jeden Tag daran erinnert, besser zu sein als gestern. Deine Ziele, deine To-Dos, deine Disziplin – alles wird stärker, weil du es wirst. Schalte jetzt Benachrichtigungen ein und lass dich von deinem inneren Daimonion pushen.",
              style: TextStyle(fontSize: 18, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: _requestNotificationPermission,
              child: const Text(
                "Push mich!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_permissionGranted)
              const Text(
                "Benachrichtigungen sind jetzt aktiv! Lass uns loslegen.",
                style: TextStyle(color: Colors.green, fontSize: 16),
                textAlign: TextAlign.center,
              )
            else if (_permissionDenied)
              const Text(
                "Benachrichtigungen wurden abgelehnt. Du kannst sie später in den Einstellungen aktivieren.",
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: _goNext,
              child: const Text(
                "Weiter zur nächsten Challenge",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
