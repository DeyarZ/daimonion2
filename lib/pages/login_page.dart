import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Zeig meinetwegen nur eine Info: "Login später implementieren"
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Login / Registrierung'),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'Login wird später noch implementiert...',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_isLogin ? 'Anmelden' : 'Registrieren'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // E-Mail
              TextField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'E-Mail',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Passwort
              TextField(
                controller: _passCtrl,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Passwort',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMsg != null)
                Text(_errorMsg!, style: const TextStyle(color: Colors.redAccent)),
              if (_isLoading) const CircularProgressIndicator(),
              const SizedBox(height: 16),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: _isLoading ? null : _handleEmailPass,
                child: Text(_isLogin ? 'Login' : 'Registrieren'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _errorMsg = null;
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Noch keinen Account? Hier registrieren'
                      : 'Schon Account? Hier einloggen',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleEmailPass() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    // Fake-lokal: Speichere “eingeloggt” in SharedPreferences
    try {
      final email = _emailCtrl.text.trim();
      final pass = _passCtrl.text.trim();
      if (email.isEmpty || pass.isEmpty) {
        throw Exception('E-Mail oder Passwort leer');
      }
      final prefs = await SharedPreferences.getInstance();
      if (_isLogin) {
        // Prüfe (Dummy) – z. B. Lese "registeredEmail" und "registeredPass" aus SharedPrefs
        final regEmail = prefs.getString('registeredEmail');
        final regPass = prefs.getString('registeredPass');
        if (regEmail == email && regPass == pass) {
          // success
          prefs.setBool('loggedIn', true);
        } else {
          throw Exception('Login fehlgeschlagen (keine Übereinstimmung).');
        }
      } else {
        // Registrieren – speichere in SharedPrefs
        prefs.setString('registeredEmail', email);
        prefs.setString('registeredPass', pass);
        prefs.setBool('loggedIn', true);
      }
    } catch (e) {
      setState(() => _errorMsg = e.toString());
    }
    setState(() => _isLoading = false);
  }
}
*/
