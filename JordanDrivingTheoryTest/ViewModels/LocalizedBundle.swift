//
//  LocalizedBundle.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//

import Foundation
import SwiftUI

private var bundleKey: UInt8 = 0

class LocalizedBundle {
    static func setLanguage(_ language: String) {
        let isLanguageRTL = Locale.characterDirection(forLanguage: language) == .rightToLeft
        UIView.appearance().semanticContentAttribute = isLanguageRTL ? .forceRightToLeft : .forceLeftToRight
        
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return
        }
        
        objc_setAssociatedObject(Bundle.main, &bundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension Bundle {
    static var localized: Bundle {
        if let bundle = objc_getAssociatedObject(Bundle.main, &bundleKey) as? Bundle {
            return bundle
        } else {
            return Bundle.main
        }
    }
}



extension Text {
    init(localizedKey: String) {
        self.init(LocalizedStringKey(localizedKey), bundle: .localized)
    }
}
