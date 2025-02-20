// lib/pages/gamification_page.dart

import 'package:flutter/material.dart';
import '../services/gamification_service.dart';
import '../l10n/generated/l10n.dart';
import 'gamification_info_page.dart';

class GamificationPage extends StatelessWidget {
  const GamificationPage({Key? key}) : super(key: key);

  // Badge-FileName => "Rekrut" => "assets/badges/rekrut.png"
  String _badgeAssetForStatus(String status) {
    final fileName = status.toLowerCase().replaceAll(' ', '_');
    return 'assets/badges/$fileName.png';
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final gamification = GamificationService();

    final currentXP = gamification.currentXP;
    final currentLevel = gamification.currentLevel;
    final currentStatus = gamification.currentStatus;

    final nextLevel = currentLevel + 1;
    final currentThreshold = gamification.getXPNeededForLevel(currentLevel);
    final nextThreshold = gamification.getXPNeededForLevel(nextLevel);
    final xpToNextLevel =
        (nextThreshold - currentThreshold).clamp(1, double.infinity);
    final xpProgress = (currentXP - currentThreshold).clamp(0, xpToNextLevel);
    final progressPercent = xpProgress / xpToNextLevel;

    // Lade die Badge-Datei
    final badgePath = _badgeAssetForStatus(currentStatus);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.title_progress),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // -----------------------------------------
                // Badge (nicht rund ausgeschnitten)
                // -----------------------------------------
                SizedBox(
                  height: 180,
                  child: Image.asset(
                    badgePath,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) {
                      // Fallback
                      return Image.asset('assets/badges/rekrut.png',
                          fit: BoxFit.contain);
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Mini-Text, optional z.B. "Du bist: ... Status"
                Text(
                  loc.status_text(currentStatus),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                // -----------------------------------------
                // Container mit Level, XP-Balken, etc.
                // -----------------------------------------
                InkWell(
                  onTap: () {
                    // Rufe Info auf
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GamificationInfoPage(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Column(
                      children: [
                        // Level
                        Text(
                          loc.level_text(currentLevel.toString()),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // XP-Bar
                        Stack(
                          children: [
                            Container(
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return Container(
                                  height: 22,
                                  width: constraints.maxWidth *
                                      progressPercent.clamp(0.0, 1.0),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.redAccent, Colors.orange],
                                    ),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // "XY% bis L Next"
                        Text(
                          loc.progress_text(
                            (progressPercent * 100).toStringAsFixed(0),
                            nextLevel.toString(),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // "XP a.bis/c. gesamt"
                        Text(
                          loc.xp_text(
                            xpProgress.toStringAsFixed(0),
                            xpToNextLevel.toStringAsFixed(0),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // -----------------------------------------
                // Optionaler Motivations-Text
                // -----------------------------------------
                Text(
                  loc.motivation_text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
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