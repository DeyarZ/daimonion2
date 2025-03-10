import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:daimonion_app/l10n/generated/l10n.dart';

enum SubscriptionType {
  weekly,
  monthly,
  yearly,
}

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with SingleTickerProviderStateMixin {
  SubscriptionType _selectedPlan = SubscriptionType.monthly; // Default
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Daimonion-Farbe
  final Color accentColor = const Color.fromARGB(255, 223, 27, 27);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        // SCHWARZ -> DUNKELGRAU (sehr subtil)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              const Color(0xFF111111),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Hintergrund-Deko (Kreise in Rot)
            Positioned(
              top: -50,
              right: -50,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header mit Logo links, Close-Button rechts
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Weißes PNG-Logo
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/icon/chat.png',
                                width: 24,
                                height: 24,
                                color: Colors.white,
                              ),
                            ),
                            // Close button
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Premium Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                loc.premium_label, // "PREMIUM" i18n
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.025),

                        // Titel
                        Text(
                          loc.unlock_premium,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.015),

                        // Beschreibung
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            loc.premium_description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.04),

                        // Feature-Liste
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.features_label, // "What's included:"
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureItem(Icons.book, loc.access_journal),
                              const SizedBox(height: 12),
                              _buildFeatureItem(Icons.trending_up,
                                  loc.access_habit_tracker),
                              const SizedBox(height: 12),
                              _buildFeatureItem(Icons.chat_bubble_outline,
                                  loc.unlimited_chat_prompts),
                              const SizedBox(height: 12),
                              _buildFeatureItem(
                                  Icons.add_circle_outline, loc.more_to_come),
                            ],
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.04),

                        // Auswahl der Subscriptions
                        _buildPlanOptions(context, loc),

                        SizedBox(height: screenHeight * 0.04),

                        // Call-to-Action
                        _buildCtaButton(context, loc),

                        SizedBox(height: screenHeight * 0.025),

                        // Disclaimer
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            loc.subscription_disclaimer,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanOptions(BuildContext context, S loc) {
    return Column(
      children: [
        _buildPlanCard(
          context,
          loc: loc,
          plan: SubscriptionType.weekly,
          title: loc.weekly_label,         // "Wöchentlich"
          price: "0,99 €",
          period: "/Woche",
          description: loc.weekly_description, // "Probier's günstig aus"
          icon: Icons.rocket_launch,
          isPopular: false,
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          context,
          loc: loc,
          plan: SubscriptionType.monthly,
          title: loc.monthly_label,         // "Monatlich"
          price: "2,99 €",
          period: "/Monat",
          description: loc.monthly_description, // "Am beliebtesten"
          icon: Icons.military_tech,        // statt Herzen
          isPopular: true,
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          context,
          loc: loc,
          plan: SubscriptionType.yearly,
          title: loc.yearly_label,         // "Jährlich"
          price: "29,99 €",
          period: "/Jahr",
          description: loc.yearly_description, // "Spare über 80%"
          icon: Icons.diamond,
          isPopular: false,
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required S loc,
    required SubscriptionType plan,
    required String title,
    required String price,
    required String period,
    required String description,
    required IconData icon,
    required bool isPopular,
  }) {
    final isSelected = (_selectedPlan == plan);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? accentColor : Colors.white.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icon links
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.7),
                size: 24,
              ),
            ),
            const SizedBox(width: 20),
            // Title + Beschreibung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            loc.most_popular_label, // "Beliebt"
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Preis (rechts)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Auswahl-Indikator (Check)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? accentColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? accentColor
                      : Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context, S loc) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => _handlePurchase(context, loc),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loc.start_free_week_label, // "Kostenlose Woche starten"
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Kaufvorgang
  Future<void> _handlePurchase(BuildContext context, S loc) async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current == null ||
          offerings.current!.availablePackages.isEmpty) {
        _showErrorDialog(context, loc.error_title, loc.premium_not_available);
        return;
      }

      // Produkt-ID je nach Auswahl
      late String productId;
      switch (_selectedPlan) {
        case SubscriptionType.weekly:
          productId = 'com.manuelworlitzer.daimonion.premium.weekly';
          break;
        case SubscriptionType.monthly:
          productId = 'com.manuelworlitzer.daimonion.premium.monthly';
          break;
        case SubscriptionType.yearly:
          productId = 'com.manuelworlitzer.daimonion.premium.yearly';
          break;
      }

      // Das richtige Package raussuchen
      final package = offerings.current!.availablePackages.firstWhere(
        (pkg) => pkg.storeProduct.identifier == productId,
        orElse: () => throw Exception(loc.premium_not_available),
      );

      // Kaufvorgang
      final purchaserInfo = await Purchases.purchasePackage(package);

      // Check, ob premium jetzt aktiv
      final isPremium =
          purchaserInfo.entitlements.all['premium']?.isActive ?? false;
      if (isPremium) {
        Hive.box('settings').put('isPremium', true);
        _showSuccessDialog(context, loc);
      } else {
        _showErrorDialog(context, loc.error_title, loc.subscription_failed);
      }
    } catch (e) {
      _showErrorDialog(context, loc.error_title, e.toString());
    }
  }

  void _showSuccessDialog(BuildContext context, S loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: accentColor),
            const SizedBox(width: 10),
            Text(
              loc.thank_you,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          loc.premium_activated,
          style: TextStyle(color: Colors.white.withOpacity(0.9)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(
              loc.ok,
              style: TextStyle(color: accentColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Icon(Icons.error_outline, color: accentColor),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white.withOpacity(0.9)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "OK",
              style: TextStyle(color: accentColor),
            ),
          ),
        ],
      ),
    );
  }
}
