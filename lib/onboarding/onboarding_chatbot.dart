// lib/onboarding/onboarding_chatbot.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../onboarding/onboarding_notification.dart';
import '../l10n/generated/l10n.dart';

class OnboardingChatbotPage extends StatefulWidget {
  const OnboardingChatbotPage({Key? key}) : super(key: key);

  @override
  State<OnboardingChatbotPage> createState() => _OnboardingChatbotPageState();
}

class _OnboardingChatbotPageState extends State<OnboardingChatbotPage> {
  // Statt Strings wie 'normal' speichern wir hier direkt den Index 0=normal, 1=hart, 2=brutal
  int _chosenIndex = 0; // default = normal
  String _warningMessage = '';

  @override
  void initState() {
    super.initState();
    final settingsBox = Hive.box('settings');
    // Falls 'haertegrad' existiert => einlesen, sonst 0 (normal)
    final existingIndex = settingsBox.get('haertegrad', defaultValue: 0) as int;
    _chosenIndex = existingIndex.clamp(0, 2);
  }

  void _selectMode(int idx) {
    setState(() {
      _chosenIndex = idx;
      _warningMessage = (idx == 2)
          ? S.of(context).chatbotWarning // z. B. "Vorsicht, brutal ehrlich"
          : '';
    });
  }

  void _goNext() {
    final settingsBox = Hive.box('settings');
    settingsBox.put('haertegrad', _chosenIndex); // Speichern => 0,1,2

    // Weiter zur nächsten Onboarding-Seite
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const OnboardingNotificationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      // Dunkler Gradient-Hintergrund
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  loc.onboardingChatbotTitle, // z. B. "Wähle deine Chat-Einstellung"
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // 3 Buttons: normal/hart/brutal
                _buildModeButton(0, loc.chatbotModeNormal, Colors.blue),
                _buildModeButton(1, loc.chatbotModeHard, Colors.blue),
                _buildModeButton(2, loc.chatbotModeBrutal,
                    const Color.fromARGB(255, 223, 27, 27)),

                if (_warningMessage.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    _warningMessage,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 223, 27, 27),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const Spacer(),

                // Weiter-Button
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Baut einen Button, der den Index idx setzt
  Widget _buildModeButton(int idx, String label, Color activeColor) {
    final isSelected = (_chosenIndex == idx);
    return GestureDetector(
      onTap: () => _selectMode(idx),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade600,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
