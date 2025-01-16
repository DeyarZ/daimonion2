import 'dart:async';
import 'package:flutter/material.dart';

class FlowTimerService extends ChangeNotifier {
  int _minutes = 25;        // Wie lange dauert 1 Flow in Minuten?
  int _flows = 4;          // Wie viele Flows hintereinander (max 4)?
  int _flowIndex = 0;      // Welcher Flow (0..3)?
  int _secondsLeft = 25*60; 
  bool _isRunning = false;

  Timer? _timer;

  // ------------------------------------------------
  // Getter / Setter
  // ------------------------------------------------
  int get minutes => _minutes;
  int get flows => _flows;
  int get flowIndex => _flowIndex;
  int get secondsLeft => _secondsLeft;
  bool get isRunning => _isRunning;

  // Du kannst sie anpassen, falls der User im UI was ändert
  void updateMinutes(int newMins) {
    _minutes = newMins;
    resetTimer(); // Nach dem Ändern am besten reset
    notifyListeners();
  }

  void updateFlows(int newFlows) {
    _flows = newFlows;
    resetTimer(); 
    notifyListeners();
  }

  // ------------------------------------------------
  // Timer starten
  // ------------------------------------------------
  void startTimer() {
    // Falls schon läuft, abbrechen
    _timer?.cancel();  

    // Falls wir fresh starten (z. B. flowIndex=0) => ensure secondsLeft = minutes*60
    if (!_isRunning && _secondsLeft == 0 && _flowIndex < _flows) {
      _secondsLeft = _minutes * 60;
    }
    _isRunning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        // Flow fertig
        timer.cancel();
        _isRunning = false;
        _secondsLeft = 0;
        notifyListeners();

        // Nächsten Flow anwerfen
        _flowIndex++;
        if (_flowIndex < _flows) {
          // Resette die Zeit für den neuen Flow
          _secondsLeft = _minutes * 60;
          // Starte den Timer erneut
          startTimer(); 
        } else {
          // Alle Flows fertig => do nothing or show message
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
}
