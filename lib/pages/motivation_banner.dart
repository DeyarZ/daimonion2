// lib/pages/motivation_banner.dart
import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/generated/l10n.dart';

class MotivationBanner extends StatefulWidget {
  const MotivationBanner({Key? key}) : super(key: key);

  @override
  _MotivationBannerState createState() => _MotivationBannerState();
}

class _MotivationBannerState extends State<MotivationBanner> {
  late String _randomQuote;
  late String _randomImage;

  @override
  void initState() {
    super.initState();
    _pickRandomImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hol dir jetzt die Zitate, sobald das Widget Zugriff auf inherited Widgets hat
    _pickRandomQuote();
  }

  void _pickRandomImage() {
    final images = [
      'assets/images/arnold.jpg',
      'assets/images/8bit_squat.png',
      'assets/images/chess.png',
      'assets/images/ferrari.png',
      'assets/images/greek_focus.png',
      'assets/images/napoleon.png',
      'assets/images/ronaldo.png',
      'assets/images/spartan.png',
      'assets/images/tate.png',
      'assets/images/wolf.png',
      'assets/images/alexander.png',
      'assets/images/garage.png',
      'assets/images/gervonta.png',
      'assets/images/gloves.png',
      'assets/images/gymrack.png',
      'assets/images/hustle_rari.png',
      'assets/images/khabib.png',
      'assets/images/lambo_gelb.png',
      'assets/images/limit.png',
      'assets/images/lion.png',
      'assets/images/matrix.png',
      'assets/images/nate.png',
      'assets/images/rolex.png',
    ];
    _randomImage = images[Random().nextInt(images.length)];
  }

  void _pickRandomQuote() {
    final quotes = S.of(context).motivationQuotes.split('||');
    _randomQuote = quotes[Random().nextInt(quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _pickRandomImage();
          _pickRandomQuote();
        });
      },
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: Offset(0, 5),
              blurRadius: 15,
            ),
          ],
          image: DecorationImage(
            image: AssetImage(_randomImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(color: Colors.black.withOpacity(0.2)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.format_quote, color: Color.fromARGB(255, 223, 27, 27), size: 32),
                  const SizedBox(height: 8),
                  Text(
                    _randomQuote,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        S.of(context).tapToRefresh,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
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
