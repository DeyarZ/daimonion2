import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'flow_timer.dart';
import 'todo_list.dart';
import 'journal.dart';
import 'habit_tracker.dart';
import '../widgets/ad_wrapper.dart'; // Import des AdWrapper

class ToolsPage extends StatelessWidget {
  const ToolsPage({Key? key}) : super(key: key);

  // Liste der Tools
  final List<_ToolItem> tools = const [
    _ToolItem(
      title: 'Flow Timer',
      imagePath: 'assets/images/Flow_Timer.png',
      isPremium: false,
      pageToNavigate: FlowTimerPage(),
    ),
    _ToolItem(
      title: 'Tasks',
      imagePath: 'assets/images/To_Do_List.jpg',
      isPremium: false,
      pageToNavigate: ToDoListPage(),
    ),
    _ToolItem(
      title: 'Journal',
      imagePath: 'assets/images/journal.jpg',
      isPremium: true,
      pageToNavigate: JournalPage(),
    ),
    _ToolItem(
      title: 'Gewohnheitstracker',
      imagePath: 'assets/images/habits.jpg',
      isPremium: true,
      pageToNavigate: HabitTrackerPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Check ob Premium
    final isPremium = Hive.box('settings').get('isPremium', defaultValue: false);

    return AdWrapper(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Deine Werkzeuge zum Sieg'),
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
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Premium benötigt'),
          content: const Text('Dieses Tool ist nur für Premium-Mitglieder verfügbar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
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
