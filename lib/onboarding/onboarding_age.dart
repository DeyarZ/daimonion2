// lib/onboarding/onboarding_age.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/cupertino.dart';
import '../l10n/generated/l10n.dart';
import '../onboarding/onboarding_goals.dart';

class OnboardingAgePage extends StatefulWidget {
  const OnboardingAgePage({Key? key}) : super(key: key);

  @override
  State<OnboardingAgePage> createState() => _OnboardingAgePageState();
}

class _OnboardingAgePageState extends State<OnboardingAgePage> {
  int _selectedAge = 18;

  @override
  void initState() {
    super.initState();
    final settingsBox = Hive.box('settings');
    final existingAge = settingsBox.get('userAge', defaultValue: 18);
    _selectedAge = existingAge;
  }

  void _goNext() {
    final settingsBox = Hive.box('settings');
    settingsBox.put('userAge', _selectedAge);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingGoalsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                loc.onboardingAgeQuestion,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: _selectedAge - 1),
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedAge = index + 1;
                    });
                  },
                  children: List<Widget>.generate(100, (int index) {
                    return Center(
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }),
                ),
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
                child: Text(
                  loc.continueButton,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
