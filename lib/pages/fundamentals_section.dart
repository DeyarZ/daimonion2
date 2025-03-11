import 'package:flutter/material.dart';
import '../l10n/generated/l10n.dart';
import '../models/data_models.dart';

class FundamentalsSection extends StatelessWidget {
  final DailyCheckModel todayCheck;
  final void Function(String key, bool value) onToggle;
  final void Function(String title, String explanation) onExplanation;

  const FundamentalsSection({
    Key? key,
    required this.todayCheck,
    required this.onToggle,
    required this.onExplanation,
  }) : super(key: key);

  int get completedCount => [
        todayCheck.gym,
        todayCheck.mental,
        todayCheck.noPorn,
        todayCheck.healthyEating,
        todayCheck.helpOthers,
      ].where((completed) => completed).length;

  @override
  Widget build(BuildContext context) {
    final progressPercentage = completedCount / 5;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 6),
            blurRadius: 16,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      // SingleChildScrollView mit reduziertem bottom-Padding
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header mit Fortschrittsleiste
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        S.of(context).dailyFundamentalsTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "$completedCount/5 ${S.of(context).dailyProgress}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Fortschrittsleiste
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Container(
                            height: 8,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            height: 8,
                            width: constraints.maxWidth * progressPercentage,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: progressPercentage < 1.0
                                    ? [Colors.green.shade600, Colors.green.shade400]
                                    : [Colors.amber.shade600, Colors.amber.shade400],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: (progressPercentage < 1.0 ? Colors.green : Colors.amber)
                                      .withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            // Grid mit den Fundamentals (5 Spalten, Labels in einer Zeile)
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
              // Etwas größer, damit "Kein Porn" in eine Zeile passt
              childAspectRatio: 0.7,
              children: _buildFundamentalItems(context),
            ),
            const SizedBox(height: 16),
            // Motivationsnachricht (reduziertes Bottom-Padding)
            if (completedCount < 5)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _getMotivationalMessage(completedCount),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            // Feierbanner für 5/5
            if (completedCount == 5)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context).allTasksCompleted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFundamentalItems(BuildContext context) {
    return [
      _buildFundamentalItem(
        context: context,
        icon: Icons.fitness_center,
        label: S.of(context).shortCheckGym, // "Körper"
        explanation: S.of(context).fullCheckGym,
        isDone: todayCheck.gym,
        keyName: 'gym',
        color: Colors.orange,
      ),
      _buildFundamentalItem(
        context: context,
        icon: Icons.self_improvement,
        label: S.of(context).shortCheckMental, // "Mental"
        explanation: S.of(context).fullCheckMental,
        isDone: todayCheck.mental,
        keyName: 'mental',
        color: Colors.blue,
      ),
      _buildFundamentalItem(
        context: context,
        icon: Icons.block,
        label: S.of(context).shortCheckNoPorn, // "Kein Porn"
        explanation: S.of(context).fullCheckNoPorn,
        isDone: todayCheck.noPorn,
        keyName: 'noPorn',
        color: Colors.purple,
      ),
      _buildFundamentalItem(
        context: context,
        icon: Icons.restaurant,
        label: S.of(context).shortCheckHealthyEating, // "Gesund"
        explanation: S.of(context).fullCheckHealthyEating,
        isDone: todayCheck.healthyEating,
        keyName: 'healthyEating',
        color: Colors.green,
      ),
      _buildFundamentalItem(
        context: context,
        icon: Icons.volunteer_activism,
        label: S.of(context).shortCheckHelpOthers, // "Helfen"
        explanation: S.of(context).fullCheckHelpOthers,
        isDone: todayCheck.helpOthers,
        keyName: 'helpOthers',
        color: Colors.red,
      ),
    ];
  }

  Widget _buildFundamentalItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String explanation,
    required bool isDone,
    required String keyName,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => onToggle(keyName, !isDone),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isDone
                    ? [color.withOpacity(0.85), color.withOpacity(0.65)]
                    : [Colors.grey.shade800, Colors.grey.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDone
                      ? color.withOpacity(0.4)
                      : Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(
                color: isDone
                    ? color.withOpacity(0.4)
                    : Colors.grey.shade600.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: RotationTransition(
                    turns: anim,
                    child: child,
                  ),
                ),
                child: isDone
                    ? Icon(
                        Icons.check,
                        key: ValueKey('$keyName-check'),
                        color: Colors.white,
                        size: 30,
                      )
                    : Icon(
                        icon,
                        key: ValueKey('$keyName-icon'),
                        color: Colors.white70,
                        size: 26,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => onExplanation(label, explanation),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isDone ? color.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isDone
                  ? Border.all(color: color.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // Etwas kleinere Schrift, um Zeilenumbruch zu vermeiden
                      fontSize: 11,
                      color: isDone ? Colors.white : Colors.white70,
                      fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDone
                        ? color.withOpacity(0.4)
                        : Colors.grey.shade700,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.question_mark,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getMotivationalMessage(int completed) {
    if (completed == 0) {
      return "Start your daily habits! Take the first step today.";
    } else if (completed < 3) {
      return "You've made a good start! Keep going!";
    } else if (completed < 5) {
      return "Almost there! Just a few more to complete today's goals.";
    } else {
      return "Amazing job! You've completed all your daily habits!";
    }
  }
}
