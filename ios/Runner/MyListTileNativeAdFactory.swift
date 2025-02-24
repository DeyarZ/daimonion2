import UIKit
import GoogleMobileAds
import flutter_google_mobile_ads // <- Brauchen wir für FLTNativeAdFactory

class MyListTileNativeAdFactory: NSObject, FLTNativeAdFactory {
    
    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [AnyHashable : Any]? = nil
    ) -> GADNativeAdView {
        
        let adView = GADNativeAdView(frame: .zero)

        // Headline
        let headlineLabel = UILabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.text = nativeAd.headline
        headlineLabel.textColor = .white
        headlineLabel.font = UIFont.boldSystemFont(ofSize: 16)
        adView.addSubview(headlineLabel)
        adView.headlineView = headlineLabel

        // Body (optional)
        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.text = nativeAd.body
        bodyLabel.textColor = .lightGray
        adView.addSubview(bodyLabel)
        adView.bodyView = bodyLabel

        // Icon (optional)
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        if let icon = nativeAd.icon {
            iconImageView.image = icon.image
        }
        adView.addSubview(iconImageView)
        adView.iconView = iconImageView

        // CTA
        let ctaButton = UIButton(type: .system)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.setTitle(nativeAd.callToAction, for: .normal)
        ctaButton.setTitleColor(.black, for: .normal)
        ctaButton.backgroundColor = .yellow
        ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        adView.addSubview(ctaButton)
        adView.callToActionView = ctaButton

        // Advertiser
        if let adv = nativeAd.advertiser {
            let advLabel = UILabel()
            advLabel.translatesAutoresizingMaskIntoConstraints = false
            advLabel.text = adv
            advLabel.textColor = .gray
            adView.addSubview(advLabel)
            adView.advertiserView = advLabel
        }

        // Layout Constraints (Bsp.)
        NSLayoutConstraint.activate([
            headlineLabel.topAnchor.constraint(equalTo: adView.topAnchor, constant: 8),
            headlineLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8),
            headlineLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),

            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4),
            bodyLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8),
            bodyLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),

            iconImageView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 8),
            iconImageView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            ctaButton.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            ctaButton.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            ctaButton.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -8),
            ctaButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -8),
        ])

        // NativeAd zuweisen
        adView.nativeAd = nativeAd

        return adView
    }
}
