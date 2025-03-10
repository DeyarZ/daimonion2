import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class DBService {
  // Name der Hive-Boxen
  static const String tasksBoxName = 'tasksBox';
  static const String journalBoxName = 'journalBox';
  static const String habitsBoxName = 'habitsBox';

  final Uuid _uuid = const Uuid();

  // ---------- TASKS --------------------
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

  // ---------- JOURNAL --------------------
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

  // ---------- HABIT TRACKER --------------------
  Box<Map> get _habitsBox => Hive.box<Map>(habitsBoxName);

  ValueListenable<Box<Map>> listenableHabits() {
    return _habitsBox.listenable();
  }

  Future<void> addHabit(Map<String, dynamic> habitData) async {
    await _habitsBox.add(habitData);
  }

  Future<void> updateHabit(String id, Map<String, dynamic> newData) async {
    int index = _habitsBox.values.toList().indexWhere((habit) => habit['id'] == id);
    if (index != -1) {
      await _habitsBox.putAt(index, newData);
    }
  }

  Future<void> deleteHabit(String id) async {
    int index = _habitsBox.values.toList().indexWhere((habit) => habit['id'] == id);
    if (index != -1) {
      await _habitsBox.deleteAt(index);
    }
  }

  /// **Neu: `saveHabit()`**
  /// Diese Methode überprüft, ob das Habit bereits existiert.
  /// - Falls ja, wird es aktualisiert.
  /// - Falls nein, wird es neu gespeichert.
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
    final existingIndex = _habitsBox.values.toList().indexWhere((habit) => habit['id'] == id);

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

  // Methode zum Abrufen der Habit-Box (optional)
  Box<Map> getHabitsBox() => _habitsBox;
}
