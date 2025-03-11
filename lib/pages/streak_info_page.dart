import 'package:flutter/material.dart';
import 'package:daimonion_app/l10n/generated/l10n.dart';
import 'dart:math' as math;

class StreakInfoPage extends StatefulWidget {
  final int streak;
  const StreakInfoPage({Key? key, required this.streak}) : super(key: key);

  @override
  State<StreakInfoPage> createState() => _StreakInfoPageState();
}

class _StreakInfoPageState extends State<StreakInfoPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wir gehen hier davon aus, dass S.of(context) niemals null ist
    final loc = S.of(context)!;

    // Berechnung des XP-Multiplikators
    const double baseRate = 0.01; // +1% pro Streak-Tag
    const double maxMultiplier = 2.0;
    double multiplier = 1.0 + baseRate * (widget.streak - 1);
    multiplier = multiplier.clamp(1.0, maxMultiplier);
    final bonusPercent = ((multiplier - 1.0) * 100).round();

    // Calculate progress percentage toward max multiplier
    final progressPercent = ((multiplier - 1.0) / (maxMultiplier - 1.0)).clamp(0.0, 1.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF121212),
              const Color(0xFF1E1E1E),
              Colors.grey.shade900,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    loc.streak_info_title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Animated Streak Fire
                  _buildAnimatedStreakFire(widget.streak),

                  const SizedBox(height: 40),

                  // XP Boost Card
                  _buildXPBoostCard(loc, bonusPercent, progressPercent),

                  const SizedBox(height: 30),

                  // Streak Benefits Card
                  _buildStreakBenefitsCard(loc),

                  const SizedBox(height: 30),

                  // Streak Calendar
                  _buildStreakCalendar(widget.streak),

                  const SizedBox(height: 40),

                  // Continue Button
                  _buildContinueButton(context, loc),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStreakFire(int streak) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFDF1B1B).withOpacity(0.7),
                        const Color(0xFFDF1B1B).withOpacity(0.0),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDF1B1B).withOpacity(
                          0.3 + 0.2 * math.sin(_animationController.value * 2 * math.pi),
                        ),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                );
              },
            ),

            // Inner circle
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade800,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animationController.value * 2 * math.pi / 60, // langsamere Rotation
                    child: const Icon(
                      Icons.local_fire_department,
                      size: 80,
                      color: Color(0xFFDF1B1B),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context)!.streak_days(streak),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFDF1B1B),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildXPBoostCard(S loc, int bonusPercent, double progressPercent) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: const Color(0xFF242424),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDF1B1B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFDF1B1B),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    loc.xp_bonus(bonusPercent),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "1.0×",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      "2.0×",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    // Background
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    // Progress
                    Container(
                      height: 10,
                      width: MediaQuery.of(context).size.width * 0.8 * progressPercent,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFDF1B1B), Color(0xFFFF6B6B)],
                        ),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDF1B1B).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              loc.streak_description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakBenefitsCard(S loc) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: const Color(0xFF242424),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDF1B1B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFDF1B1B),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Streak Benefits",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              loc.streak_rewards,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Additional benefits list
            _buildBenefitItem(Icons.speed, "Faster Progress", "Complete tasks more efficiently"),
            _buildBenefitItem(Icons.lock_open, "Unlock Special Features", "Access exclusive content"),
            _buildBenefitItem(Icons.military_tech, "Earn Rare Achievements", "Show off your dedication"),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDF1B1B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFDF1B1B),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCalendar(int streak) {
    // Generate the last 7 days with the streak
    final List<bool> days = List.generate(7, (index) {
      // For simplicity, wir nehmen an, dass die letzten 'streak' Tage abgeschlossen sind
      return index >= (7 - streak.clamp(0, 7));
    });

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: const Color(0xFF242424),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Last 7 Days",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                String dayLabel = "";
                switch (index) {
                  case 0:
                    dayLabel = "M";
                    break;
                  case 1:
                    dayLabel = "T";
                    break;
                  case 2:
                    dayLabel = "W";
                    break;
                  case 3:
                    dayLabel = "T";
                    break;
                  case 4:
                    dayLabel = "F";
                    break;
                  case 5:
                    dayLabel = "S";
                    break;
                  case 6:
                    dayLabel = "S";
                    break;
                }

                return Column(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: days[index]
                            ? const Color(0xFFDF1B1B)
                            : Colors.grey.shade800,
                        boxShadow: days[index]
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFDF1B1B).withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          days[index] ? Icons.check : Icons.close,
                          color: days[index] ? Colors.white : Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dayLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: days[index] ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, S loc) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDF1B1B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
          shadowColor: const Color(0xFFDF1B1B).withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt, size: 24),
            const SizedBox(width: 8),
            Text(
              loc.back_button,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
