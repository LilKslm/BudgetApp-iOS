import Foundation
import Combine

/// Offering / package / customer-info shapes are simplified at Phase 1; Phase 3 swaps in RevenueCat's real types.
struct PaywallPackage: Identifiable, Equatable {
    let id: String
    let productId: String
    let title: String
    let priceDisplay: String
    let cadence: String
    let trialDisplay: String?
    let isBestValue: Bool
}

protocol PaymentServiceProtocol: AnyObject {
    var isPremium: Bool { get }
    var isPremiumPublisher: AnyPublisher<Bool, Never> { get }

    func configure()
    func fetchOfferings() async throws -> [PaywallPackage]
    func purchase(packageId: String) async throws
    func restorePurchases() async throws
}

final class MockPaymentService: PaymentServiceProtocol {
    private let premiumSubject = CurrentValueSubject<Bool, Never>(false)
    var isPremium: Bool { premiumSubject.value }
    var isPremiumPublisher: AnyPublisher<Bool, Never> { premiumSubject.eraseToAnyPublisher() }

    var shouldFailPurchase = false

    func configure() {
        AppLogger.info("MockPaymentService configured")
    }

    func fetchOfferings() async throws -> [PaywallPackage] {
        [
            PaywallPackage(
                id: "yearly",
                productId: "budgetapp.pro.yearly",
                title: "Yearly",
                priceDisplay: "$49.99 / year",
                cadence: "after 7-day free trial",
                trialDisplay: "Free for 7 days",
                isBestValue: true
            ),
            PaywallPackage(
                id: "monthly",
                productId: "budgetapp.pro.monthly",
                title: "Monthly",
                priceDisplay: "$7.99 / month",
                cadence: "billed monthly",
                trialDisplay: nil,
                isBestValue: false
            )
        ]
    }

    func purchase(packageId: String) async throws {
        if shouldFailPurchase { throw AppError.purchaseFailed("Mock failure") }
        try await Task.sleep(nanoseconds: 500_000_000)
        premiumSubject.send(true)
    }

    func restorePurchases() async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        premiumSubject.send(true)
    }

    // MARK: - Debug helpers (removed once RevenueCat is live — tracked in apple-developer-tasks.md item 2)
    func _debugSetPremium(_ value: Bool) {
        premiumSubject.send(value)
    }
}
