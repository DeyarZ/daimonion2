import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../onboarding/onboarding_name.dart'; 
import '../onboarding/onboarding_age.dart'; 
import '../onboarding/onboarding_chatbot.dart'; 
import '../onboarding/onboarding_finish.dart'; 
import '../onboarding/onboarding_goals.dart'; 
import '../onboarding/onboarding_todos.dart'; 

class OnboardingNamePage extends StatefulWidget {
  const OnboardingNamePage({Key? key}) : super(key: key);

  @override
  State<OnboardingNamePage> createState() => _OnboardingNamePageState();
}

class _OnboardingNamePageState extends State<OnboardingNamePage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Evtl. vorhandenen Namen vorbefüllen:
    final settingsBox = Hive.box('settings');
    final existingName = settingsBox.get('userName', defaultValue: '');
    _nameController.text = existingName;
  }

  void _goNext() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final settingsBox = Hive.box('settings');
      settingsBox.put('userName', name);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingAgePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bitte gib deinen Namen ein.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Wie heißt du?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Dein Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _goNext,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                    ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 14.0,
                  ),
                ),
                child: const Text(
                  "Weiter",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

