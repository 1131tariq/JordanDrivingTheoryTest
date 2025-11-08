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
    let freeExamIDs: Set<Int> = [1, 2,3,4,5,6,7,8,9,10,11,12,13,14,15]
    
    // 1. Ad + navigation state
    @State private var showAd = false
    @State private var pendingQuestions: [Question]? = nil
    @State private var navigateToTest = false
    
    // 2. Your exams
    let exams: [Exam] = (1...15).map {
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
                    HStack {
                        Picker("Language", selection: $langMgr.language) {
                            Text("English").tag("en")
                            Text("العربية").tag("ar")
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 220) // keeps picker smaller
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "cart.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding(.leading, 8)
                        }
                    }
                    Spacer()
                    
                    Text(localizedKey: "main_action_title")
                        .font(.largeTitle)
                        .padding(.bottom, 10)
                    
                    ScrollView {
                        let columns = [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ]
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(exams) { exam in
                                let isLocked = !freeExamIDs.contains(exam.id) && !purchaseManager.hasRemovedAds
                                
                                Button {
                                    if isLocked {
                                        Task { await purchaseManager.purchaseRemoveAds() }
                                    } else {
                                        pendingQuestions = loadQuestions(from: exam.filename)
                                        showAd = true
                                    }
                                } label: {
                                    VStack {
                                        if isLocked {
                                            Text("\(NSLocalizedString("Exam", comment: "")) \(exam.id)\nComming Soon")
                                                .font(.title3)
                                                .bold()
                                        } else {
                                            Text("\(NSLocalizedString("Exam", comment: "")) \(exam.id)")
                                                .font(.title3)
                                                .bold()
                                            
                                        }
                                        if isLocked {
                                            Image(systemName: "lock.fill")
                                                .font(.headline)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 120) // makes them square-like
                                    .background(isLocked ? Color.gray : Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .opacity(0.9)
                                }
                                .disabled(isLocked)
                            }
                        }
                        .padding(.horizontal, 20)
                    }.mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .black, location: 0),
                                .init(color: .black, location: 0.9),
                                .init(color: .clear, location: 1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    
                    Spacer(minLength: 10)
                    if !purchaseManager.hasRemovedAds {
                        BannerAdView(adUnitID: Secrets.bannerUnitID)
                            .frame(height: 50) // Height adjusts automatically based on device width
                    }
                    
                }
                .padding(.horizontal, 80)   // ✅ only horizontal padding
                
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
        }        .navigationBarBackButtonHidden(true)
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
