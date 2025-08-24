//
//  ResultView.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//


import SwiftUI

struct ResultView: View {
    let score: Int
    let total: Int
    let onRestart: () -> Void
    let onExit: () -> Void
    @State private var showAd = false
    
    
    var body: some View {
        VStack(spacing: 30) {
            Text(localizedKey: "test_complete")
                .font(.largeTitle)
                .bold()
            
            Text(localizedKey: "your_score_was")
                .font(.title2)
            
            Text("\(score) / \(total)")
                .font(.system(size: 40, weight: .bold))
            
            Text(scorePercentageText())
                .foregroundColor(score >= passingScore ? .green : .red)
            
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        
    }
    
    private var passingScore: Int {
        Int(Double(total) * 0.8) // 80% pass mark
    }
    
    private func scorePercentageText() -> String {
        let percent = Int((Double(score) / Double(total)) * 100)
        // Use a simple string if localization fails
        let format = NSLocalizedString("you_scored_percent", bundle: .localized, comment: "")
        if format.contains("%d") {
            return String(format: format, percent)
        } else {
            return "You scored \(percent)%"
        }
    }

}
