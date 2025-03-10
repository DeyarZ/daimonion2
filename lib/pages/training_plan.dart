import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../l10n/generated/l10n.dart';

// Modelle
class Exercise {
  String name;
  int? sets;
  int? reps;
  double? weight;
  String? notes;

  Exercise({
    required this.name,
    this.sets,
    this.reps,
    this.weight,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'notes': notes,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] == null ? "" : map['name'] as String,
      sets: map['sets'] as int?,
      reps: map['reps'] as int?,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      notes: map['notes'] as String?,
    );
  }
}

class Workout {
  String dayName;       // z. B. "Mo", "Di", …
  String workoutName;   // z. B. "Push", "Legs", …
  List<Exercise> exercises;
  Color? color;

  Workout({
    required this.dayName,
    required this.workoutName,
    List<Exercise>? exercises,
    this.color,
  }) : exercises = exercises ?? [];

  Map<String, dynamic> toMap() {
    return {
      'dayName': dayName,
      'workoutName': workoutName,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'color': color?.value,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      dayName: map['dayName'] == null ? "" : map['dayName'] as String,
      workoutName: map['workoutName'] == null ? "" : map['workoutName'] as String,
      exercises: map['exercises'] != null
          ? List<Exercise>.from((map['exercises'] as List)
              .map((x) => Exercise.fromMap(Map<String, dynamic>.from(x))))
          : [],
      color: map['color'] != null ? Color(map['color'] as int) : null,
    );
  }
}

class TrainingPlanPage extends StatefulWidget {
  const TrainingPlanPage({Key? key}) : super(key: key);

  @override
  _TrainingPlanPageState createState() => _TrainingPlanPageState();
}

