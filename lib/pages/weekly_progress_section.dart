// lib/pages/weekly_progress_section.dart
import 'package:flutter/material.dart';
import 'package:daimonion_app/l10n/generated/l10n.dart';
import 'dart:ui';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/dashboard_utils.dart';
import '../models/data_models.dart'; // Verwende hier die Task-Klasse aus data_models.dart
import '../services/db_service.dart';
import '../pages/user_stats_page.dart'; // Für Navigation zur UserStatsPage

class WeeklyProgressSection extends StatelessWidget {
  final List<DateTime> weekDates;
  final DBService dbService;

  const WeeklyProgressSection({
    Key? key,
    required this.weekDates,
    required this.dbService,
  }) : super(key: key);

  // Hilfsmethode: Konvertiert die Tasks-Box in eine Liste von Tasks
  List<Task> _boxToTaskList(Box box) {
    final List<Task> tasks = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data == null) continue;
      final id = data['id'] as String? ?? '';
      final title = data['title'] as String? ?? '';
      final completed = data['completed'] as bool? ?? false;
      final deadlineTimestamp = data['deadline'] as int?;
      final deadline = deadlineTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(deadlineTimestamp)
          : DateTime.now();
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
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final dayDate = weekDates[index];
            final isToday = isSameDay(dayDate, DateTime.now());
            final completedCount = _getCompletedCountForDate(dayDate, tasks);
            final totalItems = _getTotalCountForDate(dayDate, tasks);
            final progressPercent =
                totalItems > 0 ? (completedCount / totalItems).clamp(0.0, 1.0) : 0.0;
            return Expanded(
              child: Column(
                children: [
                  Text(
                    weekDayLabels[index],
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 90,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutQuart,
                              width: constraints.maxWidth,
                              height: constraints.maxHeight * progressPercent,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 223, 27, 27),
                                    Color.fromARGB(255, 223, 27, 27),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 223, 27, 27),
                                    offset: const Offset(0, 2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              child: Text(
                                '$completedCount/$totalItems',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dayDate.day.toString(),
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserStatsPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            child: SizedBox(
              height: 140,
              child: _buildWeekDayProgress(context),
            ),
          ),
        ],
      ),
    );
  }
}
