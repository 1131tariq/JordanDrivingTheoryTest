//
//  PurchaseManager.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 26/08/2025.
//

import Foundation
import SwiftUI
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {
    @Published var hasRemovedAds = false
    @Published var products: [Product] = []

    private let removeAdsID = "BataynehInc.JordanDrivingTheoryTestApp.removeads1"

    init() {
        Task {
            await requestProducts()
            await updatePurchasedProducts()
            listenForTransactions()   // 👈 Start transaction listener
        }
    }

    // Load products from App Store Connect
    func requestProducts() async {
        do {
            products = try await Product.products(for: [removeAdsID])
            print("✅ Products loaded: \(products.map(\.id))")
        } catch {
            print("❌ Failed to fetch products: \(error)")
        }
    }

    // Attempt purchase
    func purchaseRemoveAds() async {
        guard let product = products.first(where: { $0.id == removeAdsID }) else {
            print("❌ Remove Ads product not found")
            return
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                handleVerification(verification)
            case .userCancelled:
                print("⚠️ User cancelled purchase")
            default:
                break
            }
        } catch {
            print("❌ Purchase failed: \(error)")
        }
    }

    // Handle verified/unverified transactions
    private func handleVerification(_ verification: VerificationResult<StoreKit.Transaction>) {
        switch verification {
        case .verified(let transaction):
            print("✅ Purchase successful: \(transaction.productID)")
            if transaction.productID == removeAdsID {
                hasRemovedAds = true
            }
            Task { await transaction.finish() }
        case .unverified(_, let error):
            print("❌ Unverified transaction: \(error.localizedDescription)")
        }
    }

    // Always reset state, then check for entitlements
    func updatePurchasedProducts() async {
        await MainActor.run {
            self.hasRemovedAds = false
        }

        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == removeAdsID {
                await MainActor.run {
                    self.hasRemovedAds = true
                }
            }
        }
    }

    private func listenForTransactions() {
        Task.detached(priority: .background) {
            for await result in StoreKit.Transaction.updates {
                if case .verified(let transaction) = result {
                    await MainActor.run {
                        if transaction.productID == self.removeAdsID {
                            self.hasRemovedAds = true
                        }
                    }
                    await transaction.finish()
                }
            }
        }
    }

    // Manual restore purchases button
    func restorePurchases() async {
        do {
            try await AppStore.sync()   // Forces sync with App Store
            await updatePurchasedProducts()
            print("✅ Purchases restored")
        } catch {
            print("❌ Failed to restore purchases: \(error)")
        }
    }

}

