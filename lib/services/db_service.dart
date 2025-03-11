// lib/services/db_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/data_models.dart';

class DBService {
  // ----------------------------------------
  // Namen der Hive-Boxen
  // ----------------------------------------
  static const String tasksBoxName = 'tasksBox';
  static const String journalBoxName = 'journalBox';
  static const String habitsBoxName = 'habitsBox';
  static const String flowSessionsBoxName = 'flow_sessions';
  static const String settingsBoxName = 'settings';

  final Uuid _uuid = const Uuid();

  // ----------------------------------------
  // TASKS
  // ----------------------------------------
  Box<Map> get _tasksBox => Hive.box<Map>(tasksBoxName);

  ValueListenable<Box<Map>> listenableTasks() {
    return _tasksBox.listenable();
  }

  Future<void> addTask(Map<String, dynamic> data) async {
    await _tasksBox.add(data);
  }

  Future<void> updateTask(int index, Map<String, dynamic> newData) async {
    await _tasksBox.putAt(index, newData);
  }

  Future<void> deleteTask(int index) async {
    await _tasksBox.deleteAt(index);
  }

  // ----------------------------------------
  // JOURNAL
  // ----------------------------------------
  Box<Map> get _journalBox => Hive.box<Map>(journalBoxName);

  ValueListenable<Box<Map>> listenableJournal() {
    return _journalBox.listenable();
  }

  Future<void> addJournalEntry(Map<String, dynamic> data) async {
    await _journalBox.add(data);
  }

  Future<void> updateJournalEntry(int index, Map<String, dynamic> newData) async {
    await _journalBox.putAt(index, newData);
  }

  Future<void> deleteJournalEntry(int index) async {
    await _journalBox.deleteAt(index);
  }

  // ----------------------------------------
  // HABIT TRACKER
  // ----------------------------------------
  Box<Map> get _habitsBox => Hive.box<Map>(habitsBoxName);

  ValueListenable<Box<Map>> listenableHabits() {
    return _habitsBox.listenable();
  }

  Future<void> addHabit(Map<String, dynamic> habitData) async {
    await _habitsBox.add(habitData);
  }

  Future<void> updateHabit(String id, Map<String, dynamic> newData) async {
    final index = _habitsBox.values
        .toList()
        .indexWhere((habit) => habit['id'] == id);
    if (index != -1) {
      await _habitsBox.putAt(index, newData);
    }
  }

  Future<void> deleteHabit(String id) async {
    final index = _habitsBox.values
        .toList()
        .indexWhere((habit) => habit['id'] == id);
    if (index != -1) {
      await _habitsBox.deleteAt(index);
    }
  }

  /// Speichert ein Habit – falls es bereits existiert, wird es aktualisiert.
  Future<void> saveHabit({
    required String id,
    required String name,
    required Map<String, bool?> dailyStatus,
    required List<int> weekdays,
    int? reminderHour,
    int? reminderMinute,
    String? category,
    int? colorValue,
  }) async {
    final existingIndex = _habitsBox.values
        .toList()
        .indexWhere((habit) => habit['id'] == id);

    final habitData = {
      'id': id,
      'name': name,
      'dailyStatus': dailyStatus,
      'weekdays': weekdays,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'category': category,
      'colorValue': colorValue,
    };

    if (existingIndex != -1) {
      await updateHabit(id, habitData);
    } else {
      await addHabit(habitData);
    }
  }

  // Gibt die Habit-Box zurück
  Box<Map> getHabitsBox() => _habitsBox;

  // ----------------------------------------
  // FLOW-SESSIONS (für WeeklyFlowSeconds)
  // ----------------------------------------
  Box<Map> get _flowSessionsBox => Hive.box<Map>(flowSessionsBoxName);

  /// Summiert alle Flow-Sessions (minutes * 60) zwischen [from] und [to]
  Future<int> getWeeklyFlowSeconds(DateTime from, DateTime to) async {
    final allMaps = _flowSessionsBox.values.toList();
    int totalSeconds = 0;
    for (var map in allMaps) {
      final dateMs = map['date'] as int?;
      final minutes = map['minutes'] as int?;
      if (dateMs == null || minutes == null) continue;
      final date = DateTime.fromMillisecondsSinceEpoch(dateMs);
      if (date.isAfter(_startOfDay(from).subtract(const Duration(seconds: 1))) &&
          date.isBefore(_endOfDay(to).add(const Duration(seconds: 1)))) {
        totalSeconds += (minutes * 60);
      }
    }
    return totalSeconds;
  }

  // ----------------------------------------
  // SETTINGS (z. B. Streak)
  // ----------------------------------------
  Box get _settingsBox => Hive.box(settingsBoxName);

  int getStreak() {
    return _settingsBox.get('streak', defaultValue: 0) as int;
  }

  void setStreak(int newVal) {
    _settingsBox.put('streak', newVal);
  }

  // ----------------------------------------
  // DAILY CHECKS
  // ----------------------------------------
  /// Speichert DailyChecks in der Settings-Box unter dem Key "dailyCheck_YYYY-MM-DD"
  Future<Map?> getDailyCheckMap(DateTime date) async {
    final key = _dailyCheckKey(date);
    return _settingsBox.get(key) as Map?;
  }

  Future<void> setDailyCheckMap(DateTime date, Map checkData) async {
    final key = _dailyCheckKey(date);
    await _settingsBox.put(key, checkData);
  }

  /// Gibt ein DailyCheckModel für den angegebenen Tag zurück.
  /// Dabei wird die Map geparst und der Parameter [date] separat gesetzt.
  Future<DailyCheckModel?> getTodayCheck(DateTime date) async {
    final raw = await getDailyCheckMap(date);
    if (raw == null) return null;
    // Cast raw zu Map<String, dynamic>
    return DailyCheckModel.fromMap(Map<String, dynamic>.from(raw), date: date);
  }

  Future<void> saveDailyCheck(DailyCheckModel model) async {
    final map = model.toMap();
    await setDailyCheckMap(model.date, map);
  }

  /// Erhöht den Streak um 1 (Platzhalter – hier kannst du deine Logik anpassen)
  void markDateAsCompleted(DateTime date) {
    final current = getStreak();
    setStreak(current + 1);
  }

  /// Lädt für jeden Tag in [weekDates] den entsprechenden DailyCheck
  Future<List<DailyCheckModel>> getWeekChecks(List<DateTime> weekDates) async {
    final result = <DailyCheckModel>[];
    for (var d in weekDates) {
      final check = await getTodayCheck(d);
      if (check != null) {
        result.add(check);
      } else {
        result.add(DailyCheckModel(date: d));
      }
    }
    return result;
  }

  // ----------------------------------------
  // HELPER-Funktionen
  // ----------------------------------------
  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59);

  String _dailyCheckKey(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return 'dailyCheck_${y}-${m}-${d}';
  }
}
