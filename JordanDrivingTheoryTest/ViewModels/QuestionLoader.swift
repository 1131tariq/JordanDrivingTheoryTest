//
//  QuestionLoader.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//

import Foundation


class QuestionLoader {
    func loadQuestions(from filename: String) -> [Question] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let qs = try? JSONDecoder().decode([Question].self, from: data)
        else { return [] }
        return qs
    }
}
