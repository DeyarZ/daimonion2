package ple.daimonion

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory
import com.example.daimonion.R  // Achte auf dein package

class MyListTileNativeFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        // 1) my_list_tile.xml inflaten
        val inflater = LayoutInflater.from(context)
        val adView = inflater.inflate(R.layout.my_list_tile, null) as NativeAdView

        // 2) Views holen (Headline, Body, Icon, CTA)
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        val iconView = adView.findViewById<ImageView>(R.id.ad_app_icon)
        val ctaView = adView.findViewById<TextView>(R.id.ad_call_to_action)

        // 3) Headline
        headlineView?.text = nativeAd.headline
        adView.headlineView = headlineView

        // 4) Body (Optional check, falls null)
        val body = nativeAd.body
        if (body != null) {
            bodyView?.text = body
            adView.bodyView = bodyView
        }

        // 5) Icon (Optional)
        val icon = nativeAd.icon
        if (icon != null) {
            iconView?.setImageDrawable(icon.drawable)
            adView.iconView = iconView
        }

        // 6) Call to Action
        val cta = nativeAd.callToAction
        if (cta != null) {
            ctaView?.text = cta
            adView.callToActionView = ctaView
        }

        // 7) NativeAd dem AdView zuweisen
        adView.setNativeAd(nativeAd)

        return adView
    }
}
