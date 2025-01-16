import 'package:flutter/material.dart';

class FirstTimePage extends StatelessWidget {
  final VoidCallback onFinish;
  const FirstTimePage({Key? key, required this.onFinish}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Du hast im Screenshot ein Hintergrundbild + Text + Roten Button
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Hintergrundbild
          Image.asset(
            'assets/images/first_time_bg.jpg', // z.B. dein Bild
            fit: BoxFit.cover,
          ),
          // Dämmerung
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Inhalt
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'WILLST DU JEMAND SEIN, DER KONTROLLE HAT,\nODER WILLST DU EIN SKLAVE DEINER IMPULSE BLEIBEN?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                  ),
                  onPressed: onFinish,
                  child: const Text(
                    'ICH BIN BEREIT',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
