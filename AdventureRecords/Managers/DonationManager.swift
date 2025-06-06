import Foundation
import StoreKit
import SwiftUI

enum PurchaseState {
    case idle
    case purchasing
    case purchased
    case failed(Error)
    case restored
}

class DonationManager: NSObject, ObservableObject {
    static let shared = DonationManager()

    @Published var products: [SKProduct] = []
    @Published var purchaseState: PurchaseState = .idle

    private let productIdentifiers: [Int: String] = [
        6: "com.example.AdventureRecords.tip.coffee",
        15: "com.example.AdventureRecords.tip.lunch",
        30: "com.example.AdventureRecords.tip.dinner",
        66: "com.example.AdventureRecords.tip.gift"
    ]

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    func fetchProducts() {
        let identifiers = Set(productIdentifiers.values)
        let request = SKProductsRequest(productIdentifiers: identifiers)
        request.delegate = self
        request.start()
    }

    private func product(for amount: Int) -> SKProduct? {
        guard let id = productIdentifiers[amount] else { return nil }
        return products.first { $0.productIdentifier == id }
    }

    func purchase(amount: Int) {
        guard let product = product(for: amount) else { return }
        guard SKPaymentQueue.canMakePayments() else {
            purchaseState = .failed(NSError(domain: "Donation", code: 0, userInfo: [NSLocalizedDescriptionKey: "无法进行支付"]))
            return
        }
        purchaseState = .purchasing
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension DonationManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
        }
    }
}

extension DonationManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                purchaseState = .purchased
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                purchaseState = .failed(transaction.error ?? NSError(domain: "Donation", code: 0, userInfo: nil))
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                purchaseState = .restored
                SKPaymentQueue.default().finishTransaction(transaction)
            case .purchasing, .deferred:
                break
            @unknown default:
                break
            }
        }
    }
}
