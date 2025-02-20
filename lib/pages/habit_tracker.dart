// lib/pages/habit_tracker.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

// Services
import '../services/db_service.dart';
import '../services/gamification_service.dart';

// Notification-Funktionen
import 'package:daimonion_app/main.dart'
    show scheduleHabitNotifications, cancelHabitNotifications;

// Lokalisierung
import '../l10n/generated/l10n.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Model-Klasse: Habit
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Habit {
  String id;
  String name;
  Map<String, bool?> dailyStatus;
  List<int> selectedWeekdays;
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

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Haupt-Klasse: HabitTrackerPage
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class HabitTrackerPage extends StatefulWidget {
  const HabitTrackerPage({Key? key}) : super(key: key);

  @override
  _HabitTrackerPageState createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage> {
  final DBService _dbService = DBService();
  final _uuid = const Uuid();

  late DateTime today;
  late List<DateTime> days; // -3 .. +3

  @override
  void initState() {
    super.initState();
    today = _truncateToDate(DateTime.now());
    days = _generate7Days(today); 
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // BUILD
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.habitTrackerTitle),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                '${loc.todayLabel} ${_formatDate(today)}',
                style: const TextStyle(
                  color: Color.fromARGB(255, 223, 27, 27),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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

                    // ListView => Für jede Habit ein Dismissible-Element
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        return Dismissible(
                          key: Key(habit.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (dir) async {
                            return await _confirmDeleteHabit(habit);
                          },
                          onDismissed: (_) async {
                            // Wenn confirmDismiss true => hier wird wirklich gelöscht
                            await _deleteHabit(habit);
                          },
                          child: _buildHabitCard(habit),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 223, 27, 27),
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 1) HABIT-CARD
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildHabitCard(Habit habit) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color.fromARGB(255, 44, 44, 44), const Color.fromARGB(255, 48, 48, 48)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ~ Title
          Text(
            habit.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // ~ Row der 7 Tage-Kreise
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: days.map((day) {
                final isRelevant = habit.selectedWeekdays.contains(day.weekday);
                if (!isRelevant) {
                  // Grauer, inaktiver Kreis
                  return _buildDayCircle(
                    day,
                    color: Colors.grey.shade700,
                    icon: null,
                    clickable: false,
                  );
                }

                final dayKey = _formatDateKey(day);
                final currentStatus = habit.dailyStatus[dayKey];
                final isPastOrToday =
                    day.isBefore(today) || _isSameDay(day, today);

                if (currentStatus == true) {
                  return _buildDayCircle(
                    day,
                    color: Colors.green,
                    icon: Icons.check,
                    clickable: isPastOrToday,
                    onTap: () => _toggleHabitStatus(habit, dayKey),
                  );
                } else if (currentStatus == false && isPastOrToday) {
                  return _buildDayCircle(
                    day,
                    color: const Color.fromARGB(255, 223, 27, 27),
                    icon: Icons.close,
                    clickable: true,
                    onTap: () => _toggleHabitStatus(habit, dayKey),
                  );
                } else {
                  // null => no data, or future
                  return _buildDayCircle(
                    day,
                    color: isPastOrToday ? Colors.grey : Colors.grey.shade700,
                    icon: Icons.circle_outlined,
                    clickable: isPastOrToday,
                    onTap: () => _toggleHabitStatus(habit, dayKey),
                  );
                }
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 2) DAY-CIRCLE
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildDayCircle(
    DateTime day, {
    required Color color,
    required IconData? icon,
    bool clickable = false,
    VoidCallback? onTap,
  }) {
    final isToday = _isSameDay(day, today);
    final dayLabel = _dayOfWeekLetter(day.weekday); 
    final dayNumber = day.day.toString();

    return GestureDetector(
      onTap: clickable ? onTap : null,
      child: Container(
        width: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Text(
              dayLabel,
              style: TextStyle(
                color: isToday ? Colors.yellow : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(icon == null ? 0.4 : 0.8),
              ),
              child: icon != null
                  ? Icon(icon, color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(height: 2),
            Text(
              dayNumber,
              style: TextStyle(
                color: isToday ? Colors.yellow : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 3) ADD HABIT
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void _addHabit() {
    final controller = TextEditingController();
    final selectedDays = <int>{};
    int? chosenHour;
    int? chosenMinute;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            S.of(ctx).newHabitTitle,
            style: const TextStyle(color: Colors.white),
          ),
          content: StatefulBuilder(
            builder: (ctx, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Habit-Name
                    TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: S.of(ctx).newHabitNameHint,
                        hintStyle: const TextStyle(color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Wochentage-Auswahl => showCheckmark: false => keine Größenänderung
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (i) {
                        final wday = i + 1; // Mo=1,...So=7
                        final label = _dayOfWeekLetter(wday);
                        final isSelected = selectedDays.contains(wday);

                        return ChoiceChip(
                          label: Text(label, style: const TextStyle(fontSize: 14)),
                          selected: isSelected,
                          selectedColor: const Color.fromARGB(255, 223, 27, 27),
                          showCheckmark: false,  // <--- WICHTIG
                          onSelected: (val) {
                            setStateDialog(() {
                              if (val) {
                                selectedDays.add(wday);
                              } else {
                                selectedDays.remove(wday);
                              }
                            });
                          },
                        );
                      }),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          S.of(ctx).reminderLabel,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 223, 27, 27),
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
                                ? S.of(ctx).noReminder
                                : '${chosenHour!.toString().padLeft(2, '0')}:${chosenMinute!.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.white),
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
              child: Text(
                S.of(ctx).cancel,
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.pop(ctx),
            ),
            TextButton(
              child: Text(
                S.of(ctx).ok,
                style: const TextStyle(color: Color.fromARGB(255, 223, 27, 27)),
              ),
              onPressed: () async {
                final newHabitName = controller.text.trim();
                if (newHabitName.isNotEmpty && selectedDays.isNotEmpty) {
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

                  // DB-Speichern
                  await _dbService.addHabit(newData);

                  // Notifs
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
            ),
          ],
        );
      },
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 4) DELETE => VIA SWIPE
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  /// confirmDismiss() => zeigt 'Willst du wirklich löschen?' an
  Future<bool> _confirmDeleteHabit(Habit habit) async {
    final loc = S.of(context);

    return await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            loc.deleteHabitTitle,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            loc.deleteHabitMessage(habit.name),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: Text(
                loc.cancel,
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.pop(ctx, false),
            ),
            TextButton(
              child: Text(
                loc.confirmDeleteHabit,
                style: const TextStyle(color: Color.fromARGB(255, 223, 27, 27)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        );
      },
    ) ?? false; // Falls user abbricht
  }

  /// Eigentlicher Löschvorgang => onDismissed
  Future<void> _deleteHabit(Habit habit) async {
    final box = Hive.box<Map>(DBService.habitsBoxName);
    final index = _findIndexOfHabitById(box, habit.id);
    if (index != -1) {
      // Falls reminder => Notifs canceln
      if (habit.reminderHour != null && habit.reminderMinute != null) {
        cancelHabitNotifications(habit.id, habit.selectedWeekdays.toSet());
      }
      await _dbService.deleteHabit(index);
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 5) TOGGLE
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Future<void> _toggleHabitStatus(Habit habit, String dayKey) async {
    final box = Hive.box<Map>(DBService.habitsBoxName);
    final index = _findIndexOfHabitById(box, habit.id);
    if (index == -1) return;

    final current = habit.dailyStatus[dayKey];
    final newVal = (current == true) ? false : true;
    habit.dailyStatus[dayKey] = newVal;

    // Speichern
    final updatedData = {
      'id': habit.id,
      'name': habit.name,
      'dailyStatus': habit.dailyStatus,
      'selectedWeekdays': habit.selectedWeekdays,
      'reminderHour': habit.reminderHour,
      'reminderMinute': habit.reminderMinute,
    };
    await _dbService.updateHabit(index, updatedData);

    // XP => wenn wir jetzt auf "erledigt" togglen
    if (newVal == true && current != true) {
      _awardDailyHabitXP();
    }

    setState(() {});
  }

  Future<void> _awardDailyHabitXP() async {
    final settingsBox = Hive.box('settings');
    final now = DateTime.now();
    final todayString = '${now.year}-${now.month}-${now.day}';

    final storedDate = settingsBox.get('habitXpDay', defaultValue: '');
    var dailyCount = settingsBox.get('habitXpCount', defaultValue: 0) as int;

    if (storedDate != todayString) {
      dailyCount = 0;
      settingsBox.put('habitXpDay', todayString);
      settingsBox.put('habitXpCount', dailyCount);
    }

    if (dailyCount < 5) {
      GamificationService().addXPWithStreak(1);
      dailyCount++;
      settingsBox.put('habitXpCount', dailyCount);
      final left = 5 - dailyCount;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "+1 XP! ($dailyCount/5 $left left today.)",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Limit reached!",
          ),
        ),
      );
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // UTILS
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _truncateToDate(DateTime d) => DateTime(d.year, d.month, d.day);

  List<DateTime> _generate7Days(DateTime center) {
    final List<DateTime> result = [];
    for (int i = -3; i <= 3; i++) {
      result.add(_truncateToDate(center.add(Duration(days: i))));
    }
    return result;
  }

  List<Habit> _boxToHabitList(Box box) {
    final List<Habit> list = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data == null) continue;

      final id = data['id'] as String? ?? 'no-id-$i';
      final name = data['name'] as String? ?? 'Unnamed Habit';

      final dsMap = data['dailyStatus'] as Map?;
      final Map<String, bool?> dailyStatus = {};
      dsMap?.forEach((k, v) {
        dailyStatus[k.toString()] = v as bool?;
      });

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

  String _formatDate(DateTime d) => '${d.day}.${d.month}.${d.year}';

  String _formatDateKey(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  // z.B. 'M', 'T', 'W', ...
  String _dayOfWeekLetter(int weekday) {
    switch (weekday) {
      case 1:
        return 'M';
      case 2:
        return 'T';
      case 3:
        return 'W';
      case 4:
        return 'T';
      case 5:
        return 'F';
      case 6:
        return 'S';
      default:
        return 'S';
    }
  }
}
