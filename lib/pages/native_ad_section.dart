// lib/pages/native_ad_section.dart

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdSection extends StatelessWidget {
  final NativeAd? nativeAd;
  final bool isNativeAdLoaded;
  final VoidCallback onGoPremium;
  const NativeAdSection({
    Key? key,
    required this.nativeAd,
    required this.isNativeAdLoaded,
    required this.onGoPremium,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (!isNativeAdLoaded || nativeAd == null) {
      return Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Loading Ad ... or go Premium',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: AdWidget(ad: nativeAd!),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onGoPremium,
          child: Text.rich(
            TextSpan(
              text: 'No more ads. ',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              children: [
                TextSpan(
                  text: 'Get Premium',
                  style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
