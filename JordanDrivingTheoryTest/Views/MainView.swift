//
//  MainView.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var langMgr = LanguageManager()
    @EnvironmentObject var purchaseManager: PurchaseManager
    let freeExamIDs: Set<Int> = [1, 2,3,4,5,6,7,8]
    
    // 1. Ad + navigation state
    @State private var showAd = false
    @State private var pendingQuestions: [Question]? = nil
    @State private var navigateToTest = false
    
    // 2. Your exams
    let exams: [Exam] = (1...8).map {
        Exam(id: $0,
             titleKey: "exam_\($0)",
             filename: "questions\($0)")
    }
    
    var body: some View {
        ZStack {
            Image("backdrop2").resizable()
                .scaledToFill()
                .ignoresSafeArea().opacity(0.7)
            
            NavigationStack {
                
                VStack() {
                    // Language picker
                    Picker("Language", selection: $langMgr.language) {
                        Text("English").tag("en")
                        Text("العربية").tag("ar")
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 220) // keeps picker smaller
                    Spacer()
                    
                    Text(localizedKey: "main_action_title")
                        .font(.largeTitle)
                        .padding(.bottom, 10)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Preset exams
                            ForEach(exams) { exam in
                                let isLocked = !freeExamIDs.contains(exam.id) && !purchaseManager.hasRemovedAds
                                
                                Button {
                                    if isLocked {
                                        // Prompt user to purchase unlock
                                        Task { await purchaseManager.purchaseRemoveAds() }
                                    } else {
                                        pendingQuestions = loadQuestions(from: exam.filename)
                                        showAd = true
                                    }
                                } label: {
                                    HStack {
                                        Text("\(NSLocalizedString("Exam", comment: "")) \(exam.id)")
                                        if isLocked {
                                            Image(systemName: "lock.fill")
                                        }
                                    }
                                    .frame(maxWidth: 150)
                                    .padding()
                                    .background(isLocked ? Color.gray : Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(500)
                                }
                                .disabled(isLocked)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 10)
                    if !purchaseManager.hasRemovedAds {
                        BannerAdView(adUnitID: Secrets.bannerUnitID)
                            .frame(height: 50) // Height adjusts automatically based on device width
                    }
                    
                }
                .padding(.horizontal, 80)   // ✅ only horizontal padding
                
                if !purchaseManager.hasRemovedAds {
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await purchaseManager.purchaseRemoveAds()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "lock.open.fill")
                                Text(localizedKey: "Unlock All Exams + Remove Ads")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: 350)
                            .padding()
                            .background(Color.yellow)
                            .foregroundColor(.white)
                            .cornerRadius(500)
                        }
                    }
                    .padding()
                }
                
                
                
                // 3. Hidden NavigationLink to push TestView
                if let qs = pendingQuestions {
                    NavigationLink(
                        destination: TestView(
                            questions: qs,
                            goToResult: { score, total in
                                // Reset state when TestView says to go to results
                                navigateToTest = false
                                pendingQuestions = nil
                                // Then you can push your results flow here if desired
                            }
                        ),
                        isActive: $navigateToTest
                    ) {
                        EmptyView()
                    }
                }
            }
            
            
            // 4. Interstitial fullScreenCover
            .fullScreenCover(isPresented: $showAd, onDismiss: {
                // Navigate to test after ad is dismissed
                if pendingQuestions != nil {
                    navigateToTest = true
                }
            }) {
                if purchaseManager.hasRemovedAds {
                    // Skip the ad entirely → go straight to test
                    Color.clear.onAppear {
                        // instantly dismiss the ad cover
                        showAd = false
                        navigateToTest = true
                    }
                } else {
                    InterstitialAdView()
                }
            }
            .onAppear {
                LocalizedBundle.setLanguage(langMgr.language)
            }
        }
    }
    
    // MARK: – Helpers
    
    private func loadQuestions(from filename: String) -> [Question] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let qs   = try? JSONDecoder().decode([Question].self, from: data)
        else { return [] }
        return qs
    }
    
    private var randomQuestions: [Question] {
        let all = exams.flatMap { loadQuestions(from: $0.filename) }
        return Array(all.shuffled().prefix(40))
    }
}
