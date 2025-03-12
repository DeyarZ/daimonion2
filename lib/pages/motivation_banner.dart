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

class _MotivationBannerState extends State<MotivationBanner> with SingleTickerProviderStateMixin {
  late String _randomQuote;
  late String _randomImage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isFavorite = false;
  List<String> _favoriteQuotes = [];

  @override
  void initState() {
    super.initState();
    _pickRandomImage();
    
    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pickRandomQuote();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    _isFavorite = _favoriteQuotes.contains(_randomQuote);
  }

  void _refreshContent() {
    HapticFeedback.lightImpact();
    setState(() {
      _animationController.reset();
      _pickRandomImage();
      _pickRandomQuote();
      _animationController.forward();
    });
  }
  
  void _toggleFavorite() {
    setState(() {
      if (_isFavorite) {
        _favoriteQuotes.remove(_randomQuote);
      } else {
        _favoriteQuotes.add(_randomQuote);
      }
      _isFavorite = !_isFavorite;
      HapticFeedback.mediumImpact();
    });
  }
  
  void _shareQuote() {
    // Share functionality would be implemented here
    HapticFeedback.mediumImpact();
    // For example: Share.share(_randomQuote);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).quoteShared)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _refreshContent,
      onDoubleTap: _toggleFavorite,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          height: 180, // Slightly taller
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
                offset: const Offset(0, 5),
                blurRadius: 15,
              ),
            ],
            image: DecorationImage(
              image: AssetImage(_randomImage),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.65), // Slightly less dark for better image visibility
                BlendMode.darken,
              ),
            ),
          ),
          child: Stack(
            children: [
              // Gradient overlay for better text readability
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Blur effect
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5), // Reduced blur for more clarity
                    child: Container(color: Colors.black.withOpacity(0.1)),
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row with quote icon and actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.format_quote,
                          color: Color.fromARGB(255, 223, 27, 27),
                          size: 32,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.white,
                              ),
                              onPressed: _toggleFavorite,
                              tooltip: S.of(context).favoriteTooltip,
                              iconSize: 22,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(
                                Icons.share_outlined,
                                color: Colors.white,
                              ),
                              onPressed: _shareQuote,
                              tooltip: S.of(context).shareTooltip,
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Spacer to push quote text to center
                    const Spacer(),
                    
                    // Quote text
                    Text(
                      _randomQuote,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17, // Slightly larger
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        height: 1.4,
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.black,
                            offset: Offset(0.5, 0.5),
                          ),
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // Bottom row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tap instructions with icon
                        Row(
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: Colors.white.withOpacity(0.6),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              S.of(context).tapToRefresh,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        
                        // Double tap instructions
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.favorite_border,
                        //       color: Colors.white.withOpacity(0.6),
                        //       size: 12,
                        //     ),
                        //     const SizedBox(width: 4),
                        //     Text(
                        //       S.of(context).doubleTapToFavorite,
                        //       style: TextStyle(
                        //         color: Colors.white.withOpacity(0.7),
                        //         fontSize: 12,
                        //         fontStyle: FontStyle.italic,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}