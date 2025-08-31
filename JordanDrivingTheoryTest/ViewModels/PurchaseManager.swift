//
//  PurchaseManager.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 26/08/2025.
//

import Foundation

import StoreKit

enum IAPProducts {
    static let removeAds = "com.yourapp.removeads"
}

@MainActor
class PurchaseManager: ObservableObject {
//    @Published var hasRemovedAds = false
    @Published var hasRemovedAds: Bool = false

    
    init() {
        Task {
            await updatePurchasedProducts()
        }
    }
    
    func purchaseRemoveAds() async {
        do {
            if let product = try await Product.products(for: [IAPProducts.removeAds]).first {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    if case .verified = verification {
                        hasRemovedAds = true
                    }
                default: break
                }
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == IAPProducts.removeAds {
                hasRemovedAds = true
            }
        }
    }
}
