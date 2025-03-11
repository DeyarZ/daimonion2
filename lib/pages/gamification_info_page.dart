import 'package:flutter/material.dart';
import 'package:daimonion_app/l10n/generated/l10n.dart';
import 'dart:ui';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:daimonion_app/services/gamification_service.dart';

class GamificationInfoPage extends StatelessWidget {
  const GamificationInfoPage({Key? key}) : super(key: key);

  // Brand color constants
  static const Color primaryRed = Color(0xFFDF1B1B);
  static const Color darkBackground = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color accentColor = Color(0xFF2A2A2A);

  // Badge path helper
  String _badgePathForRank(String rank) {
    final filename = rank.toLowerCase().replaceAll(" ", "_");
    return 'assets/badges/$filename.png';
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final screenSize = MediaQuery.of(context).size;

    return ValueListenableBuilder<Box<GamificationStats>>(
      valueListenable: Hive.box<GamificationStats>('gamificationBox').listenable(),
      builder: (context, box, child) {
        if (box.isEmpty) {
          return Scaffold(
            backgroundColor: darkBackground,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Dynamische Gamification-Werte aus dem Service
        final gamificationService = GamificationService();
        final currentXP = gamificationService.currentXP;
        final currentLevel = gamificationService.currentLevel;
        final currentStatus = gamificationService.currentStatus;
        final nextLevelXP = gamificationService.getXPNeededForLevel(currentLevel + 1);
        final xpNeeded = nextLevelXP - currentXP;
        final progressPercent = gamificationService.levelProgress;

        return Scaffold(
          backgroundColor: darkBackground,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              loc.levels_and_rankings,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [darkBackground, Color(0xFF1A1A1A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Background subtle graphic elements
                  Positioned(
                    top: -50,
                    right: -100,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryRed.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -80,
                    left: -80,
                    child: Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryRed.withOpacity(0.08),
                      ),
                    ),
                  ),
                  // Main content
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Column(
                        children: [
                          // Dynamischer Header
                          _buildHeader(
                            loc,
                            currentLevel,
                            currentStatus,
                            currentXP,
                            nextLevelXP,
                            progressPercent,
                            xpNeeded,
                          ),
                          // XP Section – Overflow-Fix: Expanded im Titel
                          _buildSectionTitle(loc.how_to_earn_xp),
                          _buildXpCards(loc, screenSize),
                          const SizedBox(height: 24),
                          // Levels Section – nur Levels, wenn sich der Rang ändert
                          _buildSectionTitle(loc.levels_and_ranks),
                          _buildLevelsList(loc, context, currentLevel),
                          const SizedBox(height: 36),
                          // Motivational quote
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: cardBackground.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: primaryRed.withOpacity(0.3), width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_fire_department, color: primaryRed, size: 32),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    loc.keep_grinding,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomBar(context, loc),
        );
      },
    );
  }

  // Dynamischer Header mit aktuellem Fortschritt
  Widget _buildHeader(
    S loc,
    int currentLevel,
    String currentStatus,
    int currentXP,
    int nextLevelXP,
    double progressPercent,
    int xpNeeded,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryRed.withOpacity(0.8), primaryRed.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryRed.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Dynamisches Level-Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  _badgePathForRank(currentStatus),
                  width: 50,
                  height: 50,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Level $currentLevel",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentStatus,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "XP: $currentXP/$nextLevelXP",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "${(progressPercent * 100).round()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 10,
                  backgroundColor: Colors.black26,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$xpNeeded XP to next level",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Fix: Section Title in Expanded, damit der Text nicht überläuft
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: primaryRed,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpCards(S loc, Size screenSize) {
    final List<Map<String, dynamic>> xpActions = [
      {
        'action': loc.complete_todo,
        'xp': '1',
        'max': '5',
        'icon': Icons.task_alt,
      },
      {
        'action': loc.complete_habit,
        'xp': '1',
        'max': '5',
        'icon': Icons.repeat,
      },
      {
        'action': loc.journal_entry,
        'xp': '2',
        'max': '2',
        'icon': Icons.book,
      },
      {
        'action': loc.ten_min_flow,
        'xp': '1',
        'max': '-',
        'icon': Icons.timer,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenSize.width > 500 ? 4 : 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: xpActions.length,
      itemBuilder: (context, index) {
        final item = xpActions[index];
        return Container(
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item['icon'],
                color: primaryRed,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                item['action'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${item['xp']} XP",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  if (item['max'] != '-')
                    Text(
                      " · Max ${item['max']}/day",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Dynamische Levels-Liste: Nur die Einträge, bei denen sich der Rang ändert
  Widget _buildLevelsList(S loc, BuildContext context, int currentLevel) {
    // Filtere levelTable, um nur die erste Instanz jedes Status zu erhalten
    final distinctLevels = <LevelThreshold>[];
    for (var threshold in levelTable) {
      if (distinctLevels.isEmpty || distinctLevels.last.status != threshold.status) {
        distinctLevels.add(threshold);
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: cardBackground.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        loc.level,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        loc.rank,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        loc.badge,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: distinctLevels.length,
                itemBuilder: (context, index) {
                  final threshold = distinctLevels[index];
                  // Highlight current level row if the currentLevel is >= this threshold level
                  final bool isCurrent = currentLevel >= threshold.level;
                  
                  return Container(
                    color: isCurrent ? primaryRed.withOpacity(0.15) : Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              threshold.level.toString(),
                              style: TextStyle(
                                color: isCurrent ? Colors.white : Colors.white70,
                                fontSize: 16,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              threshold.status,
                              style: TextStyle(
                                color: isCurrent ? Colors.white : Colors.white70,
                                fontSize: 16,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isCurrent ? Colors.black26 : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  _badgePathForRank(threshold.status),
                                  width: 32,
                                  height: 32,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern bottom action bar
  Widget _buildBottomBar(BuildContext context, S loc) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: cardBackground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 18, color: Colors.white70),
            label: Text(
              loc.back,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Navigation zu Daily Challenges (in Kürze)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Daily challenges coming soon!"),
                  backgroundColor: primaryRed,
                ),
              );
            },
            icon: const Icon(Icons.bolt, size: 18),
            label: const Text(
              "Daily Challenges",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
