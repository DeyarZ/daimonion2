import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:daimonion_app/l10n/generated/l10n.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/first_time_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.unlock_premium,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.premium_description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildFeatureItem(loc.access_journal),
                      _buildFeatureItem(loc.access_habit_tracker),
                      _buildFeatureItem(loc.unlimited_chat_prompts),
                      _buildFeatureItem(loc.more_to_come),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildPlanOptions(context, loc),
                  const Spacer(),
                  Text(
                    loc.subscription_disclaimer,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Color.fromARGB(255, 223, 27, 27), size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOptions(BuildContext context, S loc) {
    return Column(
      children: [
        _buildPlanCard(
          context,
          title: loc.weekly,
          price: loc.weekly_price,
          description: loc.auto_renewal,
          onTap: () => _showComingSoonDialog(context, loc),
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          context,
          title: loc.monthly,
          price: loc.monthly_price,
          description: loc.auto_renewal,
          onTap: () => _handlePremiumPurchase(context, loc),
          isHighlighted: true,
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          context,
          title: loc.yearly,
          price: loc.yearly_price,
          description: loc.auto_renewal,
          onTap: () => _showComingSoonDialog(context, loc),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String description,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color.fromARGB(255, 223, 27, 27) : Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            Text(
              price,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, S loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.coming_soon),
        content: Text(loc.coming_soon_description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePremiumPurchase(BuildContext context, S loc) async {
    try {
      final offerings = await Purchases.getOfferings();
      final premiumPackage = offerings.current?.availablePackages.firstWhere(
        (pkg) => pkg.identifier == 'premium',
      );

      if (premiumPackage != null) {
        final purchaserInfo = await Purchases.purchasePackage(premiumPackage);
        final isPremium = purchaserInfo.entitlements.all['premium']?.isActive ?? false;

        if (isPremium) {
          Hive.box('settings').put('isPremium', true);
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(loc.thank_you),
              content: Text(loc.premium_activated),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: Text(loc.ok),
                ),
              ],
            ),
          );
        } else {
          _showErrorDialog(context, loc.subscription_failed);
        }
      } else {
        _showErrorDialog(context, loc.premium_not_available);
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fehler'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
