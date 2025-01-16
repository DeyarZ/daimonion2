import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../haertegrad_enum.dart';
import 'privacy_and_terms_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // -------------------------
  // FIELDS
  // -------------------------
  String userName = '';
  Haertegrad currentHaertegrad = Haertegrad.brutalEhrlich;

  // Folgende Flags haben wir im MVP auskommentiert:
  // bool notificationsEnabled = false;
  // bool darkModeEnabled = false;

  String appVersion = '1.0.0';

  // -------------------------
  // INIT
  // -------------------------
  @override
  void initState() {
    super.initState();
    // Ensure settings box is open
    if (!Hive.isBoxOpen('settings')) {
      Hive.openBox('settings');
    }

    final box = Hive.box('settings');

    // User-Name laden
    userName = box.get('userName', defaultValue: '');

    // Härtegrad laden
    final storedIndex = box.get('haertegrad', defaultValue: 2);
    currentHaertegrad = Haertegrad.values[storedIndex];

    // Benachrichtigungen & Dark Mode — auskommentiert
    // notificationsEnabled = box.get('notificationsEnabled', defaultValue: false);
    // darkModeEnabled = box.get('darkModeEnabled', defaultValue: false);
  }

  // -------------------------
  // BUILD
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildSettingsCard(),
            const SizedBox(height: 16),
            _buildLegalCard(),
            const SizedBox(height: 16),
            _buildAccountCard(),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // HEADER
  // -------------------------
  Widget _buildProfileHeader() {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Text(
          'WHO COULD YOU BE?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const CircleAvatar(
          radius: 60,
          backgroundImage: AssetImage('assets/icon/app_icon.jpeg'),
        ),
        const SizedBox(height: 16),
        Text(
          userName.isEmpty ? 'Unbekannter Nutzer' : userName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _editProfile,
          child: const Text(
            'Bearbeiten',
            style: TextStyle(
              fontSize: 14,
              color: Colors.redAccent,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------
  // SETTINGS
  // -------------------------
  Widget _buildSettingsCard() {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  'EINSTELLUNGEN',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            // Härtegrad
            ListTile(
              title: const Text('Härtegrad', style: TextStyle(color: Colors.white)),
              trailing: Text(
                _haertegradToString(currentHaertegrad),
                style: const TextStyle(color: Colors.redAccent),
              ),
              onTap: _changeHaertegrad,
            ),

            // ---------------------------------------------------------
            // AUSKOMMENTIERTE FEATURES: PUSH NOTIFS & DARK MODE
            // ---------------------------------------------------------
            /*
            const Divider(color: Colors.grey, height: 1),
            SwitchListTile(
              title: const Text('Benachrichtigungen', style: TextStyle(color: Colors.white)),
              activeColor: Colors.redAccent,
              value: notificationsEnabled,
              onChanged: (val) {
                setState(() {
                  notificationsEnabled = val;
                });
                Hive.box('settings').put('notificationsEnabled', val);
              },
            ),
            const Divider(color: Colors.grey, height: 1),
            SwitchListTile(
              title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
              activeColor: Colors.redAccent,
              value: darkModeEnabled,
              onChanged: (val) {
                setState(() {
                  darkModeEnabled = val;
                });
                Hive.box('settings').put('darkModeEnabled', val);
              },
            ),
            */
          ],
        ),
      ),
    );
  }

  // -------------------------
  // LEGAL & VERSION
  // -------------------------
  Widget _buildLegalCard() {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  'RECHTLICHES & APP-INFOS',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            ListTile(
              title: const Text('Datenschutz & Nutzungsbedingungen',
                  style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: _showPrivacy,
            ),
            const Divider(color: Colors.grey, height: 1),
            ListTile(
              title: const Text('Version', style: TextStyle(color: Colors.white)),
              trailing: Text(appVersion, style: const TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // ACCOUNT
  // -------------------------
  Widget _buildAccountCard() {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  'ACCOUNT',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(color: Colors.grey, height: 1),

            // ---------------------------------------------------------
            // AUSKOMMENTIERT: ABMELDEN, ACCOUNT LÖSCHEN, PREMIUM
            // ---------------------------------------------------------
            /*
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.white),
              title: const Text('Abmelden', style: TextStyle(color: Colors.white)),
              onTap: _signOut,
            ),
            const Divider(color: Colors.grey, height: 1),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
              title: const Text('Account löschen', style: TextStyle(color: Colors.redAccent)),
              onTap: _deleteAccount,
            ),
            const Divider(color: Colors.grey, height: 1),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text(
                'Upgrade zu Premium',
                style: TextStyle(color: Colors.amber),
              ),
              onTap: _upgradeToPremium,
            ),
            */
          ],
        ),
      ),
    );
  }

  // -------------------------
  // FUNCS
  // -------------------------
  Future<void> _changeHaertegrad() async {
    final result = await Navigator.push<Haertegrad>(
      context,
      MaterialPageRoute(
        builder: (context) => HaertegradPage(selectedHaertegrad: currentHaertegrad),
      ),
    );
    if (result != null) {
      setState(() {
        currentHaertegrad = result;
      });
      Hive.box('settings').put('haertegrad', currentHaertegrad.index);
    }
  }

  String _haertegradToString(Haertegrad hg) {
    switch (hg) {
      case Haertegrad.normal:
        return 'Normal';
      case Haertegrad.hart:
        return 'Hart';
      case Haertegrad.brutalEhrlich:
        return 'Brutal ehrlich';
    }
  }

  // EditProfile => Zeige Dialog
  void _editProfile() async {
    final newName = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: userName);
        return AlertDialog(
          title: const Text('Name bearbeiten'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Dein Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx, controller.text.trim());
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        userName = newName;
      });
      Hive.box('settings').put('userName', newName);
    }
  }

  void _showPrivacy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyAndTermsPage()),
    );
  }

  // ---------------------------------------------------------
  // Auskommentierte Dummy-Funktionen
  // ---------------------------------------------------------
  /*
  void _signOut() {
    debugPrint('Abmelden geklickt -> No real backend, so dummy');
  }

  void _deleteAccount() {
    debugPrint('Account löschen geklickt -> No real backend, so dummy');
  }

  void _upgradeToPremium() {
    debugPrint('Upgrade zu Premium geklickt -> Payment not implemented yet, dummy');
  }
  */
}

