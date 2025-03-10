// lib/services/flow_timer_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
// NEU: Import für Gamification
import 'package:daimonion_app/services/gamification_service.dart';

class FlowTimerService extends ChangeNotifier {
  int _minutes = 25;  // Dauer eines Flows (Default 25 Min)
  int _flows = 4;     // Anzahl der Flows nacheinander
  int _flowIndex = 0; // Aktueller Flow (0-based)
  int _secondsLeft = 25 * 60;
  bool _isRunning = false;

  Timer? _timer;

  // ------------------------------------------------
  // Getter
  // ------------------------------------------------
  int get minutes => _minutes;
  int get flows => _flows;
  int get flowIndex => _flowIndex;
  int get secondsLeft => _secondsLeft;
  bool get isRunning => _isRunning;

  // ------------------------------------------------
  // Setzen der Minuten (z.B. per Dialog)
  // ------------------------------------------------
  void updateMinutes(int newMins) {
    _minutes = newMins;
    resetTimer();
    notifyListeners();
  }

  // ------------------------------------------------
  // Setzen der Anzahl Flows
  // ------------------------------------------------
  void updateFlows(int newFlows) {
    _flows = newFlows;
    resetTimer();
    notifyListeners();
  }

  // ------------------------------------------------
  // Timer starten
  // ------------------------------------------------
  void startTimer() {
    // Falls noch ein Timer läuft, abbrechen
    _timer?.cancel();

    // Wenn wir komplett fertig waren oder neu starten:
    if (!_isRunning && _secondsLeft == 0 && _flowIndex < _flows) {
      _secondsLeft = _minutes * 60;
    }

    _isRunning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        // Flow abgeschlossen
        timer.cancel();
        _isRunning = false;
        _secondsLeft = 0;
        notifyListeners();

        final flowDuration = _minutes; // Dauer dieses Flows
        _storeFlowSession(flowDuration); // Speichern & XP vergeben

        _flowIndex++;
        if (_flowIndex < _flows) {
          // Nächster Flow
          _secondsLeft = _minutes * 60;
          startTimer();
        } else {
          // ALLE FLOWS DONE => Reset nach kurzem Delay
          Future.delayed(const Duration(seconds: 2), () {
            resetTimer();
          });
        }
      } else {
        _secondsLeft--;
        notifyListeners();
      }
    });
  }

  // ------------------------------------------------
  // Timer pausieren
  // ------------------------------------------------
  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  // ------------------------------------------------
  // Timer zurücksetzen
  // ------------------------------------------------
  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _flowIndex = 0;
    _secondsLeft = _minutes * 60;
    notifyListeners();
  }

  // ------------------------------------------------
  // Aktuellen Flow überspringen
  // (Keine Teil-XP, einfach nur weiter zum nächsten Flow)
  // ------------------------------------------------
  void skipToNextFlow() {
    // Nur ausführen, wenn es noch einen Flow gibt
    if (_flowIndex < _flows - 1) {
      // Laufenden Timer stoppen
      _timer?.cancel();
      _isRunning = false;

      // Nächsten Flow beginnen
      _flowIndex++;
      _secondsLeft = _minutes * 60;
      notifyListeners();
    }
  }

  // ------------------------------------------------
  // Speichern der Flow-Session in Hive
  // + XP-Vergabe
  // ------------------------------------------------
  Future<void> _storeFlowSession(int durationMinutes) async {
    final box = await Hive.openBox<Map>('flow_sessions');
    final now = DateTime.now();

    // Flow in die DB schreiben
    await box.add({
      'date': now.millisecondsSinceEpoch,
      'minutes': durationMinutes,
    });

    // XP vergeben: 1 XP pro 10 Minuten (abgerundet)
    final int xpToAward = durationMinutes ~/ 10;
    if (xpToAward > 0) {
      GamificationService().addXPWithStreak(xpToAward);
    }
  }
}
