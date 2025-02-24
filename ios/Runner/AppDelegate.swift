import UIKit
import Flutter
import GoogleMobileAds
import flutter_google_mobile_ads // Für FLTGoogleMobileAdsPlugin

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)
        
        // Hol dir den FlutterViewController
        let controller = window?.rootViewController as! FlutterViewController

        // Deine Factory instanzieren
        let factory = MyListTileNativeAdFactory()
        
        // Factory registrieren
        FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
            controller.binaryMessenger,
            factoryId: "listTile",
            nativeAdFactory: factory
        )

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        // Hier unregistern wir 
        FLTGoogleMobileAdsPlugin.unregisterNativeAdFactory(self.binaryMessenger, factoryId: "listTile")
        return super.applicationWillTerminate(application)
    }
}
