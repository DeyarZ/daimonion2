import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMob import
import 'package:uuid/uuid.dart';
import '../services/db_service.dart';

// -------------------------------------------
// Model-Klasse: Habit
// -------------------------------------------
class Habit {
  String id;
  String name;
  Map<String, bool?> dailyStatus; 
  List<int> selectedWeekdays;

  Habit({
    required this.id,
    required this.name,
    required this.dailyStatus,
    required this.selectedWeekdays,
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

  // Neue Variablen für Ads
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  late List<DateTime> days;
  late DateTime today;

  @override
  void initState() {
    super.initState();
    today = _truncateToDate(DateTime.now());
    days = _generate7Days(today);

    // AdMob Banner laden
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd.dispose(); // Ad-Objekt sauber entfernen
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2524075415669673~7860955987', // Deine Anzeigenblock-ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Heute: ${_formatDate(today)}',
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
                      return const Center(
                        child: Text(
                          'Noch keine Gewohnheiten',
                          style: TextStyle(color: Colors.white),
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
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[900]),
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
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
                          ...List.generate(habits.length, (rowIndex) {
                            final habit = habits[rowIndex];
                            return TableRow(
                              decoration: BoxDecoration(color: Colors.grey[850]),
                              children: [
                                GestureDetector(
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
          if (_isAdLoaded)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
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

  // --------------------------------------------------------------
  // Box -> List<Habit>
  // --------------------------------------------------------------
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
      // cast to List<int>
      final selectedWeekdays = sw.map((x) => x as int).toList();

      list.add(Habit(
        id: id,
        name: name,
        dailyStatus: dailyStatus,
        selectedWeekdays: selectedWeekdays,
      ));
    }
    return list;
  }

  // --------------------------------------------------------------
  // Toggle => per ID in Box suchen -> dailyStatus updaten
  // --------------------------------------------------------------
  Future<void> _toggleHabitStatus(Habit habit, String dayKey) async {
    final box = Hive.box<Map>(DBService.habitsBoxName);

    // 1) Finde index via ID
    final index = _findIndexOfHabitById(box, habit.id);
    if (index == -1) return;

    // 2) Toggle
    final current = habit.dailyStatus[dayKey];
    bool? newVal = (current == true) ? false : true;
    habit.dailyStatus[dayKey] = newVal;

    // 3) Box updaten
    final newData = {
      'id': habit.id,
      'name': habit.name,
      'dailyStatus': habit.dailyStatus,
      'selectedWeekdays': habit.selectedWeekdays,
    };
    await _dbService.updateHabit(index, newData);

    setState(() {});
  }

  // --------------------------------------------------------------
  // Neuer Habit => ID + Name + dailyStatus=null + user wählt Wochentage
  // --------------------------------------------------------------
  void _addHabit() {
    TextEditingController controller = TextEditingController();

    // 1..7 => "Mo","Di",...
    final weekdaysMap = {
      1: 'M',
      2: 'D',
      3: 'M',
      4: 'D',
      5: 'F',
      6: 'S',
      7: 'S',
    };

    final selectedDays = <int>{}; // leer

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Neue Gewohnheit'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TextField Name
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  // Wochentage-Auswahl
                  Wrap(
                    spacing: 8,
                    children: weekdaysMap.entries.map((entry) {
                      final wday = entry.key;    
                      final label = entry.value; 
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
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () async {
                final newHabitName = controller.text.trim();
                if (newHabitName.isNotEmpty && selectedDays.isNotEmpty) {
                  // dailyMap => nur für days, wo day.weekday in selectedDays
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
                  };

                  await _dbService.addHabit(newData);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------------------
  // Delete Habit
  // --------------------------------------------------------------
  void _confirmDeleteHabit(Habit habit) async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Löschen?'),
          content: Text('Möchtest du die Gewohnheit "${habit.name}" wirklich löschen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteHabit(habit);
                Navigator.pop(ctx);
              },
              child: const Text('Ja, löschen'),
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
      await _dbService.deleteHabit(index);
      setState(() {});
    }
  }

  // --------------------------------------------------------------
  // Hilfsfunktionen
  // --------------------------------------------------------------
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
}