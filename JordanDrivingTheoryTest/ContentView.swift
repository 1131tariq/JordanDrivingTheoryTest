//
//  ContentView.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("language") private var language: String = "en"
    
    @State private var showSplash = true
    
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var purchaseManager: PurchaseManager   // ✅ added
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
            } else {
                if purchaseManager.hasRemovedAds || networkMonitor.isConnected {
                    NavigationStack {
                        if hasSeenOnboarding {
                            MainView()
                        } else {
                            OnboardingView {
                                hasSeenOnboarding = true
                            }
                        }
                    }
                    .onAppear {
                        LocalizedBundle.setLanguage(language)
                    }
                } else {
                    NoConnectionView()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NetworkMonitor())
        .environmentObject(PurchaseManager())
}
