// lib/pages/habit_tracker.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

// Services
import '../services/db_service.dart';

// NEU: Notification-Funktionen aus main.dart
import 'package:daimonion_app/main.dart' show scheduleHabitNotifications, cancelHabitNotifications;

// Lokalisierung importieren
import '../l10n/generated/l10n.dart';

// -------------------------------------------
// Model-Klasse: Habit
// -------------------------------------------
class Habit {
  String id;
  String name;
  Map<String, bool?> dailyStatus;
  List<int> selectedWeekdays;

  // Optional: reminder time
  int? reminderHour;
  int? reminderMinute;

  Habit({
    required this.id,
    required this.name,
    required this.dailyStatus,
    required this.selectedWeekdays,
    this.reminderHour,
    this.reminderMinute,
  });
}

// -------------------------------------------
// Hauptklasse: HabitTrackerPage
// -------------------------------------------
class HabitTrackerPage extends StatefulWidget {
  const HabitTrackerPage({Key? key}) : super(key: key);

  @override
  _HabitTrackerPageState createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage> {
  final DBService _dbService = DBService();
  final _uuid = const Uuid();

  late List<DateTime> days;
  late DateTime today;

  @override
  void initState() {
    super.initState();
    today = _truncateToDate(DateTime.now());
    days = _generate7Days(today);
  }

  List<DateTime> _generate7Days(DateTime center) {
    final List<DateTime> result = [];
    for (int i = -3; i <= 3; i++) {
      final d = center.add(Duration(days: i));
      result.add(_truncateToDate(d));
    }
    return result;
  }

  DateTime _truncateToDate(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.habitTrackerTitle),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${loc.todayLabel} ${_formatDate(today)}',
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _dbService.listenableHabits(),
              builder: (context, Box box, _) {
                final habits = _boxToHabitList(box);

                if (habits.isEmpty) {
                  return Center(
                    child: Text(
                      loc.noHabitsMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(color: Colors.grey.shade800),
                    ),
                    columnWidths: const {
                      0: FixedColumnWidth(160),
                    },
                    children: [
                      // Kopfzeile: Habit + 7 Tage
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey[900]),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              // Hier kann auch ein lokalisierter String stehen, wenn gewünscht:
                              // z.B. S.of(context).habitHeader,
                              'Habit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...days.map((day) {
                            final isToday = _isSameDay(day, today);
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    _dayOfWeekShort(day),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      color: isToday ? Colors.red : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                      // Rows für jede Habit
                      ...List.generate(habits.length, (rowIndex) {
                        final habit = habits[rowIndex];
                        return TableRow(
                          decoration: BoxDecoration(color: Colors.grey[850]),
                          children: [
                            GestureDetector(
                              // LongPress => Habit löschen
                              onLongPress: () => _confirmDeleteHabit(habit),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  habit.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            // 7 Tage => Check ob weekday in habit, dann icon
                            ...days.map((day) {
                              if (!habit.selectedWeekdays.contains(day.weekday)) {
                                return const SizedBox(height: 36);
                              }
                              final strDay = _formatDateKey(day);
                              final status = habit.dailyStatus[strDay];

                              final isPastOrToday =
                                  day.isBefore(today) || _isSameDay(day, today);

                              IconData icon;
                              Color color;
                              if (status == true) {
                                icon = Icons.check;
                                color = Colors.green;
                              } else if (status == false && isPastOrToday) {
                                icon = Icons.close;
                                color = Colors.red;
                              } else {
                                icon = Icons.circle;
                                color = Colors.grey;
                              }

                              return GestureDetector(
                                onTap: () {
                                  if (isPastOrToday) {
                                    _toggleHabitStatus(habit, strDay);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(icon, color: color),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),
    );
  }

  // -------------------------------------------
  // Parse DB -> Habit model
  // -------------------------------------------
  List<Habit> _boxToHabitList(Box box) {
    final List<Habit> list = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data == null) continue;

      final id = data['id'] as String? ?? 'no-id-$i';
      final name = data['name'] as String? ?? 'Unnamed Habit';

      final dsMap = data['dailyStatus'] as Map?;
      final Map<String, bool?> dailyStatus = {};
      if (dsMap != null) {
        dsMap.forEach((k, v) {
          dailyStatus[k.toString()] = v as bool?;
        });
      }

      final sw = data['selectedWeekdays'] as List? ?? [];
      final selectedWeekdays = sw.map((x) => x as int).toList();

      final reminderHour = data['reminderHour'] as int?;
      final reminderMinute = data['reminderMinute'] as int?;

      list.add(Habit(
        id: id,
        name: name,
        dailyStatus: dailyStatus,
        selectedWeekdays: selectedWeekdays,
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
      ));
    }
    return list;
  }

  // -------------------------------------------
  // Toggle => dailyStatus
  // -------------------------------------------
  Future<void> _toggleHabitStatus(Habit habit, String dayKey) async {
    final box = Hive.box<Map>(DBService.habitsBoxName);

    // Index finden
    final index = _findIndexOfHabitById(box, habit.id);
    if (index == -1) return;

    final current = habit.dailyStatus[dayKey];
    final newVal = (current == true) ? false : true;
    habit.dailyStatus[dayKey] = newVal;

    // Speichern
    final newData = {
      'id': habit.id,
      'name': habit.name,
      'dailyStatus': habit.dailyStatus,
      'selectedWeekdays': habit.selectedWeekdays,
      'reminderHour': habit.reminderHour,
      'reminderMinute': habit.reminderMinute,
    };
    await _dbService.updateHabit(index, newData);

    setState(() {});
  }

  // -------------------------------------------
  // Neue Habit anlegen => TimePicker => Notifs
  // -------------------------------------------
  void _addHabit() {
    final TextEditingController controller = TextEditingController();
    final selectedDays = <int>{};
    int? chosenHour;
    int? chosenMinute;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(S.of(ctx).newHabitTitle),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titel
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(hintText: S.of(context).newHabitNameHint),
                    ),
                    const SizedBox(height: 12),

                    // Wochentage-Auswahl
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (i) {
                        final wday = i + 1; // Mo=1..So=7
                        final label = _weekdayToLetter(wday);
                        final isSelected = selectedDays.contains(wday);

                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: Colors.redAccent,
                          onSelected: (bool value) {
                            setStateDialog(() {
                              if (value) {
                                selectedDays.add(wday);
                              } else {
                                selectedDays.remove(wday);
                              }
                            });
                          },
                        );
                      }),
                    ),

                    const SizedBox(height: 12),

                    // Reminder optional
                    Row(
                      children: [
                        Text(S.of(context).reminderLabel),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () async {
                            final timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (timeOfDay != null) {
                              setStateDialog(() {
                                chosenHour = timeOfDay.hour;
                                chosenMinute = timeOfDay.minute;
                              });
                            }
                          },
                          child: Text(
                            (chosenHour == null || chosenMinute == null)
                                ? S.of(context).noReminder
                                : '${chosenHour!.toString().padLeft(2, '0')}:${chosenMinute!.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(ctx).cancel),
            ),
            TextButton(
              onPressed: () async {
                final newHabitName = controller.text.trim();
                if (newHabitName.isNotEmpty && selectedDays.isNotEmpty) {
                  // dailyMap => für alle days, die im 7-Tage-Fenster liegen
                  final dailyMap = <String, bool?>{};
                  for (var d in days) {
                    if (selectedDays.contains(d.weekday)) {
                      dailyMap[_formatDateKey(d)] = null;
                    }
                  }

                  final newData = {
                    'id': _uuid.v4(),
                    'name': newHabitName,
                    'dailyStatus': dailyMap,
                    'selectedWeekdays': selectedDays.toList(),
                    'reminderHour': chosenHour,
                    'reminderMinute': chosenMinute,
                  };

                  // In DB speichern
                  await _dbService.addHabit(newData);

                  // Falls eine Zeit gewählt wurde => schedule
                  if (chosenHour != null && chosenMinute != null) {
                    scheduleHabitNotifications(
                      habitId: newData['id'] as String,
                      habitName: newHabitName,
                      hour: chosenHour!,
                      minute: chosenMinute!,
                      weekdays: selectedDays,
                    );
                  }
                }
                Navigator.pop(ctx);
              },
              child: Text(S.of(ctx).ok),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------
  // Habit löschen => ggf. Notifications canceln
  // -------------------------------------------
  void _confirmDeleteHabit(Habit habit) async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(S.of(ctx).deleteHabitTitle),
          content: Text(S.of(ctx).deleteHabitMessage(habit.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(ctx).cancel),
            ),
            TextButton(
              onPressed: () async {
                await _deleteHabit(habit);
                Navigator.pop(ctx);
              },
              child: Text(S.of(ctx).confirmDeleteHabit),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteHabit(Habit habit) async {
    final box = Hive.box<Map>(DBService.habitsBoxName);
    final index = _findIndexOfHabitById(box, habit.id);
    if (index != -1) {
      // Falls Zeit gesetzt => Notifications canceln
      if (habit.reminderHour != null && habit.reminderMinute != null) {
        cancelHabitNotifications(habit.id, habit.selectedWeekdays.toSet());
      }
      await _dbService.deleteHabit(index);
      setState(() {});
    }
  }

  // -------------------------------------------
  // Helpers
  // -------------------------------------------
  int _findIndexOfHabitById(Box box, String habitId) {
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data == null) continue;
      if (data['id'] == habitId) {
        return i;
      }
    }
    return -1;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _formatDate(DateTime d) {
    return '${d.day}.${d.month}.${d.year}';
  }

  String _dayOfWeekShort(DateTime date) {
    switch (date.weekday) {
      case 1: return 'M';
      case 2: return 'D';
      case 3: return 'M';
      case 4: return 'D';
      case 5: return 'F';
      case 6: return 'S';
      default:
        return 'S';
    }
  }

  String _weekdayToLetter(int wday) {
    // 1=Mo,...7=So
    switch (wday) {
      case 1: return 'Mo';
      case 2: return 'Di';
      case 3: return 'Mi';
      case 4: return 'Do';
      case 5: return 'Fr';
      case 6: return 'Sa';
      case 7: return 'So';
      default: return '?';
    }
  }
}
