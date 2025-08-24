//
//  BannerAdView.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> BannerView {
        // Request an anchored adaptive banner with the screen width
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: UIScreen.main.bounds.width)
        
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        banner.delegate = context.coordinator
        banner.load(Request())
        return banner
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
    
    class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("✅ Banner loaded successfully")
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("❌ Banner failed: \(error.localizedDescription)")
        }
    }
}
