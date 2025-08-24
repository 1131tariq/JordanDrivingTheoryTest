//
//  Questions.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//

import Foundation

struct Question: Identifiable, Codable {
    let id = UUID()
    let text_en: String
    let text_ar: String
    let options_en: [String]
    let options_ar: [String]
    let correctIndex: Int
    let imageName: String?
    let imageURL: String?// e.g. "sign_stop" or nil
    
    
    func text(for language: String) -> String {
        language == "ar" ? text_ar : text_en
    }
    
    func options(for language: String) -> [String] {
        language == "ar" ? options_ar : options_en
    }
}
