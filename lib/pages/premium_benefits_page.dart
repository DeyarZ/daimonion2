import 'package:flutter/material.dart';
import 'package:daimonion_app/l10n/generated/l10n.dart';
import 'dart:ui';

class PremiumBenefitsPage extends StatelessWidget {
  const PremiumBenefitsPage({Key? key}) : super(key: key);
  
  static const Color primaryRed = Color(0xFFDF1B1B);

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    // Premium benefits list
    final List<Map<String, dynamic>> benefits = [
      {'icon': Icons.chat_bubble_outline, 'title': loc.premium_benefit_unlimited_chat},
      {'icon': Icons.block, 'title': loc.premium_benefit_no_ads},
      {'icon': Icons.book_outlined, 'title': loc.premium_benefit_journal_access},
      {'icon': Icons.trending_up, 'title': loc.premium_benefit_habit_tracker_access},
      {'icon': Icons.check_circle_outline, 'title': loc.premium_benefit_todo_advanced},
      {'icon': Icons.fitness_center, 'title': loc.premium_benefit_training_advanced},
      {'icon': Icons.insert_chart_outlined, 'title': loc.premium_benefit_flow_stats},
      {'icon': Icons.tag, 'title': loc.premium_benefit_tags_stats},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          loc.view_all_premium_benefits,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryRed.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryRed.withOpacity(0.15),
                ),
              ),
            ),
            
            // Main content layout
            Column(
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryRed.withOpacity(0.3),
                              blurRadius: 25,
                              spreadRadius: 5,
                            ),
                          ],
                          border: Border.all(
                            color: primaryRed.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              color: primaryRed,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "PREMIUM",
                              style: TextStyle(
                                color: primaryRed,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Unlock your full potential",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),

                // Benefits list and button in a single column
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Benefits list
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(top: 20, bottom: 100), // Added padding at bottom for button
                                itemCount: benefits.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                      vertical: 12.0,
                                    ),
                                    child: BenefitCard(
                                      icon: benefits[index]['icon'],
                                      title: benefits[index]['title'],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // CTA Button
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  // Price comparison
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryRed.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "\$5.99/month",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "\$3.99/month",
                          style: TextStyle(
                            color: primaryRed,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                          decoration: BoxDecoration(
                            color: primaryRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "SAVE 33%",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Upgrade button
                  GestureDetector(
                    onTap: () {
                      // Implement your purchase logic here
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryRed, Color(0xFFFA3A3A)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryRed.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.flash_on,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "UPGRADE TO PREMIUM",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Trial info
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "7-day free trial, cancel anytime",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extracted benefit card for better organization
class BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  
  const BenefitCard({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PremiumBenefitsPage.primaryRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 8.0,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: PremiumBenefitsPage.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: PremiumBenefitsPage.primaryRed,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.check_circle,
          color: PremiumBenefitsPage.primaryRed,
          size: 22,
        ),
      ),
    );
  }
}