import 'package:flutter/material.dart';
import 'package:daimonion_app/l10n/generated/l10n.dart';

class StreakInfoPage extends StatelessWidget {
  final int streak;
  const StreakInfoPage({Key? key, required this.streak}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context); // Sicherstellen, dass Lokalisierung geladen ist
    if (loc == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Berechnung des XP-Multiplikators
    const double baseRate = 0.01; // +1% pro Streak-Tag
    const double maxMultiplier = 2.0;
    double multiplier = 1.0 + baseRate * (streak - 1);
    multiplier = multiplier.clamp(1.0, maxMultiplier);
    final bonusPercent = ((multiplier - 1.0) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.streak_info_title),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade800,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 223, 27, 27)
                            .withOpacity(0.7),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    size: 60,
                    color: Color.fromARGB(255, 223, 27, 27),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  loc.streak_days(streak),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 223, 27, 27),
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  color: Colors.grey.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.xp_bonus(bonusPercent),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          loc.streak_description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          loc.streak_rewards,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 24),
                  label: Text(
                    loc.back_button,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
