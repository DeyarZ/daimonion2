package com.example.daimonion

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // *** HIER: Factory registrieren ***
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "listTile",   // <- Das ist die factoryId, die du in Flutter nutzt
            MyListTileNativeFactory(context)
        )
    }

    override fun onDestroy() {
        // Beim Destroy deregistrieren, um Memory-Leaks zu vermeiden
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
        super.onDestroy()
    }
}
