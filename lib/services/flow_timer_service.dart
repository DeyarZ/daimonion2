import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FlowTimerService extends ChangeNotifier {
  int _minutes = 25; // Wie lange dauert 1 Flow in Minuten?
  int _flows = 4; // Wie viele Flows hintereinander (du kannst mehr als 4)
  int _flowIndex = 0; // Welcher Flow ist grade dran?
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
  // Setzen der Anzahl Flows (z.B. per Dialog)
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

        final flowDuration = _minutes; // Dauer des abgeschlossenen Flows
        _storeFlowSession(flowDuration); // Speichern der Flow-Session

        _flowIndex++;
        if (_flowIndex < _flows) {
          // Nächster Flow
          _secondsLeft = _minutes * 60;
          startTimer();
        } else {
          // ALLE FLOWS DONE => autom. Reset
          // Kleiner Delay, damit man kurz sieht, dass der letzte Flow fertig ist
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
  // Speichern der Flow-Session in Hive
  // ------------------------------------------------
  Future<void> _storeFlowSession(int durationMinutes) async {
    final box = await Hive.openBox<Map>('flow_sessions');
    final now = DateTime.now();

    await box.add({
      'date': now.millisecondsSinceEpoch,
      'minutes': durationMinutes,
    });
  }
}