class _TrainingPlanPageState extends State<TrainingPlanPage>
    with TickerProviderStateMixin {
  late Box _trainingPlanBox;
  late List<Workout> _weekPlan;

  TabController? _tabController;

  int _currentDayIndex = 0;
  final TextEditingController _newExerciseController = TextEditingController();
  final TextEditingController _workoutNameController = TextEditingController();

  // Für inline Workout-Name Bearbeitung
  bool _isEditingWorkoutName = false;

  // Default day names für die Tabs
  final List<String> _defaultDayNames = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  final List<Color> _colorOptions = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
  ];

  bool get isPremium =>
      Hive.box('settings').get('isPremium', defaultValue: false);

  @override
  void initState() {
    super.initState();
    _trainingPlanBox = Hive.box('trainingPlanBox');
    _loadTrainingPlan();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _newExerciseController.dispose();
    _workoutNameController.dispose();
    super.dispose();
  }

  void _loadTrainingPlan() {
    final data = _trainingPlanBox.get('weekPlan');
    if (data != null) {
      List<dynamic> list = data;
      _weekPlan = list
          .map((e) => Workout.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      if (_weekPlan.isEmpty) {
        // Ersten Tag erstellen mit default dayName und leerem workoutName
        _weekPlan.add(
          Workout(
            dayName: _defaultDayNames[0],
            workoutName: "",
            color: _colorOptions[0],
          ),
        );
        _saveTrainingPlan();
      }
    } else {
      // Standard-Tage erstellen: Tag-Name aus _defaultDayNames, workoutName leer
      _weekPlan = List.generate(
        7,
        (index) => Workout(
          dayName: _defaultDayNames[index],
          workoutName: "",
          color: _colorOptions[index % _colorOptions.length],
        ),
      );
      _saveTrainingPlan();
    }
    _currentDayIndex = 0;
    _updateWorkoutNameController();
    _setupTabController();
  }

  void _saveTrainingPlan() {
    final list = _weekPlan.map((day) => day.toMap()).toList();
    _trainingPlanBox.put('weekPlan', list);
  }

  void _setupTabController() {
    _tabController?.dispose();

    final length = _weekPlan.isEmpty ? 1 : _weekPlan.length;

    _tabController = TabController(
      length: length,
      vsync: this,
      initialIndex: _currentDayIndex.clamp(0, length - 1),
    );

    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        setState(() {
          _currentDayIndex = _tabController!.index;
          _updateWorkoutNameController();
        });
      }
    });

    if (_currentDayIndex >= length) {
      setState(() {
        _currentDayIndex = length - 1;
      });
    }
  }

  void _updateWorkoutNameController() {
    if (_weekPlan.isNotEmpty) {
      _workoutNameController.text = _weekPlan[_currentDayIndex].workoutName;
    }
  }

  void _addNewDay() {
    setState(() {
      // Nutze Lokalisierung für "New Day" und "Day {number}" (Aufruf der generierten Methode!)
      String newDayName = S.of(context).newDay;
      if (_weekPlan.length < _defaultDayNames.length) {
        newDayName = _defaultDayNames[_weekPlan.length];
      } else {
        newDayName = S.of(context).day(_weekPlan.length + 1);
      }
      
      _weekPlan.add(
        Workout(
          dayName: newDayName,
          workoutName: "",
          color: _colorOptions[_weekPlan.length % _colorOptions.length],
        ),
      );
      _saveTrainingPlan();
      _setupTabController();
      _tabController!.index = _weekPlan.length - 1;
      _updateWorkoutNameController();
    });
  }

  void _deleteDay(int index) {
    if (_weekPlan.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).atLeastOneWorkoutDay),
        ),
      );
      return;
    }

    setState(() {
      _weekPlan.removeAt(index);
      _saveTrainingPlan();
      if (_currentDayIndex >= _weekPlan.length) {
        _currentDayIndex = _weekPlan.length - 1;
      }
      _setupTabController();
    });
  }

  void _addExercise() {
    if (_newExerciseController.text.isEmpty) return;

    setState(() {
      _weekPlan[_currentDayIndex].exercises.add(
        Exercise(name: _newExerciseController.text),
      );
      _saveTrainingPlan();
      _newExerciseController.clear();
    });
  }

  void _showExerciseDetailDialog(Exercise exercise) {
    final TextEditingController nameController =
        TextEditingController(text: exercise.name);
    final TextEditingController setsController =
        TextEditingController(text: exercise.sets?.toString() ?? "");
    final TextEditingController repsController =
        TextEditingController(text: exercise.reps?.toString() ?? "");
    final TextEditingController weightController =
        TextEditingController(text: exercise.weight?.toString() ?? "");
    final TextEditingController notesController =
        TextEditingController(text: exercise.notes ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).exerciseDetails,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: S.of(context).exerciseName,
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                onChanged: (value) {
                  exercise.name = value;
                  _saveTrainingPlan();
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: S.of(context).setsLabel,
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabled: isPremium,
                      ),
                      onChanged: (value) {
                        exercise.sets = int.tryParse(value);
                        _saveTrainingPlan();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: S.of(context).repsLabel,
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabled: isPremium,
                      ),
                      onChanged: (value) {
                        exercise.reps = int.tryParse(value);
                        _saveTrainingPlan();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: S.of(context).weightLabel,
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabled: isPremium,
                ),
                onChanged: (value) {
                  exercise.weight = double.tryParse(value);
                  _saveTrainingPlan();
                },
              ),
              if (!isPremium)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.lock, size: 16, color: Colors.amber[400]),
                      const SizedBox(width: 8),
                      Text(
                        S.of(context).premiumRequired,
                        style:
                            TextStyle(color: Colors.amber[400], fontSize: 12),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/premium');
                        },
                        child: Text(
                          S.of(context).upgradeToPremium,
                          style: TextStyle(
                            color: Colors.amber[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: S.of(context).notes,
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabled: isPremium,
                ),
                onChanged: (value) {
                  exercise.notes = value;
                  _saveTrainingPlan();
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      S.of(context).close,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          S.of(context).chooseWorkoutColor,
          style: const TextStyle(color: Colors.white),
        ),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _colorOptions.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _weekPlan[_currentDayIndex].color = color;
                  _saveTrainingPlan();
                  Navigator.pop(context);
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _weekPlan[_currentDayIndex].color == color
                        ? Colors.white
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDayNameDialog(int index) {
    final TextEditingController dayNameController =
        TextEditingController(text: _weekPlan[index].dayName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          S.of(context).editDayTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: dayNameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: S.of(context).newDayNameHint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              S.of(context).cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _weekPlan[index].dayName = dayNameController.text.trim();
                _saveTrainingPlan();
              });
              Navigator.pop(context);
            },
            child: Text(
              S.of(context).save,
              style: TextStyle(color: const Color.fromARGB(255, 223, 27, 27)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHeader(Workout workout, Color workoutColor) {
    if (_isEditingWorkoutName) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              workoutColor.withOpacity(0.7),
              workoutColor.withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _workoutNameController,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: S.of(context).workoutNameHint,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: () {
                setState(() {
                  _weekPlan[_currentDayIndex].workoutName =
                      _workoutNameController.text.trim();
                  _saveTrainingPlan();
                  _isEditingWorkoutName = false;
                });
              },
            )
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isEditingWorkoutName = true;
            _workoutNameController.text = workout.workoutName;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                workoutColor.withOpacity(0.7),
                workoutColor.withOpacity(0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.workoutName.isEmpty
                          ? S.of(context).noWorkoutName
                          : workout.workoutName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${workout.exercises.length} Exercises",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                onPressed: () {
                  setState(() {
                    _isEditingWorkoutName = true;
                    _workoutNameController.text = workout.workoutName;
                  });
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  List<Widget> _buildWeekdayTabs() {
    return List.generate(
      _weekPlan.length,
      (index) {
        final workout = _weekPlan[index];
        return Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  _showDayNameDialog(index);
                },
                child: const Icon(
                  Icons.edit,
                  size: 16,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  workout.dayName.isEmpty ? "Day ${index + 1}" : workout.dayName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  _deleteDay(index);
                },
                child: const Icon(
                  Icons.close,
                  size: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(S s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            s.noExercisesMessage,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            s.tapToAddExercises,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(Workout workout, S s) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: workout.exercises.length,
      itemBuilder: (context, index) {
        final exercise = workout.exercises[index];
        return Slidable(
          key: ValueKey(index),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            dismissible: DismissiblePane(
              onDismissed: () {
                setState(() {
                  workout.exercises.removeAt(index);
                  _saveTrainingPlan();
                });
              },
            ),
            children: [
              SlidableAction(
                onPressed: (_) {
                  setState(() {
                    workout.exercises.removeAt(index);
                    _saveTrainingPlan();
                  });
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: s.delete,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey[850],
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                exercise.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: _buildExerciseDetails(exercise, s),
              onTap: () => _showExerciseDetailDialog(exercise),
              trailing: const Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseDetails(Exercise exercise, S s) {
    if (!isPremium) {
      return Row(
        children: [
          Icon(Icons.lock, size: 14, color: Colors.amber[400]),
          const SizedBox(width: 4),
          Text(
            s.premiumRequired,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/premium');
            },
            child: Text(
              s.premiumRequired,
              style: TextStyle(
                color: Colors.amber[400],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    List<Widget> details = [];

    if (exercise.sets != null) {
      details.add(
        Text(
          "${exercise.sets} ${s.setsLabel}",
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      );
    }

    if (exercise.reps != null) {
      details.add(
        Text(
          "${exercise.reps} ${s.repsLabel}",
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      );
    }

    if (exercise.weight != null) {
      details.add(
        Text(
          "${exercise.weight} ${s.kg}",
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      );
    }

    return details.isEmpty
        ? Text(
            s.tapToAddDetails,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          )
        : Row(
            children: [
              for (int i = 0; i < details.length; i++) ...[
                details[i],
                if (i < details.length - 1)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ],
          );
  }

  Widget _buildAddExerciseInput(S s) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            s.quickAdd,
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _newExerciseController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: s.newExerciseHint,
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _addExercise();
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add_circle,
              color: _weekPlan[_currentDayIndex].color ??
                  Theme.of(context).primaryColor,
            ),
            onPressed: _addExercise,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (_weekPlan.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(s.trainingPlan),
          backgroundColor: Colors.black,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentWorkout = _weekPlan[_currentDayIndex];
    final workoutColor = currentWorkout.color ?? Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(s.trainingPlan),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _showColorPickerDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewDay,
          ),
        ],
        bottom: (_tabController == null)
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: workoutColor,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                tabs: _buildWeekdayTabs(),
              ),
      ),
      body: Column(
        children: [
          _buildWorkoutHeader(currentWorkout, workoutColor),
          Expanded(
            child: currentWorkout.exercises.isEmpty
                ? _buildEmptyState(s)
                : _buildExerciseList(currentWorkout, s),
          ),
          _buildAddExerciseInput(s),
        ],
      ),
    );
  }
}