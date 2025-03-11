// lib/pages/tools_page.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
    
    // Modern tool list with categories
    final List<_ToolCategory> categories = [
      _ToolCategory(
        title: loc.productivityCategory,
        tools: [
          _ToolItem(
            title: loc.flowTimerToolTitle,
            iconData: Icons.timer_outlined,
            isPremium: false,
            pageToNavigate: const FlowTimerPage(),
            description: loc.flowTimerDescription,
            accentColor: const Color(0xFF3498DB),
          ),
          _ToolItem(
            title: loc.tasksToolTitle,
            iconData: Icons.checklist_outlined,
            isPremium: false,
            pageToNavigate: const ToDoListPage(),
            description: loc.tasksDescription,
            accentColor: const Color(0xFF2ECC71),
          ),
        ],
      ),
      _ToolCategory(
        title: loc.wellnessCategory,
        tools: [
          _ToolItem(
            title: loc.journalToolTitle,
            iconData: Icons.book_outlined,
            isPremium: true,
            pageToNavigate: const JournalPage(),
            description: loc.journalDescription,
            accentColor: const Color(0xFFF39C12),
          ),
          _ToolItem(
            title: loc.habitTrackerToolTitle,
            iconData: Icons.track_changes_outlined,
            isPremium: true,
            pageToNavigate: const HabitTrackerPage(),
            description: loc.habitTrackerDescription,
            accentColor: const Color(0xFF9B59B6),
          ),
          _ToolItem(
            title: loc.trainingPlanToolTitle,
            iconData: Icons.fitness_center_outlined,
            isPremium: false,
            pageToNavigate: const TrainingPlanPage(),
            description: loc.trainingPlanDescription,
            accentColor: const Color(0xFFE74C3C),
          ),
        ],
      ),
    ];

    // Check if the user has Premium
    final isPremium = Hive.box('settings').get('isPremium', defaultValue: false); //WICHTIG !!!

    return AdWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: Text(
            loc.toolsPageTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // Quick access to premium subscription
            if (!isPremium)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.workspace_premium,
                    color: Color(0xFFE74C3C),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                  ),
                  tooltip: loc.upgradeToPremium,
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: categories.length,
              itemBuilder: (context, categoryIndex) {
                final category = categories[categoryIndex];
                return AnimationConfiguration.staggeredList(
                  position: categoryIndex,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, bottom: 12.0, top: 16.0),
                            child: Text(
                              category.title,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          // Grid for tools in this category
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: category.tools.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                            itemBuilder: (context, index) {
                              final toolIndex = categoryIndex * 10 + index; // Unique position for animation
                              final tool = category.tools[index];
                              
                              return AnimationConfiguration.staggeredGrid(
                                position: toolIndex,
                                duration: const Duration(milliseconds: 375),
                                columnCount: 2,
                                child: ScaleAnimation(
                                  child: FadeInAnimation(
                                    child: _ToolCardItem(
                                      tool: tool,
                                      isUserPremium: isPremium,
                                      onTap: () {
                                        if (tool.isPremium && !isPremium) {
                                          _showPaywallDialog(context);
                                        } else {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation, secondaryAnimation) => tool.pageToNavigate,
                                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                const begin = Offset(1.0, 0.0);
                                                const end = Offset.zero;
                                                const curve = Curves.easeInOutQuart;
                                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                var offsetAnimation = animation.drive(tween);
                                                return SlideTransition(position: offsetAnimation, child: child);
                                              },
                                            ),
                                          );
                                        }
                                      },
                                    ),
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
              },
            ),
          ),
        ),
        // Floating action button for quick help
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showHelpDialog(context),
          backgroundColor: const Color.fromARGB(255, 223, 27, 27),
          child: const Icon(Icons.help_outline),
        ),
      ),
    );
  }

  // Premium dialog with improved visuals
  void _showPaywallDialog(BuildContext context) {
    final loc = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF212121),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            loc.paywallTitle,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.workspace_premium,
                color: Color(0xFFE74C3C),
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                loc.paywallContent,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      loc.upgradeToPremium,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                loc.maybeLater,
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Helper dialog - new functionality
  void _showHelpDialog(BuildContext context) {
    final loc = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF212121),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            loc.helpDialogTitle,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem(Icons.timer_outlined, loc.flowTimerToolTitle, loc.flowTimerHelp),
              const Divider(color: Colors.white24),
              _buildHelpItem(Icons.checklist_outlined, loc.tasksToolTitle, loc.tasksHelp),
              const Divider(color: Colors.white24),
              _buildHelpItem(Icons.book_outlined, loc.journalToolTitle, loc.journalHelp),
              const Divider(color: Colors.white24),
              _buildHelpItem(Icons.track_changes_outlined, loc.habitTrackerToolTitle, loc.habitTrackerHelp),
              const Divider(color: Colors.white24),
              _buildHelpItem(Icons.fitness_center_outlined, loc.trainingPlanToolTitle, loc.trainingPlanHelp),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                loc.gotIt,
                style: const TextStyle(
                  color: Color.fromARGB(255, 223, 27, 27),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color.fromARGB(255, 223, 27, 27), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// CATEGORY CLASS (NEW)
// -----------------------------------------------------------------
class _ToolCategory {
  final String title;
  final List<_ToolItem> tools;

  const _ToolCategory({
    required this.title,
    required this.tools,
  });
}

// -----------------------------------------------------------------
// TOOL ITEM CLASS (ENHANCED)
// -----------------------------------------------------------------
class _ToolItem {
  final String title;
  final IconData iconData;
  final bool isPremium;
  final Widget pageToNavigate;
  final String description;  // Added description
  final Color accentColor;   // Added accent color

  const _ToolItem({
    required this.title,
    required this.iconData,
    required this.isPremium,
    required this.pageToNavigate,
    required this.description,
    required this.accentColor,
  });
}

// -----------------------------------------------------------------
// TOOL CARD ITEM WIDGET (COMPLETELY REDESIGNED)
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
    
    return Hero(
      tag: 'tool-${tool.title}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: tool.accentColor.withOpacity(0.1),
          highlightColor: tool.accentColor.withOpacity(0.05),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF202020),
                  const Color(0xFF303030),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: tool.accentColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Background pattern (subtle texture)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.05,
                      child: CustomPaint(
                        painter: _PatternPainter(color: tool.accentColor),
                      ),
                    ),
                  ),
                  
                  // Premium indicator glow
                  if (tool.isPremium)
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tool.accentColor.withOpacity(0.2),
                        ),
                      ),
                    ),
                    
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: tool.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                tool.iconData,
                                color: tool.accentColor,
                                size: 30,
                              ),
                            ),
                            const Spacer(),
                            if (showLock)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8, 
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: tool.accentColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock,
                                      color: tool.accentColor,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Premium',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          tool.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tool.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Visual indicator for interactivity - subtle line
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            tool.accentColor.withOpacity(0.0),
                            tool.accentColor.withOpacity(0.7),
                            tool.accentColor.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// CUSTOM PATTERN PAINTER FOR BACKGROUND TEXTURE (NEW)
// -----------------------------------------------------------------
class _PatternPainter extends CustomPainter {
  final Color color;
  
  _PatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
      
    // Draw a subtle pattern of dots and lines
    const spacing = 15.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw dot
        canvas.drawCircle(Offset(x, y), 0.5, paint);
        
        // Sometimes draw connecting lines
        if ((x + y) % 3 == 0) {
          canvas.drawLine(
            Offset(x, y),
            Offset(x + spacing, y + spacing),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}