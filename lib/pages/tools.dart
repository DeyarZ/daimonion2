// lib/pages/tools_page.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'flow_timer.dart';
import 'todo_list.dart';
import 'journal.dart';
import 'habit_tracker.dart';
import '../widgets/ad_wrapper.dart';
import '../l10n/generated/l10n.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dynamisch die Tool-Items aus der Lokalisierung erstellen
    final loc = S.of(context);
    final List<_ToolItem> tools = [
      _ToolItem(
        title: loc.flowTimerToolTitle,
        imagePath: 'assets/images/Flow_Timer.png',
        isPremium: false,
        pageToNavigate: const FlowTimerPage(),
      ),
      _ToolItem(
        title: loc.tasksToolTitle,
        imagePath: 'assets/images/To_Do_List.jpg',
        isPremium: false,
        pageToNavigate: const ToDoListPage(),
      ),
      _ToolItem(
        title: loc.journalToolTitle,
        imagePath: 'assets/images/journal.jpg',
        isPremium: true,
        pageToNavigate: const JournalPage(),
      ),
      _ToolItem(
        title: loc.habitTrackerToolTitle,
        imagePath: 'assets/images/habits.jpg',
        isPremium: true,
        pageToNavigate: const HabitTrackerPage(),
      ),
    ];

    // Check, ob der User Premium hat
    final isPremium = Hive.box('settings').get('isPremium', defaultValue: false);

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
              childAspectRatio: 0.75,   // Verhältnis: Breite/Höhe
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

  // Einfacher Dialog: sag "Hol Premium"
  void _showPaywallDialog(BuildContext context) {
    final loc = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(loc.paywallTitle),
          content: Text(loc.paywallContent),
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
// DATENKLASSE FÜR EIN TOOL
// -----------------------------------------------------------------
class _ToolItem {
  final String title;
  final String imagePath;
  final bool isPremium;
  final Widget pageToNavigate;

  const _ToolItem({
    required this.title,
    required this.imagePath,
    required this.isPremium,
    required this.pageToNavigate,
  });
}

// -----------------------------------------------------------------
// EIN TOOL-CARD-ITEM IM GRID
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
    // Falls Premium => lock overlay
    final showLock = (tool.isPremium && !isUserPremium);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        color: Colors.transparent,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Hintergrundbild
              Image.asset(
                tool.imagePath,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              // Leichter schwarzer Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
              // Titel
              Positioned(
                left: 12,
                bottom: 12,
                child: Text(
                  tool.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Lock-Overlay, falls isPremium => lock
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
      ),
    );
  }
}
