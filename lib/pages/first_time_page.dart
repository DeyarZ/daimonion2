// lib/pages/first_time_page.dart

import 'package:flutter/material.dart';
import '../onboarding/onboarding_name.dart';
import '../onboarding/onboarding_age.dart';
import '../onboarding/onboarding_chatbot.dart';
import '../onboarding/onboarding_finish.dart';
import '../onboarding/onboarding_goals.dart';
import '../onboarding/onboarding_todos.dart';
import '../l10n/generated/l10n.dart'; // Lokalisierung importieren

class FirstTimePage extends StatelessWidget {
  final VoidCallback onFinish; // Callback vom AuthGate
  const FirstTimePage({Key? key, required this.onFinish}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Hintergrundbild
          Image.asset(
            'assets/images/first_time_bg.jpg',
            fit: BoxFit.cover,
          ),
          // Abdunkeln
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          // Inhalt
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loc.firstTimeHeadline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OnboardingNamePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 16.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      loc.firstTimeButtonText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
