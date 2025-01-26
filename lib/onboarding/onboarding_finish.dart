import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../onboarding/onboarding_name.dart'; 
import '../onboarding/onboarding_age.dart'; 
import '../onboarding/onboarding_chatbot.dart'; 
import '../onboarding/onboarding_finish.dart'; 
import '../onboarding/onboarding_goals.dart'; 
import '../onboarding/onboarding_todos.dart'; 

import '../main.dart';

class OnboardingFinishPage extends StatelessWidget {
  const OnboardingFinishPage({Key? key}) : super(key: key);

  void _finishOnboarding(BuildContext context) {
    final settingsBox = Hive.box('settings');
    settingsBox.put('hasLaunched', true);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black.withOpacity(0.7),
          ),
          // Inhalt
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'DU HAST ES GESCHAFFT!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Jetzt beginnt der wahre Grind. Du bist bereit, die Kontrolle zu übernehmen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => _finishOnboarding(context),
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
                    child: const Text(
                      'LET’S GO ZUM DASHBOARD!',
                      style: TextStyle(
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
