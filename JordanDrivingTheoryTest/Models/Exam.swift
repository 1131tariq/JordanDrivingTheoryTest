//
//  Exam.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//

import Foundation

struct Exam: Identifiable {
    let id: Int
    let titleKey: String   // Localized string key like "exam_1"
    let filename: String   // e.g. "questions1"
}

