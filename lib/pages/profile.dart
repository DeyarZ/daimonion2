import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../haertegrad_enum.dart';
import 'gamification_info_page.dart';
import '../services/gamification_service.dart';
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
  String appVersion = '2.0.0';
  String? profileImagePath;
  final GamificationService gamification = GamificationService();

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
    final currentStatus = gamification.currentStatus;
    final isPremium = Hive.box('settings').get('isPremium', defaultValue: false);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar mit Blur-Effekt
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.45,
            pinned: true,
            stretch: true,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hintergrundgradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF1A1A1A),
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                  // Hintergrundmuster
                  ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent],
                      ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      'assets/icon/chat.png',
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.05),
                    ),
                  ),
                  // Profil-Inhalt
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profilbild mit Glow-Effekt
                          GestureDetector(
                            onTap: _pickNewProfileImage,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Schatten-/Glow-Effekt
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isPremium
                                                ? const Color.fromARGB(255, 223, 27, 27)
                                                : Colors.white)
                                            .withOpacity(0.2),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                // Rahmen
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: isPremium
                                          ? [
                                              const Color.fromARGB(255, 223, 27, 27),
                                              const Color(0xFF7D0000)
                                            ]
                                          : [
                                              const Color(0xFF444444),
                                              const Color(0xFF1A1A1A)
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        offset: const Offset(0, 4),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 55,
                                    backgroundColor: Colors.grey[900],
                                    backgroundImage: _loadProfileImage(),
                                    child: profileImagePath == null
                                        ? Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey[700],
                                          )
                                        : null,
                                  ),
                                ),
                                // Kamera-Edit-Indikator
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 223, 27, 27),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          offset: const Offset(0, 2),
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Benutzername
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                userName.isEmpty ? loc.unknownUser : userName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _editProfile,
                                child: const Icon(
                                  Icons.edit,
                                  color: Color.fromARGB(255, 223, 27, 27),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Rang-Abzeichen
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isPremium
                                  ? const Color(0xFF3D0000)
                                  : Colors.black38,
                              border: Border.all(
                                color: isPremium
                                    ? const Color.fromARGB(255, 223, 27, 27)
                                    : Colors.grey[700]!,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPremium ? Icons.military_tech : Icons.shield,
                                  color: isPremium
                                      ? const Color.fromARGB(255, 223, 27, 27)
                                      : Colors.grey[400],
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  currentStatus,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isPremium
                                        ? const Color.fromARGB(255, 223, 27, 27)
                                        : Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Fortschrittsanzeige (immer sichtbar, egal ob Premium oder nicht)
                          _buildProgressIndicator(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Seiteninhalt
          SliverToBoxAdapter(
            child: Container(
              color: Colors.black,
              child: Column(
                children: [
                  // Quick-Action-Buttons
                  _buildQuickActions(context),
                  // Einstellungs-Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSettingsSection(),
                        const SizedBox(height: 20),
                        _buildAccountSection(),
                        const SizedBox(height: 20),
                        _buildLegalSection(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fortschrittsanzeige für Gamification (immer sichtbar)
  Widget _buildProgressIndicator(BuildContext context) {
    final loc = S.of(context);
    final currentLevel = gamification.currentLevel;
    final nextLevel = currentLevel + 1;
    final progress = gamification.levelProgress;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                loc.levelNumber(currentLevel),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    // Hintergrund-Leiste
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    // Fortschrittsanzeige
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 223, 27, 27),
                              Colors.red,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 223, 27, 27)
                                  .withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                loc.levelNumber(nextLevel),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            loc.progressToNextLevel((progress * 100).toInt()),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  // Quick-Action-Buttons – Upgrade-Button wird nur angezeigt, wenn der User kein Premium hat
  Widget _buildQuickActions(BuildContext context) {
    final loc = S.of(context);
    final isPremium = Hive.box('settings').get('isPremium', defaultValue: false);

    List<Widget> quickActionButtons = [
      _buildQuickActionButton(
        icon: Icons.trending_up,
        label: loc.stats,
        onTap: _goToGamificationPage,
      ),
      _buildQuickActionButton(
        icon: Icons.tune,
        label: _haertegradToString(context, currentHaertegrad),
        onTap: _changeHaertegrad,
        isActive: true,
      ),
    ];

    if (!isPremium) {
      quickActionButtons.add(
        _buildQuickActionButton(
          icon: Icons.star_border,
          label: loc.upgrade,
          onTap: _upgradeToPremium,
          isPremium: true,
        ),
      );
    }

    quickActionButtons.add(
      _buildQuickActionButton(
        icon: Icons.feedback,
        label: loc.feedback,
        onTap: _sendFeedback,
      ),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[900]!,
            Colors.grey[850]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: quickActionButtons
            .map((button) => Expanded(child: button))
            .toList(),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isPremium = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPremium
                    ? [
                        const Color.fromARGB(255, 223, 27, 27),
                        const Color(0xFF7D0000)
                      ]
                    : isActive
                        ? [
                            const Color(0xFF444444),
                            const Color(0xFF222222)
                          ]
                        : [
                            const Color(0xFF333333),
                            const Color(0xFF222222)
                          ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (isPremium
                          ? const Color.fromARGB(255, 223, 27, 27)
                          : Colors.black)
                      .withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isPremium ? Colors.white : Colors.white70,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isPremium ? FontWeight.bold : FontWeight.normal,
              color: isPremium
                  ? const Color.fromARGB(255, 223, 27, 27)
                  : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    final loc = S.of(context);
    return _buildSectionCard(
      title: loc.settingsTitle,
      icon: Icons.settings,
      children: [
        _buildActionTile(
          icon: Icons.tune,
          title: loc.hardnessTitle,
          subtitle: loc.hardnessSubtitle,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 223, 27, 27).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color.fromARGB(255, 223, 27, 27).withOpacity(0.3),
              ),
            ),
            child: Text(
              _haertegradToString(context, currentHaertegrad),
              style: const TextStyle(
                color: Color.fromARGB(255, 223, 27, 27),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onTap: _changeHaertegrad,
        ),
        _buildActionTile(
          icon: Icons.trending_up,
          title: loc.levelAndXp,
          subtitle: loc.levelAndXpSubtitle,
          onTap: _goToGamificationPage,
        ),
        _buildActionTile(
          icon: Icons.feedback,
          title: loc.feedbackButtonLabel,
          subtitle: loc.helpImproveDaimonion,
          onTap: _sendFeedback,
        ),
      ],
    );
  }

  Widget _buildLegalSection() {
    final loc = S.of(context);
    return _buildSectionCard(
      title: loc.legalAndAppInfoTitle,
      icon: Icons.info_outline,
      children: [
        _buildActionTile(
          icon: Icons.privacy_tip,
          title: loc.privacyAndTerms,
          subtitle: loc.privacyAndTermsSubtitle,
          onTap: _showPrivacy,
        ),
        _buildActionTile(
          icon: Icons.new_releases,
          title: loc.version,
          subtitle: loc.currentAppVersion,
          trailing: Text(
            appVersion,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          onTap: () {}, // Keine Aktion notwendig
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    final loc = S.of(context);
    final isPremium = Hive.box('settings').get('isPremium', defaultValue: false);
    List<Widget> actions = [];

    if (!isPremium) {
      actions.add(
        _buildActionTile(
          icon: Icons.star,
          title: loc.upgradeToPremium,
          subtitle: loc.upgradeToPremiumSubtitle,
          isPremium: true,
          onTap: _upgradeToPremium,
        ),
      );
    }

    actions.add(
      _buildActionTile(
        icon: Icons.restart_alt,
        title: loc.restorePurchases,
        subtitle: loc.restorePurchasesSubtitle,
        onTap: _restorePurchases,
      ),
    );

    return _buildSectionCard(
      title: loc.accountTitle,
      icon: Icons.account_circle,
      children: actions,
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Abschnitts-Kopfzeile
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color.fromARGB(255, 223, 27, 27),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.grey[850],
          ),
          // Abschnitts-Items
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color.fromARGB(255, 223, 27, 27).withOpacity(0.1),
        highlightColor: const Color.fromARGB(255, 223, 27, 27).withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Icon-Container
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isPremium
                      ? const Color.fromARGB(255, 223, 27, 27).withOpacity(0.1)
                      : Colors.grey[850],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isPremium
                      ? const Color.fromARGB(255, 223, 27, 27)
                      : Colors.white70,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              // Titel und Subtitel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isPremium
                            ? const Color.fromARGB(255, 223, 27, 27)
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: isPremium ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Trailing Widget
              if (trailing != null)
                trailing
              else
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[600],
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _loadProfileImage() {
    if (profileImagePath != null && profileImagePath!.isNotEmpty) {
      return FileImage(File(profileImagePath!));
    }
    return null;
  }

  Future<void> _pickNewProfileImage() async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        final path = picked.path;
        setState(() {
          profileImagePath = path;
        });
        Hive.box('settings').put('profileImagePath', path);
      }
    } catch (e) {
      debugPrint("Image picking error: $e");
      _showErrorToast(S.of(context).imageSelectError);
    }
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _goToGamificationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GamificationInfoPage()),
    );
  }

  Future<void> _changeHaertegrad() async {
    final result = await showModalBottomSheet<Haertegrad>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        Haertegrad _tempSelection = currentHaertegrad;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle-Indikator
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    S.of(context).selectHardness,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHardnessOption(
                    haertegrad: Haertegrad.normal,
                    isSelected: _tempSelection == Haertegrad.normal,
                    onTap: () => setState(() => _tempSelection = Haertegrad.normal),
                  ),
                  const SizedBox(height: 12),
                  _buildHardnessOption(
                    haertegrad: Haertegrad.hart,
                    isSelected: _tempSelection == Haertegrad.hart,
                    onTap: () => setState(() => _tempSelection = Haertegrad.hart),
                  ),
                  const SizedBox(height: 12),
                  _buildHardnessOption(
                    haertegrad: Haertegrad.brutalEhrlich,
                    isSelected: _tempSelection == Haertegrad.brutalEhrlich,
                    onTap: () => setState(() => _tempSelection = Haertegrad.brutalEhrlich),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx, _tempSelection);
                    },
                    child: Text(
                      S.of(context).save,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        currentHaertegrad = result;
      });
      Hive.box('settings').put('haertegrad', result.index);
    }
  }

  Widget _buildHardnessOption({
    required Haertegrad haertegrad,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final loc = S.of(context);
    String title;
    String description;
    Widget icon;

    switch (haertegrad) {
      case Haertegrad.normal:
        title = loc.hardnessNormal;
        description = loc.hardnessNormalDesc;
        icon = const Icon(Icons.sentiment_satisfied, color: Colors.white, size: 24);
        break;
      case Haertegrad.hart:
        title = loc.hardnessHard;
        description = loc.hardnessHardDesc;
        icon = const Icon(Icons.whatshot, color: Colors.orange, size: 24);
        break;
      case Haertegrad.brutalEhrlich:
        title = loc.hardnessBrutal;
        description = loc.hardnessBrutalDesc;
        icon = Image.asset(
          'assets/icon/chat.png',
          width: 24,
          height: 24,
          color: Colors.red,
        );
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
                    const Color.fromARGB(255, 223, 27, 27).withOpacity(0.2),
                    const Color.fromARGB(255, 223, 27, 27).withOpacity(0.05)
                  ]
                : [Colors.grey[850]!, Colors.grey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color.fromARGB(255, 223, 27, 27) : Colors.grey[800]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color.fromARGB(255, 223, 27, 27).withOpacity(0.1) : Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              child: icon,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 223, 27, 27).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color.fromARGB(255, 223, 27, 27),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _haertegradToString(BuildContext context, Haertegrad haertegrad) {
    final loc = S.of(context);
    switch (haertegrad) {
      case Haertegrad.normal:
        return loc.hardnessNormal;
      case Haertegrad.hart:
        return loc.hardnessHard;
      case Haertegrad.brutalEhrlich:
        return loc.hardnessBrutal;
    }
  }

  void _editProfile() async {
    final TextEditingController controller = TextEditingController(text: userName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          S.of(context).editProfileTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: S.of(context).nameLabel,
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color.fromARGB(255, 223, 27, 27)),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color.fromARGB(255, 223, 27, 27),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              S.of(context).cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 223, 27, 27),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        userName = result;
      });
      Hive.box('settings').put('userName', result);
    }
  }

  Future<void> _upgradeToPremium() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionPage()),
    );
  }

  Future<void> _restorePurchases() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).restoringPurchases),
          backgroundColor: Colors.blue[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      final restoredInfo = await Purchases.restorePurchases();
      final entitlements = restoredInfo.entitlements.all;

      if (entitlements.containsKey('premium') &&
          entitlements['premium']?.isActive == true) {
        await Hive.box('settings').put('isPremium', true);
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).purchasesRestoredSuccess),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).noPurchasesToRestore),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Restore error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).purchasesRestoredError),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _sendFeedback() async {
    final loc = S.of(context);
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'manuel@worlitzer.com',
      query:
          'subject=${Uri.encodeComponent(loc.feedbackEmailSubject)}&body=${Uri.encodeComponent(loc.feedbackEmailBody)}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showErrorToast(S.of(context).emailAppNotFound);
      }
    } catch (e) {
      debugPrint("Email launch error: $e");
      _showErrorToast(S.of(context).couldNotSendFeedback);
    }
  }

  void _showPrivacy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyAndTermsPage()),
    );
  }
}
