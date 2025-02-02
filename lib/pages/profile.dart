// lib/pages/profile.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:collection/collection.dart'; // Für firstWhereOrNull

import '../haertegrad_enum.dart';
import 'privacy_and_terms_page.dart';
import '../l10n/generated/l10n.dart';

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
  }

  // -------------------------
  // BUILD
  // -------------------------
  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.profileTitle),
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
    final loc = S.of(context);
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          loc.profileHeader,
          style: const TextStyle(
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
          userName.isEmpty ? loc.unknownUser : userName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _editProfile,
          child: Text(
            loc.editProfile,
            style: const TextStyle(
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
    final loc = S.of(context);
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  loc.settingsTitle,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            // Härtegrad
            ListTile(
              title: Text(loc.hardnessTitle, style: const TextStyle(color: Colors.white)),
              trailing: Text(
                _haertegradToString(context, currentHaertegrad),
                style: const TextStyle(color: Colors.redAccent),
              ),
              onTap: _changeHaertegrad,
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // LEGAL & VERSION
  // -------------------------
  Widget _buildLegalCard() {
    final loc = S.of(context);
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  loc.legalAndAppInfoTitle,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            ListTile(
              title: Text(loc.privacyAndTerms, style: const TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: _showPrivacy,
            ),
            const Divider(color: Colors.grey, height: 1),
            ListTile(
              title: Text(loc.version, style: const TextStyle(color: Colors.white)),
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
    final loc = S.of(context);
    final isPremium = Hive.box('settings').get('isPremium', defaultValue: false);
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  loc.accountTitle,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            if (!isPremium) ...[
              ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text(
                  loc.upgradeToPremium,
                  style: const TextStyle(color: Colors.amber),
                ),
                onTap: _upgradeToPremium,
              ),
              const Divider(color: Colors.grey, height: 1),
            ],
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

  // EDIT PROFILE => Name
  void _editProfile() async {
    final newName = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: userName);
        return AlertDialog(
          title: Text(S.of(ctx).editProfileTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: S.of(ctx).editProfileHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(ctx).cancel),
            ),
            ElevatedButton(
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
      MaterialPageRoute(builder: (context) => const PrivacyAndTermsPage()),
    );
  }

  Future<void> _upgradeToPremium() async {
    final loc = S.of(context);
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        final premiumPackage = offerings.current!.availablePackages.firstWhereOrNull(
          (pkg) => pkg.identifier == "premium",
        );
        if (premiumPackage == null) {
          _showErrorDialog(loc.premiumPackageNotFound);
          return;
        }
        final purchaserInfo = await Purchases.purchasePackage(premiumPackage);
        final isPremium = purchaserInfo.entitlements.all["premium"]?.isActive ?? false;
        if (isPremium) {
          Hive.box('settings').put('isPremium', true);
          _showSuccessDialog(loc.premiumUpgradeSuccess);
          setState(() {});
        }
      } else {
        _showErrorDialog(loc.noOffersAvailable);
      }
    } catch (e) {
      _showErrorDialog(loc.purchaseError(e.toString()));
    }
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
        title: Text(S.of(ctx).errorTitle),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(ctx).ok),
          )
        ],
      ),
    );
  }

  void _showSuccessDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(ctx).successTitle),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(ctx).ok),
          )
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// SEPARATE PAGE FOR HÄRTEGRAD-AUSWAHL
// ---------------------------------------------------------
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
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              loc.hardnessQuestion,
              style: const TextStyle(
                  fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.grey[850],
              child: Column(
                children: [
                  RadioListTile<Haertegrad>(
                    title: Text(loc.hardnessNormal, style: const TextStyle(color: Colors.white)),
                    value: Haertegrad.normal,
                    groupValue: _currentSelection,
                    activeColor: Colors.redAccent,
                    onChanged: (val) => setState(() => _currentSelection = val!),
                  ),
                  Divider(color: Colors.grey[700], height: 1),
                  RadioListTile<Haertegrad>(
                    title: Text(loc.hardnessHard, style: const TextStyle(color: Colors.white)),
                    value: Haertegrad.hart,
                    groupValue: _currentSelection,
                    activeColor: Colors.redAccent,
                    onChanged: (val) => setState(() => _currentSelection = val!),
                  ),
                  Divider(color: Colors.grey[700], height: 1),
                  RadioListTile<Haertegrad>(
                    title: Text(loc.hardnessBrutal, style: const TextStyle(color: Colors.redAccent)),
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
              child: Text(loc.save),
            ),
          ],
        ),
      ),
    );
  }
}
