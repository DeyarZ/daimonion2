// lib/onboarding/onboarding_goals.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../onboarding/onboarding_chatbot.dart';
import '../l10n/generated/l10n.dart';

class OnboardingGoalsPage extends StatefulWidget {
  const OnboardingGoalsPage({Key? key}) : super(key: key);

  @override
  State<OnboardingGoalsPage> createState() => _OnboardingGoalsPageState();
}

class _OnboardingGoalsPageState extends State<OnboardingGoalsPage> {
  List<String> _selectedGoals = [];

  // Statt einer konstanten Liste, definieren wir die verfügbaren Ziele dynamisch,
  // damit sie lokalisiert werden können.
  List<String> _availableGoals(BuildContext context) {
    final loc = S.of(context);
    return [
      loc.goalFit,
      loc.goalProductivity,
      loc.goalSaveMoney,
      loc.goalBetterRelationships,
      loc.goalMentalHealth,
      loc.goalCareer,
    ];
  }

  @override
  void initState() {
    super.initState();
    final settingsBox = Hive.box('settings');
    final existingGoals = settingsBox.get('userGoals', defaultValue: <String>[]);
    _selectedGoals = List<String>.from(existingGoals);
  }

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  void _goNext() {
    final settingsBox = Hive.box('settings');
    settingsBox.put('userGoals', _selectedGoals);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingChatbotPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final availableGoals = _availableGoals(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              loc.onboardingGoalsQuestion,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: availableGoals.length,
                itemBuilder: (context, index) {
                  final goal = availableGoals[index];
                  final isSelected = _selectedGoals.contains(goal);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isSelected ? Colors.red.shade50 : Colors.grey.shade200,
                    child: ListTile(
                      title: Text(
                        goal,
                        style: TextStyle(
                          color: isSelected ? const Color.fromARGB(255, 223, 27, 27) : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: Checkbox(
                        value: isSelected,
                        activeColor: const Color.fromARGB(255, 223, 27, 27),
                        onChanged: (_) => _toggleGoal(goal),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _goNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 14.0,
                ),
              ),
              child: Text(
                loc.continueButton,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
