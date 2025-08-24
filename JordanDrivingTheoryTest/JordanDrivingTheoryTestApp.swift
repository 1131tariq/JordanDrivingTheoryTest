//
//  JordanDrivingTheoryTestApp.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//

import SwiftUI

import GoogleMobileAds

@main
struct JordanDrivingTheoryTestApp: App {
    init() {
        MobileAds.shared.start { status in
            print("✅ Initialized with adapter statuses: \(status.adapterStatusesByClassName)")
        }
        @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }
}
