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
    @State private var hasPresented = false
    var onDismiss: (() -> Void)? = nil  // <-- Add this


    var body: some View {
        // Empty view since we don't need a loading placeholder
        Color.clear
            .task {
                await adVM.loadAd()
                adVM.onAdDismiss = { dismiss() }

                if !hasPresented, adVM.interstitialAd != nil {
                    hasPresented = true
                    adVM.showAd()
                }
            }
    }
}
