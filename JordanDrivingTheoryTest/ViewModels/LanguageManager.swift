//
//  LanguageManager.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//

import Foundation
import SwiftUI

/// Manages the in‑app language and forces SwiftUI updates when it changes.
class LanguageManager: ObservableObject {
    @AppStorage("language") var language: String = "en" {
        didSet {
            // Update the bundle so NSLocalizedString(…, bundle: .localized) uses the right lproj
            LocalizedBundle.setLanguage(language)
            objectWillChange.send()
        }
    }
    
    init() {
        // Ensure bundle is set on launch
        LocalizedBundle.setLanguage(language)
    }
}
