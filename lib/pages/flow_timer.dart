import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/flow_timer_service.dart';
import '../widgets/ad_wrapper.dart'; // Import des AdWrapper

class FlowTimerPage extends StatefulWidget {
  const FlowTimerPage({Key? key}) : super(key: key);

  @override
  _FlowTimerPageState createState() => _FlowTimerPageState();
}

class _FlowTimerPageState extends State<FlowTimerPage> {
  DateTime? _sessionStart;

  @override
  Widget build(BuildContext context) {
    final flowTimer = context.watch<FlowTimerService>();

    final timeString = _formatTime(flowTimer.secondsLeft);
    final isRunning = flowTimer.isRunning;
    final currentFlowIndex = flowTimer.flowIndex;
    final totalFlows = flowTimer.flows;

    // Automatisch resetten, falls das Ende erreicht wurde
    if (currentFlowIndex >= totalFlows) {
      flowTimer.resetTimer();
    }

    return AdWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Focus!'),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flow-Kästchen
              _buildFlowSquares(flowTimer),
              const SizedBox(height: 24),

              // Timer (klickbar => Dialog)
              GestureDetector(
                onTap: () async {
                  _sessionStart ??= DateTime.now();
                  await _changeTimeDialog(context);
                },
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

              // Flows: z.B. "Flow 2 / 4" + Button, um die Anzahl Flows zu ändern
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Flow ${currentFlowIndex + 1} / $totalFlows',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () async {
                      await _changeFlowsDialog(context);
                    },
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Start/Pause/Reset
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 64,
                    color: Colors.redAccent,
                    icon: Icon(isRunning ? Icons.pause_circle : Icons.play_circle),
                    onPressed: () {
                      if (isRunning) {
                        flowTimer.pauseTimer();
                      } else {
                        _sessionStart ??= DateTime.now();
                        flowTimer.startTimer();
                      }
                    },
                  ),
                  const SizedBox(width: 24),
                  // Reset-Button (statt Stop)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    iconSize: 64,
                    color: Colors.redAccent,
                    onPressed: flowTimer.resetTimer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------
  // 1) Flow-Kästchen
  // ------------------------------------------------
  Widget _buildFlowSquares(FlowTimerService flowTimer) {
    final currentFlowIndex = flowTimer.flowIndex;
    final totalFlows = flowTimer.flows;
    final isRunning = flowTimer.isRunning;
    final minutes = flowTimer.minutes;
    final secondsLeft = flowTimer.secondsLeft;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalFlows, (index) {
        double fillPercent = 0.0;

        if (index < currentFlowIndex) {
          fillPercent = 1.0;
        } else if (index == currentFlowIndex && isRunning) {
          final totalSecs = minutes * 60.0;
          final done = (minutes * 60.0 - secondsLeft);
          fillPercent = done / totalSecs;
        }

        Color baseColor;
        if (index < currentFlowIndex) {
          baseColor = Colors.green;
        } else if (index == currentFlowIndex) {
          baseColor = Colors.redAccent;
        } else {
          baseColor = Colors.grey;
        }

        return Container(
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
        );
      }),
    );
  }

  // ------------------------------------------------
  // 2) Zeit-Einstellung-Dialog
  // ------------------------------------------------
  Future<void> _changeTimeDialog(BuildContext ctx) async {
    final flowTimer = ctx.read<FlowTimerService>();
    final controller = TextEditingController(text: flowTimer.minutes.toString());

    await showDialog<void>(
      context: ctx,
      builder: (dialogCtx) {
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
                Navigator.pop(dialogCtx);
                final newM = int.tryParse(controller.text);
                if (newM != null && newM > 0) {
                  flowTimer.updateMinutes(newM);
                }
              },
            )
          ],
        );
      },
    );
  }

  // ------------------------------------------------
  // 3) Flow-Anzahl-Einstellung-Dialog
  // ------------------------------------------------
  Future<void> _changeFlowsDialog(BuildContext ctx) async {
    final flowTimer = ctx.read<FlowTimerService>();
    final flowController = TextEditingController(text: flowTimer.flows.toString());

    await showDialog<void>(
      context: ctx,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Anzahl Flows einstellen'),
          content: TextField(
            controller: flowController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Flows eingeben'),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(dialogCtx);
                final newF = int.tryParse(flowController.text);
                if (newF != null && newF > 0) {
                  flowTimer.updateFlows(newF);
                }
              },
            )
          ],
        );
      },
    );
  }

  // ------------------------------------------------
  // 4) Zeit-Format
  // ------------------------------------------------
  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
