//
//  InterstitialViewModel.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//

import Foundation
import GoogleMobileAds

class InterstitialViewModel: NSObject, ObservableObject, FullScreenContentDelegate {
    var interstitialAd: InterstitialAd?
    var onAdDismiss: (() -> Void)?
    
    @MainActor
    func loadAd() async -> Bool {
        do {
            interstitialAd = try await InterstitialAd.load(
                with: Secrets.interstitialUnitID,
                request: Request()
            )
            interstitialAd?.fullScreenContentDelegate = self
            print("✅ Interstitial loaded")
            return true
        } catch {
            print("❌ Failed to load interstitial ad: \(error.localizedDescription)")
            interstitialAd = nil
            return false
        }
    }
    
    @MainActor
    func showAd() {
        guard let ad = interstitialAd,
              let root = UIApplication.topViewController() else {
            print("⚠️ Ad or root VC not ready")
            onAdDismiss?()  // auto-dismiss if ad fails to show
            return
        }
        ad.present(from: root)
        interstitialAd = nil
    }
    
    // MARK: - FullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        onAdDismiss?()
        Task { await loadAd() } // preload next ad
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Failed to present interstitial: \(error.localizedDescription)")
        onAdDismiss?()
    }
}


extension UIApplication {
    static func topViewController(
        _ base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first { $0.isKeyWindow }?.rootViewController }
            .first
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
