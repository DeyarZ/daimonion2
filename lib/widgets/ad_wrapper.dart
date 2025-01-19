// lib/widgets/ad_wrapper.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdWrapper extends StatefulWidget {
  final Widget child;

  // Optional: Du könntest dem Wrapper noch ein "bannerAdUnitId" übergeben,
  // falls du verschiedene IDs hast. Oder du belässt es bei einer fixen ID.
  
  const AdWrapper({
    Key? key,
    required this.child,
    // this.bannerAdUnitId = 'ca-app-pub-2524075415669673~7860955987',
  }) : super(key: key);

  @override
  State<AdWrapper> createState() => _AdWrapperState();
}

class _AdWrapperState extends State<AdWrapper> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    // Check ob Premium => Wenn NICHT Premium => Ad laden
    final isPremium = Hive.box('settings').get('isPremium', defaultValue: false);
    if (!isPremium) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      // Wenn du nur 1 ID hast, schreibst du sie fix hier rein:
      adUnitId: 'ca-app-pub-2524075415669673/5094652840',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = Hive.box('settings').get('isPremium', defaultValue: false);

    // Wenn premium => zeig KEINE Ads
    // Oder wenn Ad (noch) nicht geladen => zeig nur child
    if (isPremium || !_isAdLoaded) {
      return widget.child;
    }

    // Wenn NICHT premium & ad ist loaded => Stack child + Banner
    return Stack(
      children: [
        widget.child, // Das eigentliche Page-UI
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
      ],
    );
  }
}