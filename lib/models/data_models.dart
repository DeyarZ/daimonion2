// lib/models/data_models.dart

class FlowSession {
  final DateTime date;
  final int minutes;
  FlowSession({required this.date, required this.minutes});
}

class Task {
  final String id;
  String title;
  bool completed;
  DateTime deadline;
  // Optionale Felder:
  String? description;
  int? priority;
  List<String>? tags; // Neu: Tags hinzufügen

  Task({
    required this.id,
    required this.title,
    this.completed = false,
    required this.deadline,
    this.description,
    this.priority,
    this.tags = const [],
  });
}


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

  bool isCompletedForDate(DateTime date) {
    final key = _formatDateKey(date);
    return dailyStatus[key] == true;
  }

  String _formatDateKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

/// Die DailyCheckModel speichert z. B. tägliche Fortschritte (Fundamentals)
class DailyCheckModel {
  /// Wir fordern hier einen Parameter "date" – also immer mit "date:" angeben!
  DateTime date;
  bool gym;
  bool mental;
  bool noPorn;
  bool healthyEating;
  bool helpOthers;
  bool natureTime;

  DailyCheckModel({
    required this.date,
    this.gym = false,
    this.mental = false,
    this.noPorn = false,
    this.healthyEating = false,
    this.helpOthers = false,
    this.natureTime = false,
  });

  /// Erzeugt ein DailyCheckModel aus einer Map.
  /// Der Parameter [date] muss separat übergeben werden.
  factory DailyCheckModel.fromMap(Map<String, dynamic> map, {required DateTime date}) {
    return DailyCheckModel(
      date: date,
      gym: map['gym'] ?? false,
      mental: map['mental'] ?? false,
      noPorn: map['noPorn'] ?? false,
      healthyEating: map['healthyEating'] ?? false,
      helpOthers: map['helpOthers'] ?? false,
      natureTime: map['natureTime'] ?? false,
    );
  }

  /// Konvertiert das Model in eine Map zum Speichern in Hive.
  Map<String, dynamic> toMap() {
    return {
      'gym': gym,
      'mental': mental,
      'noPorn': noPorn,
      'healthyEating': healthyEating,
      'helpOthers': helpOthers,
      'natureTime': natureTime,
    };
  }

  /// Prüft, ob alle Fundamentals erledigt sind.
  bool allCompleted() {
    return gym && mental && noPorn && healthyEating && helpOthers && natureTime;
  }

  /// Zählt, wie viele Fundamentals erledigt sind.
  int getCompletedCount() {
    int count = 0;
    if (gym) count++;
    if (mental) count++;
    if (noPorn) count++;
    if (healthyEating) count++;
    if (helpOthers) count++;
    if (natureTime) count++;
    return count;
  }
}
