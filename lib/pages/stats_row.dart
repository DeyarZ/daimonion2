import 'package:flutter/material.dart';
import '../l10n/generated/l10n.dart';
import '../utils/dashboard_utils.dart';

class StatsRow extends StatelessWidget {
  final bool isRunning;
  final String timeString;
  final int streak;
  final String weeklyFlowTime;
  final VoidCallback onProductiveTimeTap;
  final VoidCallback onStreakTap;
  final VoidCallback onFlowTimerTap;

  const StatsRow({
    Key? key,
    required this.isRunning,
    required this.timeString,
    required this.streak,
    required this.weeklyFlowTime,
    required this.onProductiveTimeTap,
    required this.onStreakTap,
    required this.onFlowTimerTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use a theme-based color instead of hardcoded
    final primaryColor = Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFFE53935) // slightly softer red in dark mode
        : const Color(0xFFD32F2F); // material red for light mode
    
    final shadowColor = primaryColor.withOpacity(0.25);
    
    return Row(
      children: [
        Expanded(
          child: _buildStatsCard(
            context: context,
            title: S.of(context).productiveTimeWeek,
            value: weeklyFlowTime,
            icon: Icons.watch_later_outlined,
            onTap: onProductiveTimeTap,
            shadowColor: shadowColor,
            primaryColor: primaryColor,
            tooltip: S.of(context).productiveTimeWeek,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatsCard(
            context: context,
            title: S.of(context).streak,
            value: '$streak',
            icon: Icons.local_fire_department,
            onTap: onStreakTap,
            shadowColor: shadowColor,
            primaryColor: primaryColor,
            tooltip: '${S.of(context).streak}: $streak ${streak == 1 ? "day" : "days"}',
            showAnimation: streak > 3,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildFlowTimerCard(
            context: context,
            isRunning: isRunning,
            timeString: timeString,
            onTap: onFlowTimerTap,
            shadowColor: shadowColor,
            primaryColor: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required Color shadowColor,
    required Color primaryColor,
    required String tooltip,
    bool showAnimation = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 110),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2A2A2A),
                const Color(0xFF1A1A1A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(0, 4),
                blurRadius: 12,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                showAnimation
                    ? _animatedIcon(icon, primaryColor)
                    : Icon(icon, color: primaryColor, size: 22),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Digital',
                    fontSize: 26,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _animatedIcon(IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.2),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        );
      },
      onEnd: () {},
    );
  }

  Widget _buildFlowTimerCard({
    required BuildContext context,
    required bool isRunning,
    required String timeString,
    required VoidCallback onTap,
    required Color shadowColor,
    required Color primaryColor,
  }) {
    return Tooltip(
      message: isRunning ? S.of(context).pauseTimer : S.of(context).startTimer,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 110),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isRunning
                  ? [
                      const Color(0xFF2D1E1E),
                      const Color(0xFF1F1515),
                    ]
                  : [
                      const Color(0xFF2A2A2A),
                      const Color(0xFF1A1A1A),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: isRunning ? primaryColor.withOpacity(0.4) : shadowColor,
                offset: const Offset(0, 4),
                blurRadius: 12,
                spreadRadius: isRunning ? 1 : 0,
              ),
            ],
            border: isRunning
                ? Border.all(color: primaryColor.withOpacity(0.3), width: 1.5)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isRunning
                    ? _pulsingIcon(Icons.pause_circle, primaryColor)
                    : Icon(
                        Icons.play_circle,
                        color: primaryColor,
                        size: 22,
                      ),
                const SizedBox(height: 10),
                Text(
                  timeString,
                  style: TextStyle(
                    fontFamily: 'Digital',
                    fontSize: 26,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).flowTimer,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pulsingIcon(IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.2),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        );
      },
      onEnd: () {},
    );
  }
}