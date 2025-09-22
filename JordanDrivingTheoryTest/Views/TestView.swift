////
////  TestView.swift
////  JordanDrivingTheoryTest
////
////  Created by Tareq Batayneh on 23/08/2025.
////


import SwiftUI

struct TestView: View {
    let questions: [Question]
    let goToResult: (_ score: Int, _ total: Int) -> Void
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var bounce: CGFloat = 0
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("language") private var language: String = "en"
    @StateObject private var viewModel: TestViewModel
    @State private var isFinished = false
    @State private var showAd = false
    @State private var selectedImage: Image? = nil
    
    init(
        questions: [Question],
        goToResult: @escaping (_ score: Int, _ total: Int) -> Void
    ) {
        self.questions = questions
        self.goToResult = goToResult
        _viewModel = StateObject(wrappedValue: TestViewModel(questions: questions))
    }
    
    var body: some View {
        ZStack {
            Image("backdrop2").resizable()
                .scaledToFill()
                .ignoresSafeArea().opacity(0.3)
            
            VStack(spacing: 20) {
                // Custom back button
                HStack {
                    Button { showAd = true } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.left")
                            Text(NSLocalizedString("main_menu", bundle: .localized, comment: ""))
                        }
                    }
                    .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.horizontal)
                
                if isFinished {
                    ResultView(
                        score: viewModel.score,
                        total: viewModel.questions.count,
                        onRestart: {
                            viewModel.restart()
                            isFinished = false
                        },
                        onExit: { showAd = true }
                    )
                } else {
                    // ✅ Scrollable question + answers
                    ScrollView {
                        VStack(spacing: 16) {
                            Text("\(viewModel.currentIndex + 1) / \(viewModel.questions.count)")
                                .font(.title).bold()
                            
                            ProgressView(value: viewModel.progress)
                                .tint(.yellow)
                                .padding(.horizontal)
                            
                            // Image handling
                            if let imgName = viewModel.currentQuestion.imgName {
                                Image(imgName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 200, maxHeight: 200)
                                    .padding()
                                    .onTapGesture { selectedImage = Image(imgName) }
                            } else if let urlString = viewModel.currentQuestion.imageURL,
                                      let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: 200, maxHeight: 300)
                                        .padding()
                                        .onTapGesture { selectedImage = image }
                                } placeholder: { ProgressView() }
                            }
                            
                            // Question text
                            Text(viewModel.currentQuestion.text(for: language))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .font(.title)
                            
                            // Answer buttons
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
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .mask(
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
                    
                    // ✅ Feedback + Next button + Score pinned below scroll
                    VStack(spacing: 12) {
                        if viewModel.showFeedback {
                            Text(viewModel.selectedAnswer == viewModel.currentQuestion.correctIndex
                                 ? NSLocalizedString("correct", bundle: .localized, comment: "")
                                 : NSLocalizedString("wrong", bundle: .localized, comment: ""))
                            
                            Button {
                                if viewModel.currentIndex == viewModel.questions.count - 1 {
                                    withAnimation { isFinished = true }
                                } else {
                                    viewModel.nextQuestion()
                                }
                            } label: {
                                Text(NSLocalizedString("next", bundle: .localized, comment: ""))
                                    .padding()
                                    .frame(maxWidth: 260)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        
                        Text("\(NSLocalizedString("score", bundle: .localized, comment: "")): \(viewModel.score)")
                            .bold()
                            .font(.title)
                    }
                }
                
                // Banner Ad
                if !purchaseManager.hasRemovedAds {
                    BannerAdView(adUnitID: Secrets.bannerUnitID)
                        .frame(height: 50)
                }
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .onAppear {
                LocalizedBundle.setLanguage(language)
            }
            .fullScreenCover(isPresented: $showAd, onDismiss: { dismiss() }) {
                if purchaseManager.hasRemovedAds {
                    Color.clear.onAppear {
                        showAd = false
                        dismiss()
                    }
                } else {
                    InterstitialAdView()
                }
            }
            .padding(.horizontal, 85)// ✅ only horizontal padding
            .padding(.vertical, 35)
            
            // ✅ Fullscreen image popup
            if let img = selectedImage {
                ZStack {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                        .onTapGesture { selectedImage = nil } // dismiss anywhere
                    
                    img.resizable()
                        .scaledToFit()
                        .frame(maxWidth: 400, maxHeight: 400)
                }
            }

        }
    }
    
    private func buttonColor(for index: Int) -> Color {
        guard viewModel.showFeedback else { return .orange }
        if index == viewModel.currentQuestion.correctIndex { return .green }
        if let selected = viewModel.selectedAnswer, index == selected { return .red }
        return .gray
    }
}
