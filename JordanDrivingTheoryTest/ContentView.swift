//
//  ContentView.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//
//
//import SwiftUI
//
//struct ContentView: View {
//    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
//    @AppStorage("language") private var language: String = "en"
//    
//    var body: some View {
//        NavigationStack {
//            if hasSeenOnboarding {
//                MainView()
//            } else {
//                OnboardingView {
//                    hasSeenOnboarding = true
//                }
//            }
//        }
//        .onAppear {
//            LocalizedBundle.setLanguage(language)
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}

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
    
    // 🔑 New state for splash screen
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
            } else {
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
        .onAppear {
            // Hide splash after 3 seconds
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
}
