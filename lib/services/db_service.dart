import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart'; // Falls noch nicht importiert

class DBService {
  // Tasks
  static const String tasksBoxName = 'tasksBox';

  // Journal
  static const String journalBoxName = 'journalBox';

  // Habit Tracker
  static const String habitsBoxName = 'habitsBox';

  final Uuid _uuid = const Uuid(); // Initialisiere eine Uuid-Instanz

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

  // ---------- HABITS --------------------
  Box<Map> get _habitsBox => Hive.box<Map>(habitsBoxName);

  ValueListenable<Box<Map>> listenableHabits() {
    return _habitsBox.listenable();
  }

  Future<void> addHabit(Map<String, dynamic> habitData) async {
    await _habitsBox.add(habitData);
  }

  Future<void> updateHabit(int index, Map<String, dynamic> newData) async {
    await _habitsBox.putAt(index, newData);
  }

  Future<void> deleteHabit(int index) async {
    await _habitsBox.deleteAt(index);
  }

  // **Neue Methode hinzugefügt**
  Box<Map> getHabitsBox() => _habitsBox;

  // ... (Weitere Methoden nach Bedarf) ...
}



/*
Warum Map<String,dynamic> statt Task-Objekt?
Damit du keine Hive-Adapter-Schreiberei brauchst. 
Du kannst gerne später einen Hive-Adapter für dein 
Task-Model definieren und die Instanzen direkt speichern. 
Aber für dein MVP reicht’s, Tasks als Map reinzuwerfen.
*/
