// lib/pages/flow_timer.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/flow_timer_service.dart';
import '../widgets/ad_wrapper.dart';
import '../l10n/generated/l10n.dart';

class FlowTimerPage extends StatefulWidget {
  const FlowTimerPage({Key? key}) : super(key: key);

  @override
  _FlowTimerPageState createState() => _FlowTimerPageState();
}

class _FlowTimerPageState extends State<FlowTimerPage>
    with SingleTickerProviderStateMixin {
  DateTime? _sessionStart;

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final flowTimer = context.watch<FlowTimerService>();

    final isRunning = flowTimer.isRunning;
    final currentFlowIndex = flowTimer.flowIndex;
    final totalFlows = flowTimer.flows;
    final totalSeconds = flowTimer.minutes * 60.0;
    final secondsLeft = flowTimer.secondsLeft.toDouble();
    final timeString = _formatTime(flowTimer.secondsLeft);

    // Falls wir das Ende erreicht haben => reset
    if (currentFlowIndex >= totalFlows) {
      flowTimer.resetTimer();
    }

    // Fortschritt für den aktuellen Flow (0..1)
    double flowProgress = 0.0;
    if (isRunning && totalSeconds > 0) {
      flowProgress = (totalSeconds - secondsLeft) / totalSeconds;
    } else if (currentFlowIndex > 0 && !isRunning) {
      // Wenn ein Flow fertig ist, Pause
      flowProgress = 1.0;
    }

    return AdWrapper(
      child: Scaffold(
        // <-- Nutze hier eine "normale" AppBar, damit wir einen Zurück-Button haben
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            loc.flowTimerTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context), // Zurück
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ---------------------------------------
                // OBERE SECTION: Flow-Kästchen (als Cards)
                // ---------------------------------------
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: _buildFlowSquares(flowTimer),
                  ),
                ),

                // ---------------------------------------
                // MITTLERER BEREICH: CIRCULAR TIMER
                // ---------------------------------------
                Expanded(
                  child: Center(
                    // Kann via onTap die Zeit ändern
                    child: GestureDetector(
                      onTap: () async {
                        _sessionStart ??= DateTime.now();
                        await _changeTimeDialog(context);
                      },
                      child: SizedBox(
                        width: 280,
                        height: 280,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Hintergrund-Kreis
                            SizedBox(
                              width: 280,
                              height: 280,
                              child: CircularProgressIndicator(
                                value: flowProgress,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey.shade800,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isRunning ? const Color.fromARGB(255, 223, 27, 27) : Colors.grey,
                                ),
                              ),
                            ),
                            // Zeit drüber
                            Text(
                              timeString,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 223, 27, 27),
                                fontFamily: 'Digital',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ---------------------------------------
                // UNTERER BEREICH: FLOW-INFO + BUTTONS
                // ---------------------------------------
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      // Flows: "Flow X / Y" + Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            loc.flowCounter(currentFlowIndex + 1, totalFlows),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Einstellen der Flow-Anzahl
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white),
                            onPressed: () async {
                              await _changeFlowsDialog(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Buttons: Start/Pause & Reset
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 60,
                            color: const Color.fromARGB(255, 223, 27, 27),
                            icon: Icon(isRunning
                                ? Icons.pause_circle
                                : Icons.play_circle),
                            onPressed: () {
                              if (isRunning) {
                                flowTimer.pauseTimer();
                              } else {
                                _sessionStart ??= DateTime.now();
                                flowTimer.startTimer();
                              }
                            },
                          ),
                          const SizedBox(width: 40),
                          IconButton(
                            iconSize: 60,
                            color: const Color.fromARGB(255, 223, 27, 27),
                            icon: const Icon(Icons.refresh),
                            onPressed: flowTimer.resetTimer,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Flow-Kästchen (jetzt optisch minimal aufgeräumter)
  // ----------------------------------------------------
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
          fillPercent = 1.0; // Flow erledigt
        } else if (index == currentFlowIndex && isRunning) {
          final totalSecs = minutes * 60.0;
          final done = totalSecs - secondsLeft;
          fillPercent = done / totalSecs;
        }

        Color baseColor;
        if (index < currentFlowIndex) {
          baseColor = Colors.green; // fertige Flows = grün
        } else if (index == currentFlowIndex) {
          baseColor = const Color.fromARGB(255, 223, 27, 27); // aktueller Flow = rot
        } else {
          baseColor = Colors.grey;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 28,
          height: 28,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                heightFactor: fillPercent,
                child: Container(
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ----------------------------------------------------
  // Zeit-Dialog
  // ----------------------------------------------------
  Future<void> _changeTimeDialog(BuildContext ctx) async {
    final loc = S.of(ctx);
    final flowTimer = ctx.read<FlowTimerService>();
    final controller = TextEditingController(text: flowTimer.minutes.toString());

    await showDialog<void>(
      context: ctx,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text(
            loc.flowTimerSetTimeTitle,
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            style: const TextStyle(color: Colors.white),
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: loc.flowTimerSetTimeHint,
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey.shade800,
            ),
          ),
          actions: [
            TextButton(
              child: Text(loc.ok, style: const TextStyle(color: Color.fromARGB(255, 223, 27, 27))),
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

  // ----------------------------------------------------
  // Flow-Anzahl-Dialog (max. 8)
  // ----------------------------------------------------
  Future<void> _changeFlowsDialog(BuildContext ctx) async {
    final loc = S.of(ctx);
    final flowTimer = ctx.read<FlowTimerService>();
    final flowController =
        TextEditingController(text: flowTimer.flows.toString());

    await showDialog<void>(
      context: ctx,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text(
            loc.flowTimerSetFlowsTitle,
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            style: const TextStyle(color: Colors.white),
            controller: flowController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: loc.flowTimerSetFlowsHint,
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey.shade800,
            ),
          ),
          actions: [
            TextButton(
              child: Text(loc.ok, style: const TextStyle(color: Color.fromARGB(255, 223, 27, 27))),
              onPressed: () {
                Navigator.pop(dialogCtx);
                final newF = int.tryParse(flowController.text);
                if (newF != null && newF > 0) {
                  // max. 8
                  flowTimer.updateFlows(newF.clamp(1, 8));
                }
              },
            )
          ],
        );
      },
    );
  }

  // ----------------------------------------------------
  // Zeit formatieren (mm:ss)
  // ----------------------------------------------------
  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