// ----------------------------------------------
// SEPARATE PAGE FOR HÄRTEGRAD-AUSWAHL
// ----------------------------------------------
class HaertegradPage extends StatefulWidget {
  final Haertegrad selectedHaertegrad;

  const HaertegradPage({Key? key, required this.selectedHaertegrad}) : super(key: key);

  @override
  State<HaertegradPage> createState() => _HaertegradPageState();
}

class _HaertegradPageState extends State<HaertegradPage> {
  late Haertegrad _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedHaertegrad;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Härtegrad wählen'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'WIE HART SOLL ICH ZU DIR SEIN?',
              style: TextStyle(
                  fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.grey[850],
              child: Column(
                children: [
                  RadioListTile<Haertegrad>(
                    title: const Text('Normal', style: TextStyle(color: Colors.white)),
                    value: Haertegrad.normal,
                    groupValue: _currentSelection,
                    activeColor: Colors.redAccent,
                    onChanged: (val) => setState(() => _currentSelection = val!),
                  ),
                  Divider(color: Colors.grey[700], height: 1),
                  RadioListTile<Haertegrad>(
                    title: const Text('Hart', style: TextStyle(color: Colors.white)),
                    value: Haertegrad.hart,
                    groupValue: _currentSelection,
                    activeColor: Colors.redAccent,
                    onChanged: (val) => setState(() => _currentSelection = val!),
                  ),
                  Divider(color: Colors.grey[700], height: 1),
                  RadioListTile<Haertegrad>(
                    title: const Text('Brutal ehrlich', style: TextStyle(color: Colors.redAccent)),
                    value: Haertegrad.brutalEhrlich,
                    groupValue: _currentSelection,
                    activeColor: Colors.redAccent,
                    onChanged: (val) => setState(() => _currentSelection = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(context, _currentSelection),
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
