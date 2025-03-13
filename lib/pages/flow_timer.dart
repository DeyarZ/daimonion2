// lib/pages/flow_timer.dart

import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/flow_timer_service.dart';
import '../widgets/ad_wrapper.dart';
import '../l10n/generated/l10n.dart';
import 'flow_stats_page.dart';

class FlowTimerPage extends StatefulWidget {
  const FlowTimerPage({Key? key}) : super(key: key);

  @override
  _FlowTimerPageState createState() => _FlowTimerPageState();
}

class _FlowTimerPageState extends State<FlowTimerPage>
    with SingleTickerProviderStateMixin {
  DateTime? _sessionStart;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Blackout-Variablen
  bool _isBlackout = false;
  Timer? _blackoutTimer;

  // Für Ding-Ton, wenn ein Flow vorbei ist
  final AudioPlayer _dingPlayer = AudioPlayer();
  int _lastFlowIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cancelBlackoutTimer();
    super.dispose();
  }

  // Startet den Timer, der nach 30 Sekunden den Blackout aktiviert
  void _startBlackoutTimer() {
    _cancelBlackoutTimer();
    _blackoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _isBlackout = true;
        });
      }
    });
  }

  // Löscht den Blackout-Timer
  void _cancelBlackoutTimer() {
    _blackoutTimer?.cancel();
    _blackoutTimer = null;
  }

  // Spielt den Ding-Ton ab (Stelle sicher, dass die Datei in assets/sounds/ding.mp3 vorhanden und deklariert ist)
  Future<void> _playDingSound() async {
    try {
      await _dingPlayer.play(AssetSource('sounds/ding.mp3'));
    } catch (e) {
      debugPrint("Error playing ding sound: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final flowTimer = context.watch<FlowTimerService>();
    final size = MediaQuery.of(context).size;

    final isRunning = flowTimer.isRunning;
    final currentFlowIndex = flowTimer.flowIndex;
    final totalFlows = flowTimer.flows;
    final totalSeconds = flowTimer.minutes * 60.0;
    final secondsLeft = flowTimer.secondsLeft.toDouble();
    final timeString = _formatTime(flowTimer.secondsLeft);

    // Wenn das Ende erreicht ist => zurücksetzen
    if (currentFlowIndex >= totalFlows) {
      flowTimer.resetTimer();
    }

    // Fortschritt des aktuellen Flows (0..1)
    double flowProgress = 0.0;
    if (isRunning && totalSeconds > 0) {
      flowProgress = (totalSeconds - secondsLeft) / totalSeconds;
    } else if (currentFlowIndex > 0 && !isRunning) {
      flowProgress = 1.0;
    }

    // Session-Dauer
    final sessionTime = _sessionStart != null
        ? DateTime.now().difference(_sessionStart!)
        : Duration.zero;
    final sessionTimeString = _formatDuration(sessionTime);

    // Ding-Ton abspielen, wenn ein Flow vorbei ist und noch nicht für diesen Flow der Ton gespielt wurde
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isRunning && flowTimer.secondsLeft == 0 && _lastFlowIndex != currentFlowIndex) {
        _lastFlowIndex = currentFlowIndex;
        _playDingSound();
      }
    });

    // Normaler Body in einem Scaffold, umhüllt von einem Stack für den optionalen Blackout-Overlay
    return AdWrapper(
      child: Stack(
        children: [
          Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              title: Text(
                loc.flowTimerTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 1.2,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                // Stats-Icon
                IconButton(
                  icon: const Icon(Icons.bar_chart, size: 20),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FlowStatsPage()),
                  ),
                ),
                // Info-Icon
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 20),
                  onPressed: () => _showInfoDialog(context),
                ),
              ],
            ),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isRunning 
                      ? [const Color(0xFF1A2151), const Color(0xFF3D0D4E)]
                      : [const Color(0xFF0F0F0F), const Color(0xFF2A2A2A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: FadeTransition(
                  opacity: _animation,
                  child: Column(
                    children: [
                      // Stats summary card – erscheint von Anfang an, sobald die Seite geladen wird
                      if (_sessionStart != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: _buildSessionCard(sessionTimeString, currentFlowIndex, totalFlows),
                        ),
                      
                      // Flow progress visualization
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildFlowProgress(flowTimer),
                      ),
      
                      // Haupt-Timer-Bereich
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: () async {
                              // Falls Blackout aktiv, bei Tippen Farben wiederherstellen
                              if (_isBlackout) {
                                setState(() {
                                  _isBlackout = false;
                                });
                                _cancelBlackoutTimer();
                              } else {
                                _sessionStart ??= DateTime.now();
                                await _changeTimeDialog(context);
                              }
                            },
                            child: FractionallySizedBox(
                              widthFactor: 0.85,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isRunning 
                                          ? const Color.fromARGB(255, 223, 27, 27)
                                          : Colors.blueGrey).withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Timer-Hintergrund
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.black.withOpacity(0.8),
                                              Colors.black.withOpacity(0.6),
                                            ],
                                            stops: const [0.6, 1.0],
                                          ),
                                        ),
                                      ),
                                      
                                      // Progress-Indikator
                                      SizedBox(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: CircularProgressIndicator(
                                          value: flowProgress,
                                          strokeWidth: 15,
                                          backgroundColor: Colors.grey.shade800.withOpacity(0.3),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            isRunning 
                                              ? const Color.fromARGB(255, 223, 27, 27) 
                                              : Colors.blueGrey,
                                          ),
                                        ),
                                      ),
                                      
                                      // Zeit-Anzeige
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            timeString,
                                            style: TextStyle(
                                              fontSize: size.width * 0.15,
                                              fontWeight: FontWeight.bold,
                                              color: isRunning 
                                                  ? const Color.fromARGB(255, 223, 27, 27)
                                                  : Colors.white,
                                              fontFamily: 'Digital',
                                              letterSpacing: 2,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black26,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              isRunning ? "RUNNING" : "PAUSED",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: isRunning 
                                                    ? const Color.fromARGB(255, 223, 27, 27)
                                                    : Colors.white70,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
      
                      // Untere Steuerung
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          children: [
                            // Flow-Konfigurationszeile
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildConfigButton(
                                  context,
                                  icon: Icons.timer,
                                  label: '${flowTimer.minutes} min',
                                  onTap: () async {
                                    await _changeTimeDialog(context);
                                  },
                                ),
                                const SizedBox(width: 16),
                                _buildConfigButton(
                                  context,
                                  icon: Icons.repeat,
                                  label: '$totalFlows flows',
                                  onTap: () async {
                                    await _changeFlowsDialog(context);
                                  },
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Steuerungs-Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildControlButton(
                                  icon: Icons.refresh,
                                  color: Colors.orange,
                                  onPressed: () {
                                    _showResetConfirmation(context, flowTimer);
                                  },
                                ),
                                _buildControlButton(
                                  icon: isRunning ? Icons.pause : Icons.play_arrow,
                                  color: isRunning ? Colors.blue : const Color.fromARGB(255, 223, 27, 27),
                                  size: 70,
                                  onPressed: () {
                                    if (isRunning) {
                                      flowTimer.pauseTimer();
                                      _cancelBlackoutTimer();
                                      setState(() {
                                        _isBlackout = false;
                                      });
                                    } else {
                                      _sessionStart ??= DateTime.now();
                                      flowTimer.startTimer();
                                      _startBlackoutTimer();
                                    }
                                  },
                                ),
                                _buildControlButton(
                                  icon: Icons.skip_next,
                                  color: Colors.green,
                                  onPressed: () {
                                    if (currentFlowIndex < totalFlows - 1) {
                                      flowTimer.skipToNextFlow();
                                    }
                                  },
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
          ),
          // Blackout-Overlay: Deckt den ganzen Screen schwarz ab, zeigt nur die Timer-Zahl und hebt sich per Tap auf
          if (_isBlackout)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isBlackout = false;
                  });
                  _cancelBlackoutTimer();
                },
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      timeString,
                      style: TextStyle(
                        fontSize: size.width * 0.2,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Digital',
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Configuration-Button (Zeit / Flows)
  Widget _buildConfigButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Steuerungs-Button (Play/Pause/Reset/Skip)
  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    double size = 50,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: size * 0.6),
        color: color,
        onPressed: onPressed,
      ),
    );
  }

  // Session-Stats-Karte
  Widget _buildSessionCard(String sessionTime, int currentFlow, int totalFlows) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.watch_later_outlined,
            label: "Session",
            value: sessionTime,
          ),
          _buildStatItem(
            icon: Icons.auto_awesome,
            label: "Flow",
            value: "$currentFlow/$totalFlows",
          ),
          _buildStatItem(
            icon: Icons.auto_graph,
            label: "Completed",
            value: "${((currentFlow / totalFlows) * 100).toStringAsFixed(0)}%",
          ),
        ],
      ),
    );
  }

  // Einzelnes Stat-Item
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white60),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Flow-Progress Visualisierung
  Widget _buildFlowProgress(FlowTimerService flowTimer) {
    final currentFlowIndex = flowTimer.flowIndex;
    final totalFlows = flowTimer.flows;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalFlows, (index) {
              Color flowColor;
              double opacity = 1.0;
              
              if (index < currentFlowIndex) {
                flowColor = Colors.green; // abgeschlossen
              } else if (index == currentFlowIndex) {
                flowColor = const Color.fromARGB(255, 223, 27, 27); // aktuell
              } else {
                flowColor = Colors.grey; // anstehend
                opacity = 0.5;
              }

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      // Flow-Indikator
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: flowColor.withOpacity(opacity),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      
                      // Flow-Label
                      if (index == currentFlowIndex)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "CURRENT",
                            style: TextStyle(
                              color: flowColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Reset-Bestätigungsdialog
  Future<void> _showResetConfirmation(BuildContext context, FlowTimerService flowTimer) async {
    final loc = S.of(context);
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Reset Timer?",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "This will reset your current flow session. Are you sure?",
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                  child: const Text("CANCEL"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("RESET"),
                  onPressed: () {
                    flowTimer.resetTimer();
                    Navigator.of(context).pop();
                    setState(() {
                      _sessionStart = null;
                    });
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Info-Dialog
  Future<void> _showInfoDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "About Flow Timer",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer,
                size: 48,
                color: Color.fromARGB(255, 223, 27, 27),
              ),
              const SizedBox(height: 16),
              const Text(
                "Flow Timer helps you maintain focus and track your deep work sessions.",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(
                      icon: Icons.timer,
                      text: "Set time for each flow session",
                    ),
                    _buildInfoItem(
                      icon: Icons.repeat,
                      text: "Set number of flows (max 8)",
                    ),
                    _buildInfoItem(
                      icon: Icons.skip_next,
                      text: "Skip to next flow if needed",
                    ),
                    _buildInfoItem(
                      icon: Icons.auto_graph,
                      text: "Track your progress visually",
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(120, 45),
                ),
                child: const Text("GOT IT"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Info-Item
  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white60),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Time-Dialog (restyled)
  // ----------------------------------------------------
  Future<void> _changeTimeDialog(BuildContext ctx) async {
    final loc = S.of(ctx);
    final flowTimer = ctx.read<FlowTimerService>();
    final controller = TextEditingController(text: flowTimer.minutes.toString());
    final focusNode = FocusNode();

    await showDialog<void>(
      context: ctx,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            loc.flowTimerSetTimeTitle,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Set the duration for each flow session",
                style: TextStyle(color: Colors.white60, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                focusNode: focusNode,
                autofocus: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: loc.flowTimerSetTimeHint,
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Text(
                      "min",
                      style: TextStyle(color: Colors.white60, fontSize: 16),
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              const SizedBox(height: 10),
              // Preset-Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [15, 25, 30, 45, 60].map((minutes) {
                  return InkWell(
                    onTap: () {
                      controller.text = minutes.toString();
                      focusNode.unfocus();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        "$minutes",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                  child: const Text("CANCEL"),
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(100, 45),
                  ),
                  child: const Text("SET"),
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    final newM = int.tryParse(controller.text);
                    if (newM != null && newM > 0) {
                      flowTimer.updateMinutes(newM);
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------
  // Flow-Number-Dialog (max. 8, restyled)
  // ----------------------------------------------------
  Future<void> _changeFlowsDialog(BuildContext ctx) async {
    final loc = S.of(ctx);
    final flowTimer = ctx.read<FlowTimerService>();
    final flowController = TextEditingController(text: flowTimer.flows.toString());
    final focusNode = FocusNode();

    await showDialog<void>(
      context: ctx,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            loc.flowTimerSetFlowsTitle,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "How many flow sessions do you want to complete?",
                style: TextStyle(color: Colors.white60, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                focusNode: focusNode,
                autofocus: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
                controller: flowController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: loc.flowTimerSetFlowsHint,
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Text(
                      "flows",
                      style: TextStyle(color: Colors.white60, fontSize: 16),
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              const SizedBox(height: 10),
              // Preset-Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [2, 3, 4, 5, 8].map((flows) {
                  return InkWell(
                    onTap: () {
                      flowController.text = flows.toString();
                      focusNode.unfocus();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        "$flows",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                  child: const Text("CANCEL"),
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(100, 45),
                  ),
                  child: const Text("SET"),
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    final newF = int.tryParse(flowController.text);
                    if (newF != null && newF > 0) {
                      flowTimer.updateFlows(newF.clamp(1, 8));
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------
  // Time Formatting (mm:ss)
  // ----------------------------------------------------
  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  
  // ----------------------------------------------------
  // Duration Formatting (hh:mm:ss)
  // ----------------------------------------------------
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    return hours == '00' 
        ? '$minutes:$seconds' 
        : '$hours:$minutes:$seconds';
  }
}
