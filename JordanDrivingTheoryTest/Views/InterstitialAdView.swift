import SwiftUI
import GoogleMobileAds

struct InterstitialAdView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var adVM = InterstitialViewModel()
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var hasPresented = false
    @State private var isLoading = true
    var onDismiss: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            // Loading content
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                .padding()
                .background(Color.black.opacity(0.4))
                .cornerRadius(16)
            }
        }
        .task {
            adVM.onAdDismiss = {
                dismiss()
                onDismiss?()
            }

            // Load the ad asynchronously
            let success = await adVM.loadAd()
            isLoading = false

            if !hasPresented {
                hasPresented = true
                if success, adVM.interstitialAd != nil {
                    adVM.showAd()
                } else {
                    print("⚠️ No ad available → dismissing")
                    dismiss()
                    onDismiss?()
                }
            }
        }
    }
}
