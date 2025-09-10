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
    
    // 🔑 Network monitor
    @EnvironmentObject var networkMonitor: NetworkMonitor

    var body: some View {
           ZStack {
               if showSplash {
                   SplashScreenView()
               } else {
                   if networkMonitor.isConnected {
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
               // Hide splash after 2 seconds
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
