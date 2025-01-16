// auth_service.dart (Dummy-Version)
import 'dart:async';

// "User" minimal definieren:
class LocalUser {
  final String id;
  final String email;
  LocalUser({required this.id, required this.email});
}

class AuthService {
  // Stream, der null sendet, wenn nicht eingeloggt,
  // oder einen LocalUser, wenn eingeloggt.
  final StreamController<LocalUser?> _authStateController =
      StreamController<LocalUser?>.broadcast();

  Stream<LocalUser?> get authStateChanges => _authStateController.stream;

  LocalUser? _currentUser;
  LocalUser? get currentUser => _currentUser;

  // Simples "Login" (Speicher in SharedPreferences o.ä. – hier nur In-Memory)
  Future<LocalUser?> signInWithEmail(String email, String password) async {
    // Hier könntest du in einer echten App
    // passwort-Check aus SharedPrefs oder lokaler DB machen
    // Wir tun jetzt einfach so, als wäre alles ok.
    _currentUser = LocalUser(id: 'someLocalId', email: email);
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  // Registrieren
  Future<LocalUser?> registerWithEmail(String email, String password) async {
    // Normal würdest du in einer lokalen DB ein Benutzer-Objekt anlegen.
    // Wir faken hier nur:
    _currentUser = LocalUser(id: 'someLocalId', email: email);
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  // Abmelden
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  // Am Ende nicht vergessen:
  void dispose() {
    _authStateController.close();
  }
}
