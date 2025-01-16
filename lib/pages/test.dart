import 'dart:async';
import 'package:flutter/material.dart';

class TestTimerPage extends StatefulWidget {
  const TestTimerPage({Key? key}) : super(key: key);

  @override
  _TestTimerPageState createState() => _TestTimerPageState();
}

class _TestTimerPageState extends State<TestTimerPage> {
  // ============= Konfiguration =============
  int minutes = 45; // Minuten pro Flow
  int flows = 1; // Anzahl Flow-Einheiten (1..4)

  // ============= Laufzeit-State =============
  int flowIndex = 0; // Welcher Flow wird gerade bearbeitet? 0-basiert
  late int secondsLeft; // Sekunden, die in diesem Flow noch übrig sind
  bool isRunning = false;
  Timer? _timer;

  // Startzeit für (lokales) Log
  DateTime? _sessionStart;

  @override
  void initState() {
    super.initState();
    flowIndex = 0;
    secondsLeft = minutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ------------------------------------------------
  // ============= TIMER-LOGIK =============
  // ------------------------------------------------
  void startTimer() {
    _timer?.cancel();

    // Falls wir ganz am Anfang sind
    if (!_isAnyFlowInProgress()) {
      flowIndex = 0;
      secondsLeft = minutes * 60;
    }
    _sessionStart = DateTime.now();

    setState(() {
      isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft <= 1) {
        // Flow beendet
        timer.cancel();
        setState(() {
          isRunning = false;
          secondsLeft = 0;
        });
        // Hier könntest du ein lokales Logging machen
        _logOneFlowSession();

        // Nächster Flow?
        flowIndex++;
        if (flowIndex < flows) {
          // Falls noch weitere Flows übrig sind => Startet direkt den nächsten
          _startNextFlow();
        } else {
          // Alle Flows fertig => Gesamtsession Ende
          _logFinalSession();
        }
      } else {
        setState(() {
          secondsLeft--;
        });
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      flowIndex = 0;
      secondsLeft = minutes * 60;
    });
  }

  bool _isAnyFlowInProgress() {
    return flowIndex < flows;
  }

  void _startNextFlow() {
    secondsLeft = minutes * 60;
    startTimer();
  }

  // ------------------------------------------------
  // ============= FLOWS QUADRATE =============
  // ------------------------------------------------
  Widget _buildFlowSquares() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        double fillPercent = 0.0; // Default ungefüllt

        if (index < flowIndex) {
          fillPercent = 1.0; // voll
        } else if (index == flowIndex && isRunning) {
          double total = minutes * 60.0;
          double done = (minutes * 60.0 - secondsLeft);
          fillPercent = done / total;
        }

        Color baseColor;
        if (index < flowIndex) {
          baseColor = Colors.green;
        } else if (index == flowIndex) {
          baseColor = Colors.redAccent;
        } else {
          baseColor = Colors.grey;
        }

        return GestureDetector(
          onTap: () => _onFlowSquareTapped(index),
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 24,
            height: 24,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: fillPercent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _onFlowSquareTapped(int index) {
    setState(() {
      if (flows == index + 1) {
        if (flows > 1) flows--;
      } else {
        flows = index + 1;
        if (flows > 4) flows = 4;
      }
      flowIndex = 0;
      secondsLeft = minutes * 60;
      _timer?.cancel();
      isRunning = false;
    });
  }

  // ------------------------------------------------
  // ============= ZEIT FORMATIEREN & DIALOG =============
  // ------------------------------------------------
  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _changeTimeDialog() async {
    final controller = TextEditingController(text: minutes.toString());
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Timer einstellen (Minuten)'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Minuten eingeben'),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(ctx);
                final newM = int.tryParse(controller.text);
                if (newM != null && newM > 0) {
                  setState(() {
                    minutes = newM;
                    flowIndex = 0;
                    secondsLeft = minutes * 60;
                    isRunning = false;
                    _timer?.cancel();
                  });
                }
              },
            )
          ],
        );
      },
    );
  }

  // ------------------------------------------------
  // ============= "LOCAL LOG" STATT FIRESTORE =============
  // ------------------------------------------------
  void _logOneFlowSession() {
    if (_sessionStart == null) return;
    final sessionEnd = DateTime.now();
    final totalSeconds = sessionEnd.difference(_sessionStart!).inSeconds;
    final data = {
      'startTime': _sessionStart!,
      'endTime': sessionEnd,
      'flowNumber': flowIndex, // welcher Flow war das
      'minutesConfigured': minutes,
      'actualDurationSeconds': totalSeconds,
    };
    // Hier könntest du das in einer lokalen DB speichern
    // oder 'print' machen:
    print('FlowSession => $data');
  }

  void _logFinalSession() {
    print('Alle Flows geschafft! flowsTotal=$flows, minutesPerFlow=$minutes');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alle Flows geschafft!')),
    );
  }

  // ------------------------------------------------
  // ============= BUILD UI =============
  // ------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final timeString = _formatTime(secondsLeft);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer (Test)'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFlowSquares(),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _changeTimeDialog,
              child: Text(
                timeString,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  fontFamily: 'Digital',
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 64,
                  color: Colors.redAccent,
                  icon:
                      Icon(isRunning ? Icons.pause_circle : Icons.play_circle),
                  onPressed: () {
                    isRunning ? pauseTimer() : startTimer();
                  },
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.stop_circle),
                  iconSize: 64,
                  color: Colors.redAccent,
                  onPressed: resetTimer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
