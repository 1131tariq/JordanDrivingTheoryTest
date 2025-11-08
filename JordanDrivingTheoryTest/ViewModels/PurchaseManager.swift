import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    @Published private(set) var hasRemovedAds = false
    @Published private(set) var products: [Product] = []
    
    private let removeAdsID = "BataynehInc.JordanDrivingTheoryTestApp.removeads1"
    private var updatesTask: Task<Void, Never>? = nil
    
    init() {
        Task {
            await loadProducts()
            await refreshEntitlements()
            startListeningForTransactions()
        }
    }
    
    deinit {
        updatesTask?.cancel()
    }
    
    // MARK: - Load products
    func loadProducts() async {
        do {
            products = try await Product.products(for: [removeAdsID])
            print("✅ Products loaded: \(products.map(\.id))")
        } catch {
            print("❌ Failed to fetch products: \(error.localizedDescription)")
            products = []
        }
    }
    
    // MARK: - Purchase
    func purchaseRemoveAds() async {
        guard let product = products.first(where: { $0.id == removeAdsID }) else {
            print("❌ Remove Ads product not found")
            return
        }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                handleTransaction(verification)
            case .userCancelled:
                print("⚠️ Purchase cancelled by user")
            default:
                print("⚠️ Unknown purchase result")
            }
        } catch {
            print("❌ Purchase failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Transaction Handling
    private func handleTransaction(_ verification: VerificationResult<StoreKit.Transaction>) {
        guard case .verified(let transaction) = verification else {
            if case .unverified(_, let error) = verification {
                print("❌ Unverified transaction: \(error.localizedDescription)")
            }
            return
        }
        
        print("✅ Verified transaction for product: \(transaction.productID)")
        if transaction.productID == removeAdsID {
            hasRemovedAds = true
        }
        
        Task { await transaction.finish() }
    }
    
    // MARK: - Entitlements
    func refreshEntitlements() async {
        var isEntitled = false
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == removeAdsID {
                isEntitled = true
                break
            }
        }
        
        hasRemovedAds = isEntitled
        print(isEntitled ? "✅ User owns Remove Ads" : "ℹ️ No active entitlements")
    }
    
    // MARK: - Live Transaction Updates
    private func startListeningForTransactions() {
        updatesTask = Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                
                if transaction.productID == self.removeAdsID {
                    await MainActor.run {
                        self.hasRemovedAds = true
                    }
                }
                await transaction.finish()
            }
        }
    }
    
    // MARK: - Restore
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            print("✅ Purchases restored successfully")
        } catch {
            print("❌ Restore failed: \(error.localizedDescription)")
        }
    }
}
