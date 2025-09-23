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
    @StateObject private var purchaseManager = PurchaseManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate   // ✅ here, as a property
    @StateObject private var networkMonitor = NetworkMonitor()
    
    
    
    
    init() {
        MobileAds.shared.start { status in
            print("✅ Initialized with adapter statuses: \(status.adapterStatusesByClassName)")
        }
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
            "a3bb6548935848c963aec29062ee5fc3"
        ]
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(purchaseManager)
                .environmentObject(networkMonitor)
            
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
