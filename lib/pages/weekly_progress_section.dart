import 'package:flutter/material.dart';
import 'package:daimonion_app/l10n/generated/l10n.dart';
import 'dart:ui';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/dashboard_utils.dart';
import '../models/data_models.dart';
import '../services/db_service.dart';
import '../pages/user_stats_page.dart';

class WeeklyProgressSection extends StatelessWidget {
  final List<DateTime> weekDates;
  final DBService dbService;

  const WeeklyProgressSection({
    Key? key,
    required this.weekDates,
    required this.dbService,
  }) : super(key: key);

  // Helper zum Parsen von Datum: Akzeptiert int und String
  DateTime _parseDate(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      return DateTime.parse(value);
    } else {
      return DateTime.now();
    }
  }

  // Hilfsmethode: Konvertiert die Tasks-Box in eine Liste von Tasks
  List<Task> _boxToTaskList(Box box) {
    final List<Task> tasks = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data == null) continue;
      final id = data['id'] as String? ?? '';
      final title = data['title'] as String? ?? '';
      final completed = data['completed'] as bool? ?? false;
      final deadline = _parseDate(data['deadline']);
      // Erstelle Task ohne den createdAt Parameter
      tasks.add(Task(
        id: id,
        title: title,
        completed: completed,
        deadline: deadline,
      ));
    }
    return tasks;
  }

  // Hilfsmethode: Berechnet die Anzahl abgeschlossener Tasks an einem bestimmten Tag
  int _getCompletedCountForDate(DateTime date, List<Task> tasks) {
    int count = 0;
    for (var task in tasks) {
      if (isSameDay(task.deadline, date) && task.completed) {
        count++;
      }
    }
    return count;
  }

  // Hilfsmethode: Berechnet die Gesamtanzahl an Tasks an einem bestimmten Tag
  int _getTotalCountForDate(DateTime date, List<Task> tasks) {
    int count = 0;
    for (var task in tasks) {
      if (isSameDay(task.deadline, date)) {
        count++;
      }
    }
    return count;
  }

  // New helper method to determine productivity level
  String _getProductivityLevel(double progressPercent) {
    if (progressPercent >= 0.9) return 'Excellent';
    if (progressPercent >= 0.7) return 'Good';
    if (progressPercent >= 0.4) return 'OK';
    if (progressPercent > 0) return 'Low';
    return 'None';
  }

  // New helper to determine color based on completion percentage
  Color _getProgressColor(double progressPercent) {
    if (progressPercent >= 0.75) {
      return const Color.fromARGB(255, 46, 213, 115); // Green for high completion
    } else if (progressPercent >= 0.5) {
      return const Color.fromARGB(255, 255, 184, 0); // Yellow for medium completion
    } else {
      return const Color.fromARGB(255, 223, 27, 27); // Red for low completion
    }
  }

  Widget _buildWeekDayProgress(BuildContext context) {
    final weekDayLabels = [
      S.of(context).mondayShort,
      S.of(context).tuesdayShort,
      S.of(context).wednesdayShort,
      S.of(context).thursdayShort,
      S.of(context).fridayShort,
      S.of(context).saturdayShort,
      S.of(context).sundayShort,
    ];

    return ValueListenableBuilder(
      valueListenable: dbService.listenableTasks(),
      builder: (context, Box box, _) {
        final tasks = _boxToTaskList(box);
        
        // Calculate weekly stats
        int totalWeekTasks = 0;
        int totalCompletedTasks = 0;
        for (final date in weekDates) {
          totalWeekTasks += _getTotalCountForDate(date, tasks);
          totalCompletedTasks += _getCompletedCountForDate(date, tasks);
        }
        final weeklyProgressPercent = 
            totalWeekTasks > 0 ? (totalCompletedTasks / totalWeekTasks).clamp(0.0, 1.0) : 0.0;
            
        return Column(
          children: [
            // Weekly summary at the top
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getProgressColor(weeklyProgressPercent).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${(weeklyProgressPercent * 100).toInt()}% ",
                            style: TextStyle(
                              color: _getProgressColor(weeklyProgressPercent),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: "completed this week",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Day bars
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final dayDate = weekDates[index];
                final isToday = isSameDay(dayDate, DateTime.now());
                final completedCount = _getCompletedCountForDate(dayDate, tasks);
                final totalItems = _getTotalCountForDate(dayDate, tasks);
                final progressPercent =
                    totalItems > 0 ? (completedCount / totalItems).clamp(0.0, 1.0) : 0.0;
                final progressColor = _getProgressColor(progressPercent);
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Show details of tasks for this day
                      _showDayDetailsBottomSheet(context, dayDate, tasks);
                    },
                    child: Column(
                      children: [
                        // Day name
                        Text(
                          weekDayLabels[index],
                          style: TextStyle(
                            color: isToday ? Colors.white : Colors.grey.shade400,
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        
                        // Progress bar
                        Container(
                          height: 80,
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Hintergrund
                                    Container(
                                      width: constraints.maxWidth,
                                      height: constraints.maxHeight,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey.shade800.withOpacity(0.3),
                                      ),
                                    ),
                                    
                                    // Fortschrittsbalken
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeOutQuart,
                                      width: constraints.maxWidth,
                                      height: constraints.maxHeight * progressPercent,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: [
                                            progressColor.withOpacity(0.7),
                                            progressColor,
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: progressColor.withOpacity(0.4),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Task count
                                    Positioned(
                                      bottom: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.black54,
                                        ),
                                        child: Text(
                                          totalItems > 0 ? '$completedCount/$totalItems' : '0',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Fixed: Added proper spacing and removed negative offset
                        const SizedBox(height: 8), // Add proper spacing
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday ? const Color.fromARGB(255, 223, 27, 27) : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              dayDate.day.toString(),
                              style: TextStyle(
                                color: isToday ? Colors.white : Colors.grey.shade400,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  void _showDayDetailsBottomSheet(BuildContext context, DateTime date, List<Task> tasks) {
    final dayTasks = tasks.where((task) => isSameDay(task.deadline, date)).toList();
    final completedTasks = dayTasks.where((task) => task.completed).toList();
    final pendingTasks = dayTasks.where((task) => !task.completed).toList();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF212121),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Stats summary
              Row(
                children: [
                  _buildStatCard(
                    context, 
                    'Total', 
                    dayTasks.length.toString(),
                    Icons.assignment,
                    Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    context, 
                    'Completed', 
                    completedTasks.length.toString(), 
                    Icons.check_circle,
                    Colors.green,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    context, 
                    'Pending', 
                    pendingTasks.length.toString(), 
                    Icons.pending,
                    Colors.orange,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              const Text(
                'Tasks for this day:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Task list
              Flexible(
                child: dayTasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.assignment_outlined, 
                              color: Colors.grey.shade600, size: 48),
                          const SizedBox(height: 10),
                          Text(
                            'No tasks for this day',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: dayTasks.length,
                    itemBuilder: (context, index) {
                      final task = dayTasks[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: task.completed 
                              ? Colors.green.withOpacity(0.2) 
                              : Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            task.completed ? Icons.check : Icons.hourglass_empty,
                            color: task.completed ? Colors.green : Colors.red,
                            size: 14,
                          ),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            color: Colors.white,
                            decoration: task.completed? TextDecoration.lineThrough 
                              : null,
                            decorationColor: Colors.green,
                          ),
                        ),
                      );
                    },
                  ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, 
    String label, 
    String value, 
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge, // Verhindert Überlaufen der Inhalte
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A2A), Color(0xFF212121)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                // Weekly progress title with icon
                Icon(
                  Icons.insights,
                  color: const Color.fromARGB(255, 223, 27, 27),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.of(context).weeklyProgress,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                
                // View stats button
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserStatsPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color.fromARGB(255, 223, 27, 27).withOpacity(0.2),
                    ),
                    child: Row(
                      children: [
                        Text(
                          S.of(context).viewStats,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 223, 27, 27),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color.fromARGB(255, 223, 27, 27),
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.grey,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildWeekDayProgress(context),
          ),
        ],
      ),
    );
  }
}