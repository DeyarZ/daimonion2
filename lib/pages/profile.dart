// lib/pages/profile.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';               // <-- Für Feedback-Mailto

import '../haertegrad_enum.dart';
import 'gamification_page.dart';
import '../services/gamification_service.dart';               // <-- Für Rang-Anzeige
import 'privacy_and_terms_page.dart';
import '../l10n/generated/l10n.dart';
import 'subscription_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';
  Haertegrad currentHaertegrad = Haertegrad.brutalEhrlich;
  String appVersion = '1.0.0';
  String? profileImagePath;

  @override
  void initState() {
    super.initState();

    if (!Hive.isBoxOpen('settings')) {
      Hive.openBox('settings');
    }
    final box = Hive.box('settings');

    userName = box.get('userName', defaultValue: '');
    final storedIndex = box.get('haertegrad', defaultValue: 2);
    currentHaertegrad = Haertegrad.values[storedIndex];

    profileImagePath = box.get('profileImagePath');
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    // Gamification-Objekt -> Rang
    final gamification = GamificationService();
    final currentStatus = gamification.currentStatus; // z. B. "Rekrut"

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.profileTitle),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(currentStatus),
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

  // ----------------------------------------------------------
  // PROFILE HEADER
  // ----------------------------------------------------------
  Widget _buildProfileHeader(String rank) {
    final loc = S.of(context);
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          loc.profileHeader,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // Profilbild per InkWell antippbar -> Image ändern
        InkWell(
          onTap: _pickNewProfileImage,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[800],
              backgroundImage: _loadProfileImage(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Benutzername
        Text(
          userName.isEmpty ? loc.unknownUser : userName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // Rang
        const SizedBox(height: 4),
        Text(
          rank,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
        ),

        const SizedBox(height: 8),
        GestureDetector(
          onTap: _editProfile,
          child: Text(
            loc.editProfile,
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 223, 27, 27),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider? _loadProfileImage() {
    if (profileImagePath != null && profileImagePath!.isNotEmpty) {
      return FileImage(File(profileImagePath!));
    } else {
      return const AssetImage('assets/icon/app_icon.png');
    }
  }

  Future<void> _pickNewProfileImage() async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final path = picked.path;
        setState(() {
          profileImagePath = path;
        });
        Hive.box('settings').put('profileImagePath', path);
      }
    } catch (e) {
      debugPrint("Image picking error: $e");
    }
  }

  // ----------------------------------------------------------
  // SETTINGS CARD
  // ----------------------------------------------------------
  Widget _buildSettingsCard() {
    final loc = S.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 44, 44, 44),
            Color.fromARGB(255, 48, 48, 48),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          // Titel
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                loc.settingsTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const Divider(color: Colors.grey, height: 1),

          // Härtegrad
          ListTile(
            title:
                Text(loc.hardnessTitle, style: const TextStyle(color: Colors.white)),
            trailing: Text(
              _haertegradToString(context, currentHaertegrad),
              style: const TextStyle(
                color: Color.fromARGB(255, 223, 27, 27),
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: _changeHaertegrad,
          ),
          const Divider(color: Colors.grey, height: 1),

          // Level & XP
          ListTile(
            title: const Text("Level & XP", style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: _goToGamificationPage,
          ),

          const Divider(color: Colors.grey, height: 1),

          // NEU: FEEDBACK-BUTTON
          ListTile(
            leading: const Icon(Icons.feedback, color: Colors.white),
            title:
                Text(loc.feedbackButtonLabel, style: const TextStyle(color: Colors.white)),
            onTap: _sendFeedback, // -> mailto
          ),
        ],
      ),
    );
  }

  // FEEDBACK-FUNKTION -> mailto:
  Future<void> _sendFeedback() async {
    final loc = S.of(context);

    // Falls du eine andere Email willst, hier anpassen
    final email = Uri(
      scheme: 'mailto',
      path: 'manuel@worlitzer.de',
      queryParameters: {
        'subject': Uri.encodeComponent('Feedback App Daimonion'),
      },
    );

    // Start URL
    if (await canLaunchUrl(email)) {
      await launchUrl(email);
    } else {
      // Falls kein E-Mail-Client o.ä.:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.noEmailClientFound)),
      );
    }
  }

  // ----------------------------------------------------------
  // LEGAL CARD
  // ----------------------------------------------------------
  Widget _buildLegalCard() {
    final loc = S.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 44, 44, 44),
            Color.fromARGB(255, 48, 48, 48),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                loc.legalAndAppInfoTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          ListTile(
            title: Text(
              loc.privacyAndTerms,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: _showPrivacy,
          ),
          const Divider(color: Colors.grey, height: 1),
          ListTile(
            title:
                Text(loc.version, style: const TextStyle(color: Colors.white)),
            trailing:
                Text(appVersion, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // ACCOUNT CARD
  // ----------------------------------------------------------
  Widget _buildAccountCard() {
    final loc = S.of(context);
    final isPremium = Hive.box('settings').get('isPremium', defaultValue: false);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 44, 44, 44),
            Color.fromARGB(255, 48, 48, 48),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                loc.accountTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const Divider(color: Colors.grey, height: 1),

          // Upgrade?
          if (!isPremium) ...[
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text(
                loc.upgradeToPremium,
                style: const TextStyle(
                  color: Colors.amber, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _upgradeToPremium,
            ),
            const Divider(color: Colors.grey, height: 1),
          ],

          // Restore
          ListTile(
            leading: const Icon(Icons.restart_alt, color: Colors.white),
            title: Text(
              loc.restorePurchases,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: _restorePurchases,
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // METHODS
  // ----------------------------------------------------------
  void _goToGamificationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GamificationPage()),
    );
  }

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

  String _haertegradToString(BuildContext context, Haertegrad hg) {
    final loc = S.of(context);
    switch (hg) {
      case Haertegrad.normal:
        return loc.hardnessNormal;
      case Haertegrad.hart:
        return loc.hardnessHard;
      case Haertegrad.brutalEhrlich:
        return loc.hardnessBrutal;
    }
  }

  void _editProfile() async {
    final newName = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: userName);
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            S.of(ctx).editProfileTitle,
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: S.of(ctx).editProfileHint,
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                S.of(ctx).cancel,
                style: const TextStyle(color: Color.fromARGB(255, 223, 27, 27)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 223, 27, 27),
              ),
              onPressed: () {
                Navigator.pop(ctx, controller.text.trim());
              },
              child: Text(S.of(ctx).save),
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
      MaterialPageRoute(builder: (_) => const PrivacyAndTermsPage()),
    );
  }

  Future<void> _upgradeToPremium() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionPage()),
    );
  }

  Future<void> _restorePurchases() async {
    final loc = S.of(context);
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPremium = customerInfo.entitlements.all["premium"]?.isActive ?? false;
      if (isPremium) {
        Hive.box('settings').put('isPremium', true);
        _showSuccessDialog(loc.premiumRestored);
        setState(() {});
      } else {
        _showErrorDialog(loc.noActivePurchases);
      }
    } catch (e) {
      _showErrorDialog(loc.restoreError(e.toString()));
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            Text(S.of(ctx).errorTitle, style: const TextStyle(color: Colors.white)),
        content: Text(msg, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(ctx).ok,
                style: const TextStyle(color: Color.fromARGB(255, 223, 27, 27))),
          )
        ],
      ),
    );
  }

  void _showSuccessDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            Text(S.of(ctx).successTitle, style: const TextStyle(color: Colors.white)),
        content: Text(msg, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(ctx).ok,
                style: const TextStyle(color: Color.fromARGB(255, 223, 27, 27))),
          )
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// HÄRTEGRAD PAGE
// ----------------------------------------------------------
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
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.selectHardness),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              loc.hardnessQuestion,
              style: const TextStyle(
                fontSize: 20, 
                color: Colors.white, 
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  RadioListTile<Haertegrad>(
                    title: Text(loc.hardnessNormal,
                        style: const TextStyle(color: Colors.white)), 
                    value: Haertegrad.normal,
                    groupValue: _currentSelection,
                    activeColor: const Color.fromARGB(255, 223, 27, 27),
                    onChanged: (val) => setState(() => _currentSelection = val!),
                  ),
                  Divider(color: Colors.grey[700], height: 1),
                  RadioListTile<Haertegrad>(
                    title: Text(loc.hardnessHard,
                        style: const TextStyle(color: Colors.white)),
                    value: Haertegrad.hart,
                    groupValue: _currentSelection,
                    activeColor: const Color.fromARGB(255, 223, 27, 27),
                    onChanged: (val) => setState(() => _currentSelection = val!),
                  ),
                  Divider(color: Colors.grey[700], height: 1),
                  RadioListTile<Haertegrad>(
                    title: Text(loc.hardnessBrutal,
                        style:
                            const TextStyle(color: Color.fromARGB(255, 223, 27, 27))),
                    value: Haertegrad.brutalEhrlich,
                    groupValue: _currentSelection,
                    activeColor: const Color.fromARGB(255, 223, 27, 27),
                    onChanged: (val) => setState(() => _currentSelection = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 223, 27, 27),
              ),
              onPressed: () => Navigator.pop(context, _currentSelection),
              child: Text(loc.save),
            ),
          ],
        ),
      ),
    );
  }
}
