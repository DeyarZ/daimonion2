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
  String _chosenMode = 'normal'; // default
  String _warningMessage = '';

  @override
  void initState() {
    super.initState();
    final settingsBox = Hive.box('settings');
    final existingMode = settingsBox.get('chatbotMode', defaultValue: 'normal');
    _chosenMode = existingMode;
  }

  void _goNext() {
    final settingsBox = Hive.box('settings');
    settingsBox.put('chatbotMode', _chosenMode);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingNotificationPage()),
    );
  }

  Widget _buildModeButton(String mode, String label, Color activeColor) {
    final isSelected = _chosenMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _chosenMode = mode;
          _warningMessage = mode == 'brutalEhrlich'
              ? S.of(context).chatbotWarning
              : '';
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              loc.onboardingChatbotTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildModeButton('normal', loc.chatbotModeNormal, Colors.blue),
            _buildModeButton('hart', loc.chatbotModeHard, Colors.blue),
            _buildModeButton('brutalEhrlich', loc.chatbotModeBrutal, Colors.red),
            if (_warningMessage.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                _warningMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const Spacer(),
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
    );
  }
}
