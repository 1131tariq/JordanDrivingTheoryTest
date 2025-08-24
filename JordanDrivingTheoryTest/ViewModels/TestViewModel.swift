//
//  TestViewModel.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//


import Foundation

class TestViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var selectedAnswer: Int? = nil
    @Published var showFeedback: Bool = false
    
    init(questions: [Question]) {
        self.questions = questions
    }
    
    func restart() {
        score = 0
        currentIndex = 0
        selectedAnswer = nil
        showFeedback = false
    }
    
    
    var currentQuestion: Question {
        questions[currentIndex]
    }
    
    func selectAnswer(_ index: Int) {
        selectedAnswer = index
        if index == currentQuestion.correctIndex {
            score += 1
        }
        showFeedback = true
    }
    
    func nextQuestion() {
        selectedAnswer = nil
        showFeedback = false
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            // End of test - could navigate to ResultView or reset
        }
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        let completed = showFeedback ? currentIndex + 1 : currentIndex
        return Double(completed) / Double(questions.count)
    }
    
}
