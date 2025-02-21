// lib/pages/tools_page.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'flow_timer.dart';
import 'todo_list.dart';
import 'journal.dart';
import 'habit_tracker.dart';
import 'subscription_page.dart';
import 'training_plan.dart';
import '../widgets/ad_wrapper.dart';
import '../l10n/generated/l10n.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    // Moderne Tool-Liste: Wir verzichten komplett auf Bilder
    // und nutzen Icons. Du kannst sie jederzeit anpassen.
    final List<_ToolItem> tools = [
      _ToolItem(
        title: loc.flowTimerToolTitle,
        iconData: Icons.timer_outlined,
        isPremium: false,
        pageToNavigate: const FlowTimerPage(),
      ),
      _ToolItem(
        title: loc.tasksToolTitle,
        iconData: Icons.checklist_outlined,
        isPremium: false,
        pageToNavigate: const ToDoListPage(),
      ),
      _ToolItem(
        title: loc.journalToolTitle,
        iconData: Icons.book_outlined,
        isPremium: true,
        pageToNavigate: const JournalPage(),
      ),
      _ToolItem(
        title: loc.habitTrackerToolTitle,
        iconData: Icons.track_changes_outlined,
        isPremium: true,
        pageToNavigate: const HabitTrackerPage(),
      ),
      _ToolItem(
        title: loc.trainingPlanToolTitle,
        iconData: Icons.fitness_center_outlined,
        isPremium: false,
        pageToNavigate: const TrainingPlanPage(),
      ),
    ];

    // Check, ob der User Premium hat
    final isPremium = Hive.box('settings').get('isPremium', defaultValue: false); // WICHTIG: UNBEDINGT WIEDER AUF FALSE SETZEN VOR RELEASE

    return AdWrapper(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(loc.toolsPageTitle),
          backgroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            itemCount: tools.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,        // 2 Spalten
              crossAxisSpacing: 12,     // Abstand horizontal
              mainAxisSpacing: 12,      // Abstand vertikal
              childAspectRatio: 0.90,   // Etwas quadratischer
            ),
            itemBuilder: (context, index) {
              final tool = tools[index];
              return _ToolCardItem(
                tool: tool,
                isUserPremium: isPremium,
                onTap: () {
                  if (tool.isPremium && !isPremium) {
                    _showPaywallDialog(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => tool.pageToNavigate),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Dialog mit zusätzlichem Button zur SubscriptionPage
  void _showPaywallDialog(BuildContext context) {
    final loc = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(loc.paywallTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.paywallContent),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Dialog schließen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 223, 27, 27)),
                child: Text(loc.upgradeToPremium),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(loc.ok),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------
// DATENKLASSE FÜR EIN TOOL (ohne Bildpfad, dafür Icon)
// -----------------------------------------------------------------
class _ToolItem {
  final String title;
  final IconData iconData;
  final bool isPremium;
  final Widget pageToNavigate;

  const _ToolItem({
    required this.title,
    required this.iconData,
    required this.isPremium,
    required this.pageToNavigate,
  });
}

// -----------------------------------------------------------------
// EIN TOOL-CARD-ITEM IM GRID (komplett neu gestaltet)
// -----------------------------------------------------------------
class _ToolCardItem extends StatelessWidget {
  final _ToolItem tool;
  final bool isUserPremium;
  final VoidCallback onTap;

  const _ToolCardItem({
    Key? key,
    required this.tool,
    required this.isUserPremium,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showLock = (tool.isPremium && !isUserPremium);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Schicker, dunkler Gradient (kannst du gern ändern)
          gradient: const LinearGradient(
            colors: [Color(0xFF1F1F1F), Color(0xFF2E2E2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Inhalt: Icon + Titel
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tool.iconData,
                      size: 50,
                      color: const Color.fromARGB(255, 223, 27, 27),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tool.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lock-Overlay, falls Premium => lock
            if (showLock)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
