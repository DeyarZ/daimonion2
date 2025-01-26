import 'dart:math'; // Für den Zufall
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

// Deine Services & Pages
import '../services/db_service.dart';
import '../services/flow_timer_service.dart';
import '../pages/todo_list.dart';
import '../pages/habit_tracker.dart';
import 'flow_stats_page.dart';
import '../widgets/ad_wrapper.dart';

// ------------------------------------------------
// MODELDATEN für Flow-Sessions
// ------------------------------------------------
class FlowSession {
  final DateTime date;
  final int minutes;
  FlowSession({required this.date, required this.minutes});
}

// ------------------------------------------------
// TASK / HABIT MODEL
// ------------------------------------------------
class Task {
  final String id;
  String title;
  bool completed;
  DateTime deadline;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
    required this.deadline,
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
}

// ------------------------------------------------
// DASHBOARD
// ------------------------------------------------
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final DBService _dbService = DBService();
  final Uuid _uuid = const Uuid();

  int _streak = 0; // aus Hive gelesen
  final List<DateTime> _weekDates = [];

  /// Hier speichern wir die echten Flow-Sekunden der letzten 7 Tage
  int? _weeklyFlowSeconds;

  /// Beispiel-Liste mit Motivationssprüchen
final List<String> _motivationQuotes = [
  // Kurze, prägnante Sprüche
  "Du bist nicht hier, um Durchschnitt zu sein!",
  "Keine Ausreden – geh weiter!",
  "Wenn du aufgibst, hast du es nie ernst gemeint.",
  "Jeder Tag eine neue Chance, nutze sie!",
  "Your future self will thank you for your grind today.",
  "Disziplin schlägt Talent – jeden Tag.",
  "Was du heute tust, entscheidet über morgen.",
  "Träume groß, arbeite härter.",
  "Du bist stärker, als du denkst.",
  "Kein Wachstum ohne Anstrengung.",

  // Inspirierende längere Sprüche
  "Die härtesten Kämpfe kommen vor den größten Siegen.",
  "Du musst die Person werden, die du dir wünschst zu sein – Schritt für Schritt.",
  "Egal, wie langsam du gehst, du schlägst jeden, der auf der Couch bleibt.",
  "Fehler sind der Beweis, dass du es versuchst.",
  "Man wächst nicht in seiner Komfortzone – wage den Schritt hinaus.",
  "Harte Arbeit wird nicht immer belohnt, aber sie baut Charakter.",
  "Es sind die kleinen täglichen Siege, die die großen Erfolge formen.",
  "Du hast 24 Stunden wie jeder andere – nutze sie mit Intention.",
  "Deine Ziele interessieren sich nicht für deine Ausreden.",
  "Wenn der Weg einfach ist, bist du auf dem falschen Pfad.",

  // Zitate von Persönlichkeiten
  "\"Die beste Weg, die Zukunft vorherzusagen, ist sie zu erschaffen.\" - Peter Drucker, Pionier der Managementlehre.",
  "\"Erfolg ist die Fähigkeit, von einem Misserfolg zum nächsten zu gehen, ohne die Begeisterung zu verlieren.\" - Winston Churchill, ehemaliger britischer Premierminister.",
  "\"Was immer du tun kannst oder träumst, dass du es kannst, fang damit an.\" - Johann Wolfgang von Goethe.",
  "\"Nicht die Stärke zählt, sondern die Ausdauer.\" - Konfuzius, chinesischer Philosoph.",
  "\"Sei du selbst die Veränderung, die du dir für diese Welt wünschst.\" - Mahatma Gandhi.",
  "\"Ein Ziel ist ein Traum mit einer Deadline.\" - Napoleon Hill, Autor von 'Denke nach und werde reich'.",
  "\"Erfolg ist nichts Endgültiges, Misserfolg nichts Fatales: Es ist der Mut, der zählt.\" - Winston Churchill.",
  "\"Wer kämpft, kann verlieren. Wer nicht kämpft, hat schon verloren.\" - Bertolt Brecht, deutscher Dramatiker.",
  "\"Hindernisse sind die Dinge, die du siehst, wenn du dein Ziel aus den Augen verlierst.\" - Henry Ford, Gründer von Ford Motor Company.",
  "\"Das Leben schrumpft oder dehnt sich aus in Relation zu deinem Mut.\" - Anaïs Nin, Schriftstellerin.",
  "\"Schmerz ist schwäche, die den Körper verlässt.\" - US Marines Sprichwort.",
  "\"Entweder du kontrollierst den Tag, oder der Tag kontrolliert dich.\" - David Goggins, Ultramarathonläufer und Ex-Navy SEAL.",

  // Weitere motivierende Gedanken
  "Hör auf zu reden, fang an zu machen.",
  "Jeder Erfolg beginnt mit dem Mut, es zu versuchen.",
  "Stärke wächst, wo Komfort endet.",
  "Deine einzige Grenze ist die, die du dir selbst setzt.",
  "Dein Potenzial wartet auf deinen Einsatz.",
  "Jedes Nein bringt dich näher an ein Ja.",
  "Konzentriere dich auf das, was du kontrollieren kannst.",
  "Das Gestern ist vergangen. Heute ist dein Tag.",
  "Die besten Entscheidungen sind oft die schwersten.",
  "Ein kleiner Fortschritt ist immer noch Fortschritt.",
  
  // Positive, längere Gedanken
  "Die schwierigste Entscheidung deines Lebens könnte die sein, die alles verändert.",
  "Jede großartige Reise beginnt mit dem ersten Schritt.",
  "Menschen, die dich unterschätzen, geben dir das größte Geschenk: den Ansporn, zu beweisen, dass sie falsch liegen.",
  "Erfolg ist kein Ziel, sondern eine Reise – bleib dran.",
  "Du kannst nichts kontrollieren außer deiner Reaktion auf die Welt.",
  "Die schwierigsten Momente sind oft die, die dich am meisten formen.",
  "Was du heute pflanzt, wirst du morgen ernten.",
  "Wenn du versagst, versuche es erneut, aber versage diesmal besser.",
  "Erfolg bedeutet nicht Perfektion, sondern Fortschritt.",
  "Das Leben gibt dir, was du bereit bist, dir selbst zu nehmen.",

  // Kurze Power-Sätze
  "Der Schmerz vergeht, der Stolz bleibt.",
  "Fokus schlägt Chaos.",
  "Tu, was getan werden muss.",
  "Du bist ein Krieger, keine Ausrede zählt.",
  "Hass treibt dich an, Liebe macht dich unaufhaltsam.",
  "Ziele hoch – immer.",
  "Disziplin ist Freiheit.",
  "Entweder du machst es oder jemand anderes tut es.",
  "Verliere nie deinen Glauben an dich selbst.",
  "Angst ist dein Kompass – folge ihr.",

  // Weitere Zitate von Persönlichkeiten
// Zitate von Männern mit krassem Mindset
  "\"Jeder Kampf ist der erste Kampf deines Lebens. Also kämpfe, als ob es keinen Morgen gibt.\" - Mike Tyson, Boxlegende.",
  "\"Wenn du bereit bist, das zu opfern, was du bist, für das, was du werden willst, dann bist du bereit zu gewinnen.\" - Eric Thomas, Motivationsredner.",
  "\"Wenn ich sterbe, dann auf meinen Beinen, nicht auf meinen Knien.\" - Emiliano Zapata, mexikanischer Revolutionär.",
  "\"Die Größe eines Mannes wird daran gemessen, wie viel Wahrheit er aushalten kann.\" - Friedrich Nietzsche, Philosoph.",
  "\"Ich bin nicht der Beste. Aber ich bin bereit, gegen jeden zu kämpfen, der es behauptet.\" - Bruce Lee, Kampfkünstler und Schauspieler."
  "\"Alles, was wir sind, ist das Ergebnis dessen, was wir gedacht haben.\" - Buddha.",
  "\"Erfolg besteht darin, dass man genau die Fähigkeiten hat, die im Moment gefragt sind.\" - Henry Ford.",
  "\"Die Kraft liegt nicht im Wissen, sondern im Tun.\" - Dale Carnegie, Autor von 'Wie man Freunde gewinnt'.",
  "\"Das Glück begünstigt die Mutigen.\" - Vergil, römischer Dichter.",
  "\"Lass dich niemals von der Angst leiten.\" - Nelson Mandela.",
  "\"Es ist nie zu spät, das zu sein, was man hätte sein können.\" - George Eliot, Schriftstellerin.",

  // Weitere motivierende Gedanken
  "Was heute unmöglich scheint, könnte morgen dein Standard sein.",
  "Du bist nur so stark wie die Gewohnheiten, die du jeden Tag aufbaust.",
  "Triff Entscheidungen, die deinem zukünftigen Ich dienen.",
  "Große Erfolge beginnen oft mit kleinen Schritten.",
  "Hör auf, perfekt zu sein, und fang an, Fortschritte zu machen.",
  "Die härtesten Schlachten werden oft allein gekämpft.",
  "Erfolg bedeutet, Dinge zu tun, die andere nicht tun wollen.",
  "Du hast nur eine Chance – nutze sie.",
  "Dein Warum ist größer als jedes Hindernis.",
  "Schmerz ist vorübergehend, Stolz hält ewig."
];

  /// Liste mit Bildpfaden
  final List<String> _motivationImages = [
    'assets/images/arnold.png',
    'assets/images/8bit_squat.png',
    'assets/images/chess.png',
    'assets/images/ferrari.png',
    'assets/images/greek_focus.png',
    'assets/images/napoleon.png',
    'assets/images/ronaldo.png',
    'assets/images/spartan.png',
    'assets/images/tate.png',
    'assets/images/wolf.png',
  ];


  late String _randomQuote;
  late String _randomImage;


  @override
  void initState() {
    super.initState();
    _initWeekDates();

    // Streak-Wert aus settings-Box
    final settingsBox = Hive.box('settings');
    _streak = settingsBox.get('streak', defaultValue: 1);

    // Zufallsspruch wählen
    _randomQuote = _motivationQuotes[Random().nextInt(_motivationQuotes.length)];

    // Zufälliges Bild wählen
    _randomImage = _motivationImages[Random().nextInt(_motivationImages.length)];

    // Echte wöchentliche Flow-Minuten laden und in Sek. umrechnen
    _loadWeeklyFlowSeconds();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Wenn du hier noch was updaten willst -> go ahead
  }

  // -----------------------------------------
  // Wochentage init
  // -----------------------------------------
  void _initWeekDates() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    for (int i = 0; i < 7; i++) {
      _weekDates.add(monday.add(Duration(days: i)));
    }
  }

  // -----------------------------------------
  // Wöchentliche Flow-Minuten *richtig* laden
  // -----------------------------------------
  Future<void> _loadWeeklyFlowSeconds() async {
    final box = await Hive.openBox<Map>('flow_sessions');
    final allSessions = _boxToFlowSessions(box);

    // Wir betrachten die letzten 7 Tage, also "ab Start des Tages, 6 Tage zurück"
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 6));

    final filtered = allSessions
        .where((fs) => fs.date.isAfter(_startOfDay(from)))
        .toList();

    // Gesamt-Minuten summieren
    final totalFlowMinutes = filtered.fold<int>(0, (sum, fs) => sum + fs.minutes);

    // In Sekunden umrechnen
    final totalSeconds = totalFlowMinutes * 60;

    setState(() {
      _weeklyFlowSeconds = totalSeconds;
    });
  }

  // -----------------------------------------
  // BUILD
  // -----------------------------------------
  @override
  Widget build(BuildContext context) {
    final flowTimer = context.watch<FlowTimerService>();
    final isRunning = flowTimer.isRunning;
    final secondsLeft = flowTimer.secondsLeft;
    final m = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (secondsLeft % 60).toString().padLeft(2, '0');

    return AdWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ------------------------------------
              // TOP-ROW mit 3 Cards
              // ------------------------------------
              Row(
                children: [
                  Expanded(child: _buildWeeklyFlowTimeCard()),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStreakCard()),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFlowTimerCard(isRunning, '$m:$s')),
                ],
              ),
              const SizedBox(height: 16),

              // ------------------------------------
              // MOTIVATION
              // ------------------------------------
              Card(
                color: Colors.grey[850],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _buildMotivationSection(),
                ),
              ),
              const SizedBox(height: 16),

              // ------------------------------------
              // TASKS & WEEKLY CHART
              // ------------------------------------
              ValueListenableBuilder(
                valueListenable: _dbService.listenableTasks(),
                builder: (context, taskBox, _) {
                  final tasks = _boxToTaskList(taskBox as Box);
                  final now = DateTime.now();

                  final todayTasks = tasks.where((t) => _isSameDay(t.deadline, now)).toList();
                  final totalTasks = todayTasks.length;
                  final doneTasks = todayTasks.where((t) => t.completed).length;
                  final tasksPercent =
                      (totalTasks == 0) ? 0.0 : (doneTasks / totalTasks);

                  final dailyPercents = _calculateWeeklyPercents(tasks);

                  return Column(
                    children: [
                      Card(
                        color: Colors.grey[850],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: _buildTodayAndPieRow(tasksPercent, todayTasks),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.grey[850],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ToDoListPage()),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: _buildWeeklyProgressChart(dailyPercents),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // ------------------------------------
              // HABIT CHEER
              // ------------------------------------
              ValueListenableBuilder(
                valueListenable: _dbService.listenableHabits(),
                builder: (context, habitBox, _) {
                  final habits = _boxToHabitList(habitBox as Box);
                  final cheer = _calculateCheerMessage(habits);
                  if (cheer == null) return const SizedBox();
                  return Card(
                    color: Colors.grey[850],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        cheer,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------
  // PAYWALL
  // -----------------------------------------
  void _showPaywallDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Premium benötigt'),
          content: const Text(
            'Dieser Bereich ist nur für Premium-Nutzer verfügbar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // -----------------------------------------
  // WEEKLY FLOW TIME CARD (ECHTE LOGIK)
  // -----------------------------------------
  Widget _buildWeeklyFlowTimeCard() {
    // Falls es noch null ist (z.B. bevor Hive geladen ist),
    // kannst du "Loading" anzeigen oder '00:00'
    final value = _weeklyFlowSeconds ?? 0;
    final weeklyTimeHHMM = _formatWeeklyFlowTime(value);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FlowStatsPage()),
        );
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weeklyTimeHHMM,
                style: const TextStyle(
                  fontFamily: 'Digital',
                  fontSize: 28,
                  color: Colors.redAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Produktive Zeit (Woche)',
                style: TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------
  // STREAK
  // -----------------------------------------
  Widget _buildStreakCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      height: 90,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_streak',
              style: const TextStyle(
                fontFamily: 'Digital',
                fontSize: 28,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Streak',
              style: TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------
  // FLOW TIMER
  // -----------------------------------------
  Widget _buildFlowTimerCard(bool isRunning, String timeString) {
    final flowTimer = context.watch<FlowTimerService>();
    return GestureDetector(
      onTap: () {
        if (isRunning) {
          flowTimer.pauseTimer();
        } else {
          flowTimer.startTimer();
        }
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isRunning ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.redAccent,
                    size: 24,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeString,
                    style: const TextStyle(
                      fontFamily: 'Digital',
                      fontSize: 28,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Flow Timer',
                style: TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------
  // MOTIVATION SECTION
  // -----------------------------------------
  Widget _buildMotivationSection() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            _randomImage,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _randomQuote,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'BebasNeue',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // -----------------------------------------
  // TODAY + Circle-Charts
  // -----------------------------------------
  Widget _buildTodayAndPieRow(double tasksPercent, List<Task> todayTasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTodaysTaskCard(todayTasks),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ToDoListPage()),
                  );
                },
                child: _buildPieChart(
                  tasksPercent,
                  title: 'Tasks',
                  size: 120,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final isPremium =
                      Hive.box('settings').get('isPremium', defaultValue: false);
                  if (!isPremium) {
                    _showPaywallDialog();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HabitTrackerPage()),
                    );
                  }
                },
                child: _buildPieChart(
                  _calculateHabitsPercent(),
                  title: 'Habits',
                  size: 120,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -----------------------------------------
  // PERCENT HABITS
  // -----------------------------------------
  double _calculateHabitsPercent() {
    final habitBox = _dbService.getHabitsBox();
    final habits = _boxToHabitList(habitBox);
    final todayWd = DateTime.now().weekday;
    final dayKey = _formatDateKey(DateTime.now());
    int totalHabits = 0, doneHabits = 0;
    for (var h in habits) {
      if (h.selectedWeekdays.contains(todayWd)) {
        totalHabits++;
        final st = h.dailyStatus[dayKey];
        if (st == true) doneHabits++;
      }
    }
    return (totalHabits == 0) ? 0.0 : (doneHabits / totalHabits);
  }

  // -----------------------------------------
  // CHEER MSG
  // -----------------------------------------
  String? _calculateCheerMessage(List<Habit> habits) {
    final todayWd = DateTime.now().weekday;
    final dayKey = _formatDateKey(DateTime.now());
    int doneCount = 0, totalCount = 0;
    for (var h in habits) {
      if (h.selectedWeekdays.contains(todayWd)) {
        totalCount++;
        if (h.dailyStatus[dayKey] == true) doneCount++;
      }
    }
    if (totalCount == 0) return null;
    final ratio = doneCount / totalCount;
    if (ratio >= 1.0) {
      return 'Perfekt! Du hast heute alle Gewohnheiten erledigt. Keep pushing!';
    } else if (ratio >= 0.5) {
      return 'Schon über die Hälfte deiner Gewohnheiten geschafft – stark!';
    } else if (ratio > 0.0) {
      return 'Noch nicht fertig, aber du packst das. Nur weitermachen!';
    } else {
      return 'Pack an! Zeit, etwas zu tun!';
    }
  }

  // -----------------------------------------
  // TODAY TASKS
  // -----------------------------------------
  Widget _buildTodaysTaskCard(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: const Center(
          child: Text('Keine Aufgaben für heute',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HEUTIGE TASKS',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.grey),
          ...tasks.map((task) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[700]?.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: ListTile(
                leading: IconButton(
                  icon: Icon(
                    task.completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: task.completed ? Colors.green : Colors.white,
                  ),
                  onPressed: () => _toggleTask(task),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    color: task.completed ? Colors.grey[400] : Colors.white,
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ToDoListPage()),
                  );
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // -----------------------------------------
  // PIE CHART
  // -----------------------------------------
  Widget _buildPieChart(
    double completionPercent, {
    required String title,
    double size = 100,
  }) {
    final percentage = (completionPercent * 100).toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: size,
            width: size,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 28,
                    sections: [
                      PieChartSectionData(
                        value: completionPercent * 100,
                        color: Colors.redAccent,
                        radius: 22,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: (1 - completionPercent) * 100,
                        color: Colors.grey,
                        radius: 22,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------
  // WEEKLY PROGRESS => BAR CHART
  // -----------------------------------------
  Widget _buildWeeklyProgressChart(List<double> dailyPercents) {
    final days = ['MO', 'DI', 'MI', 'DO', 'FR', 'SA', 'SO'];

    return Column(
      children: [
        const Text(
          'WOCHENFORTSCHRITT',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              minY: 0,
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white10,
                  strokeWidth: 1,
                ),
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 25,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < 7) {
                        return Text(
                          days[idx],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              barGroups: List.generate(7, (index) {
                final val = dailyPercents[index];
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: val,
                      color: Colors.redAccent,
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------
  // UTILS
  // -----------------------------------------
  /// Sekunden in HH:MM formatieren
  String _formatWeeklyFlowTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final hh = hours.toString().padLeft(2, '0');
    final mm = minutes.toString().padLeft(2, '0');
    return "$hh:$mm";
  }

  /// Hive-Daten in FlowSession-Modell konvertieren
  List<FlowSession> _boxToFlowSessions(Box<Map> box) {
    final List<FlowSession> result = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data == null) continue;
      final dateMs = data['date'] as int?;
      final mins = data['minutes'] as int?;
      if (dateMs == null || mins == null) continue;
      final dt = DateTime.fromMillisecondsSinceEpoch(dateMs);
      result.add(FlowSession(date: dt, minutes: mins));
    }
    return result;
  }

  /// Start des Tages (ohne Uhrzeit)
  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Tasks aus Box
  List<Task> _boxToTaskList(Box box) {
    final List<Task> tasks = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data == null) continue;

      final id = data['id'] as String? ?? _uuid.v4();
      final title = data['title'] as String? ?? '';
      final completed = data['completed'] as bool? ?? false;
      final deadlineTs = data['deadline'] as int?;
      final deadline = deadlineTs != null
          ? DateTime.fromMillisecondsSinceEpoch(deadlineTs)
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

  /// Habits aus Box
  List<Habit> _boxToHabitList(Box box) {
    final List<Habit> habits = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data == null) continue;

      final id = data['id'] as String? ?? _uuid.v4();
      final name = data['name'] as String? ?? '';
      final dailyStatus = Map<String, bool?>.from(data['dailyStatus'] ?? {});
      final selectedWeekdays = List<int>.from(data['selectedWeekdays'] ?? []);

      habits.add(Habit(
        id: id,
        name: name,
        dailyStatus: dailyStatus,
        selectedWeekdays: selectedWeekdays,
      ));
    }
    return habits;
  }

  /// Check same day
  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  /// DateTime zu String => z.B. "2025-01-26"
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Wöchentliche Task-Fortschritte in Prozent
  List<double> _calculateWeeklyPercents(List<Task> tasks) {
    final results = <double>[];
    for (int i = 0; i < 7; i++) {
      final dayDate = _weekDates[i];
      final tasksForDay = tasks.where((t) => _isSameDay(t.deadline, dayDate)).toList();
      if (tasksForDay.isEmpty) {
        results.add(0.0);
      } else {
        final done = tasksForDay.where((t) => t.completed).length;
        results.add((done / tasksForDay.length) * 100);
      }
    }
    return results;
  }

  /// Task toggeln
  Future<void> _toggleTask(Task task) async {
    final box = await Hive.openBox<Map>(DBService.tasksBoxName);
    final allTasks = _boxToTaskList(box);
    final index = allTasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    allTasks[index].completed = !allTasks[index].completed;

    await _dbService.updateTask(
      index,
      {
        'id': allTasks[index].id,
        'title': allTasks[index].title,
        'completed': allTasks[index].completed,
        'deadline': allTasks[index].deadline.millisecondsSinceEpoch,
      },
    );

    setState(() {});
  }
}
