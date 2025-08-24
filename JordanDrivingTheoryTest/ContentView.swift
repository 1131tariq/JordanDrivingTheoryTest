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
    
    var body: some View {
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
    }
}

#Preview {
    ContentView()
}
