//
//  InterstitialAdView.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//


import SwiftUI
import GoogleMobileAds

struct InterstitialAdView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var adVM = InterstitialViewModel()
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var hasPresented = false
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        Color.clear
            .task {
                await adVM.loadAd()
                adVM.onAdDismiss = {
                    dismiss()
                    onDismiss?()
                }

                if !hasPresented {
                    hasPresented = true
                    if adVM.interstitialAd != nil {
                        adVM.showAd()
                    } else {
                        // ⚠️ No ad available → dismiss immediately
                        dismiss()
                        onDismiss?()
                    }
                }
            }
    }
}
