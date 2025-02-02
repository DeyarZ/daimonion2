// lib/onboarding/onboarding_notification.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'onboarding_todos.dart';

// Globale Notification-Plugin Instanz importieren
import '../main.dart';
import '../l10n/generated/l10n.dart';

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
    final loc = S.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              loc.onboardingNotificationHeadline,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              loc.onboardingNotificationDescription,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
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
              child: Text(
                loc.onboardingNotificationButtonText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_permissionGranted)
              Text(
                loc.notificationActiveMessage,
                style: const TextStyle(color: Colors.green, fontSize: 16),
                textAlign: TextAlign.center,
              )
            else if (_permissionDenied)
              Text(
                loc.notificationDeniedMessage,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
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
              child: Text(
                loc.onboardingNotificationNextChallenge,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
