//
//  TestView.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//
import SwiftUI

struct TestView: View {
    // MARK: – Injected
    let questions: [Question]
    let goToResult: (_ score: Int, _ total: Int) -> Void
    @EnvironmentObject var purchaseManager: PurchaseManager

    
    // MARK: – Environment & State
    @Environment(\.dismiss) private var dismiss
    @AppStorage("language") private var language: String = "en"
    @StateObject private var viewModel: TestViewModel
    @State private var isFinished = false
    
    // **New**: show the interstitial
    @State private var showAd = false
    
    // MARK: – Init
    init(
        questions: [Question],
        goToResult: @escaping (_ score: Int, _ total: Int) -> Void
    ) {
        self.questions = questions
        self.goToResult = goToResult
        _viewModel = StateObject(wrappedValue: TestViewModel(questions: questions))
    }
    
    // MARK: – Body
    var body: some View {
        ZStack {
            Image("backdrop2").resizable()
                .scaledToFill()
                .ignoresSafeArea().opacity(0.4)
            VStack(spacing: 20) {
                // Custom “Main Menu” back button
                HStack {
                    Button(action: {
                        // show the ad instead of immediate dismiss
                        showAd = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.left")
                            Text(NSLocalizedString("main_menu", bundle: .localized, comment: ""))
                        }
                    }
                    .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.horizontal)
                
                // == SWITCH: Quiz UI vs. ResultView ==
                if isFinished {
                    ResultView(
                        score: viewModel.score,
                        total: viewModel.questions.count,
                        onRestart: {
                            viewModel.restart()
                            isFinished = false
                        },
                        onExit: {
                            // also show ad on exit if desired, or dismiss directly
                            showAd = true
                        }
                    )
                } else {
                    // … your existing quiz UI …
                    
                    Text("\(viewModel.currentIndex + 1) / \(viewModel.questions.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: viewModel.progress).tint(.yellow)
                    
                    if let imgName = viewModel.currentQuestion.imageName {
                        Image(imgName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    } else if let urlString = viewModel.currentQuestion.imageURL,
                              let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                        } placeholder: {
                            ProgressView()
                        }
                    }

                    
                    Text(viewModel.currentQuestion.text(for: language))
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    
                    ForEach(viewModel.currentQuestion.options(for: language).indices, id: \.self) { idx in
                        Button {
                            if viewModel.selectedAnswer == nil {
                                viewModel.selectAnswer(idx)
                            }
                        } label: {
                            Text(viewModel.currentQuestion.options(for: language)[idx])
                                .padding()
                                .frame(maxWidth: 260)
                                .background(buttonColor(for: idx))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    
                    if viewModel.showFeedback {
                        Text(viewModel.selectedAnswer == viewModel.currentQuestion.correctIndex
                             ? NSLocalizedString("correct", bundle: .localized, comment: "")
                             : NSLocalizedString("wrong", bundle: .localized, comment: ""))
                        Button(NSLocalizedString("next", bundle: .localized, comment: "")) {
                            if viewModel.currentIndex == viewModel.questions.count - 1 {
                                withAnimation { isFinished = true }
                            } else {
                                viewModel.nextQuestion()
                            }
                        }
                    }
                    
                    Text("\(NSLocalizedString("score", bundle: .localized, comment: "")): \(viewModel.score)")
                }
                
                Spacer()
                
                if !purchaseManager.hasRemovedAds {
                    BannerAdView(adUnitID: Secrets.bannerUnitID)
                        .frame(height: 50) // Height adjusts automatically based on device width
                }
            
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .onAppear {
                LocalizedBundle.setLanguage(language)
            }
            // MARK: – Full‑screen interstitial placeholder
            .fullScreenCover(isPresented: $showAd, onDismiss: {
                // After the interstitial is dismissed, go back to the main menu
                dismiss()
            }) {
                if purchaseManager.hasRemovedAds {
                        // Skip the ad → instantly dismiss and go back
                        Color.clear.onAppear {
                            showAd = false
                            dismiss()
                        }
                    } else {
                        InterstitialAdView()
                    }
            }.padding(80)
        }
    }
    
    // MARK: – Helpers
    private func buttonColor(for index: Int) -> Color {
        guard viewModel.showFeedback else {
            return .orange
        }
        if index == viewModel.currentQuestion.correctIndex {
            return .green
        }
        if let selected = viewModel.selectedAnswer, index == selected {
            return .red
        }
        return .gray
    }
}
