// lib/pages/training_plan.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'subscription_page.dart';
import '../l10n/generated/l10n.dart';

/// Model: Übung mit Details
class Exercise {
  String name;
  int? sets;
  int? reps;
  double? weight;

  Exercise({required this.name, this.sets, this.reps, this.weight});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] as String,
      sets: map['sets'] != null ? map['sets'] as int : null,
      reps: map['reps'] != null ? map['reps'] as int : null,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
    );
  }
}

/// Model: Tag-Workout, enthält den Workout-Namen und eine Liste von Übungen
class DayWorkout {
  String workoutName;
  List<Exercise> exercises;

  DayWorkout({required this.workoutName, List<Exercise>? exercises})
      : exercises = exercises ?? [];

  Map<String, dynamic> toMap() {
    return {
      'workoutName': workoutName,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory DayWorkout.fromMap(Map<String, dynamic> map) {
    return DayWorkout(
      workoutName: map['workoutName'] as String,
      exercises: map['exercises'] != null
          ? List<Exercise>.from((map['exercises'] as List)
              .map((x) => Exercise.fromMap(Map<String, dynamic>.from(x))))
          : [],
    );
  }
}

class TrainingPlanPage extends StatefulWidget {
  const TrainingPlanPage({Key? key}) : super(key: key);

  @override
  _TrainingPlanPageState createState() => _TrainingPlanPageState();
}

class _TrainingPlanPageState extends State<TrainingPlanPage>
    with SingleTickerProviderStateMixin {
  // Standard-Wochenplan (editierbar durch den User)
  List<DayWorkout> _weekPlan = [
    DayWorkout(workoutName: "Push"),
    DayWorkout(workoutName: "Pull"),
    DayWorkout(workoutName: "Legs"),
    DayWorkout(workoutName: "Shoulders"),
    DayWorkout(workoutName: "Core"),
    DayWorkout(workoutName: "Cardio"),
    DayWorkout(workoutName: "Rest"),
  ];

  late TabController _tabController;
  late List<TextEditingController> _workoutNameControllers;
  late List<TextEditingController> _exerciseControllers;
  late Box _trainingPlanBox;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _weekPlan.length, vsync: this);
    _workoutNameControllers = List.generate(
      _weekPlan.length,
      (index) => TextEditingController(text: _weekPlan[index].workoutName),
    );
    _exerciseControllers =
        List.generate(_weekPlan.length, (index) => TextEditingController());
    _trainingPlanBox = Hive.box('trainingPlanBox');
    _loadTrainingPlan();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _workoutNameControllers) {
      controller.dispose();
    }
    for (var controller in _exerciseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Lädt den gespeicherten Trainingsplan aus Hive
  void _loadTrainingPlan() {
    final data = _trainingPlanBox.get('weekPlan');
    if (data != null) {
      List<dynamic> list = data;
      setState(() {
        _weekPlan = list
            .map((e) => DayWorkout.fromMap(Map<String, dynamic>.from(e)))
            .toList();
        // Update der Workout-Namen-Controller
        for (int i = 0; i < _weekPlan.length; i++) {
          _workoutNameControllers[i].text = _weekPlan[i].workoutName;
        }
      });
    }
  }

  // Speichert den Trainingsplan in Hive
  void _saveTrainingPlan() {
    final list = _weekPlan.map((day) => day.toMap()).toList();
    _trainingPlanBox.put('weekPlan', list);
  }

  // Fügt eine neue Übung (als Exercise) hinzu
  void _addExercise(int dayIndex, S s) {
    final text = _exerciseControllers[dayIndex].text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.addExerciseSnackbar)),
      );
      return;
    }
    setState(() {
      _weekPlan[dayIndex].exercises.add(Exercise(name: text));
      _exerciseControllers[dayIndex].clear();
      _saveTrainingPlan();
    });
  }

  void _removeExercise(int dayIndex, int exerciseIndex) {
    setState(() {
      _weekPlan[dayIndex].exercises.removeAt(exerciseIndex);
      _saveTrainingPlan();
    });
  }

  void _reorderExercise(int dayIndex, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _weekPlan[dayIndex].exercises.removeAt(oldIndex);
      _weekPlan[dayIndex].exercises.insert(newIndex, item);
      _saveTrainingPlan();
    });
  }

  // Dialog zum Bearbeiten der Übungsdetails – Felder sind editierbar, wenn Premium,
  // sonst ausgegraut mit Schloss-Icon und "Hol Premium"-Button.
  void _showExerciseDetailsDialog(int dayIndex, int exerciseIndex, S s) {
    final exercise = _weekPlan[dayIndex].exercises[exerciseIndex];
    final bool isPremium =
        Hive.box('settings').get('isPremium', defaultValue: false);
    final TextEditingController setsController =
        TextEditingController(text: exercise.sets?.toString() ?? "");
    final TextEditingController repsController =
        TextEditingController(text: exercise.reps?.toString() ?? "");
    final TextEditingController weightController =
        TextEditingController(text: exercise.weight?.toString() ?? "");
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(s.editExerciseTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: setsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: s.setsLabel,
                  suffixIcon: isPremium
                      ? null
                      : const Icon(Icons.lock, color: Colors.grey),
                ),
                enabled: isPremium,
              ),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: s.repsLabel,
                  suffixIcon: isPremium
                      ? null
                      : const Icon(Icons.lock, color: Colors.grey),
                ),
                enabled: isPremium,
              ),
              TextField(
                controller: weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: s.weightLabel,
                  suffixIcon: isPremium
                      ? null
                      : const Icon(Icons.lock, color: Colors.grey),
                ),
                enabled: isPremium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancelButton),
            ),
            ElevatedButton(
              onPressed: () {
                if (isPremium) {
                  setState(() {
                    exercise.sets = int.tryParse(setsController.text);
                    exercise.reps = int.tryParse(repsController.text);
                    exercise.weight = double.tryParse(weightController.text);
                    _saveTrainingPlan();
                  });
                  Navigator.pop(ctx);
                } else {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                  );
                }
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 223, 27, 27)),
              child: Text(isPremium ? s.saveButton : s.getPremiumButton),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    // Nutzt die tabLabels aus der Lokalisierung
    final List<String> tabLabels = ["M", "T", "W", "T", "F", "S", "S"];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(s.appTitle),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color.fromARGB(255, 223, 27, 27),
          tabs: tabLabels
              .map((label) => Tab(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(_weekPlan.length, (dayIndex) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Editierbarer Workout-Namen
                Card(
                  color: Colors.grey.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _workoutNameControllers[dayIndex],
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: s.workoutNameLabel,
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        _weekPlan[dayIndex].workoutName = value;
                        _saveTrainingPlan();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Liste der Übungen für den Tag
                Expanded(
                  child: _weekPlan[dayIndex].exercises.isEmpty
                      ? Center(
                          child: Text(
                            s.noExercisesMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16),
                          ),
                        )
                      : ReorderableListView(
                          onReorder: (oldIndex, newIndex) =>
                              _reorderExercise(dayIndex, oldIndex, newIndex),
                          children: List.generate(
                              _weekPlan[dayIndex].exercises.length,
                              (exerciseIndex) {
                            final exercise =
                                _weekPlan[dayIndex].exercises[exerciseIndex];
                            return Card(
                              key: ValueKey(
                                  "day${dayIndex}_exercise_$exerciseIndex"),
                              color: Colors.grey.shade800,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  exercise.name,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Details-Button – öffnet den Dialog, in dem die Felder
                                    // sichtbar, aber nur für Premium editierbar sind.
                                    IconButton(
                                      icon: const Icon(Icons.info,
                                          color: Color.fromARGB(255, 223, 27, 27)),
                                      onPressed: () =>
                                          _showExerciseDetailsDialog(
                                              dayIndex, exerciseIndex, s),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Color.fromARGB(255, 223, 27, 27)),
                                      onPressed: () => _removeExercise(
                                          dayIndex, exerciseIndex),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                ),
                const SizedBox(height: 8),
                // Eingabefeld zum Hinzufügen einer neuen Übung
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _exerciseControllers[dayIndex],
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: s.newExerciseHint,
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _addExercise(dayIndex, s),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _addExercise(dayIndex, s),
                        icon: const Icon(Icons.add, color: Color.fromARGB(255, 223, 27, 27)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
