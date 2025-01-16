import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMob import

import '../services/flow_timer_service.dart';

class FlowTimerPage extends StatefulWidget {
  const FlowTimerPage({Key? key}) : super(key: key);

  @override
  _FlowTimerPageState createState() => _FlowTimerPageState();
}

class _FlowTimerPageState extends State<FlowTimerPage> {
  DateTime? _sessionStart;

  // Neue Variablen für Ads
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    // Banner-Ad laden
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd.dispose(); // Ad-Objekt sauber entfernen
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2524075415669673~7860955987', // Deine Anzeigenblock-ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    final flowTimer = context.watch<FlowTimerService>();

    final timeString = _formatTime(flowTimer.secondsLeft);
    final isRunning = flowTimer.isRunning;
    final currentFlowIndex = flowTimer.flowIndex;
    final totalFlows = flowTimer.flows;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus!'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
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

                // Flows: z.B. "Flow 2 / 4"
                Text(
                  'Flow ${currentFlowIndex + 1} / $totalFlows',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
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
                    IconButton(
                      icon: const Icon(Icons.stop_circle),
                      iconSize: 64,
                      color: Colors.redAccent,
                      onPressed: flowTimer.resetTimer,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // AdMob Banner-Ad
          if (_isAdLoaded)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
        ],
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
  // 3) Zeit-Format
  // ------------------------------------------------
  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
