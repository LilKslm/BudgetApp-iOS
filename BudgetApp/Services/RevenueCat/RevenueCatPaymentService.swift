import Foundation
import Combine
import RevenueCat

final class RevenueCatPaymentService: PaymentServiceProtocol, PurchasesDelegate {
    private let premiumSubject = CurrentValueSubject<Bool, Never>(false)
    private let entitlementId = "premium"

    var isPremium: Bool { premiumSubject.value }
    var isPremiumPublisher: AnyPublisher<Bool, Never> { premiumSubject.eraseToAnyPublisher() }

    func configure() {
        Purchases.logLevel = .warn
        Purchases.configure(withAPIKey: SecretsLoader.revenueCatAPIKey)
        Purchases.shared.delegate = self

        // Seed current entitlement status from any cached CustomerInfo.
        Task {
            if let info = try? await Purchases.shared.customerInfo() {
                premiumSubject.send(info.entitlements[entitlementId]?.isActive == true)
            }
        }
    }

    // MARK: - PurchasesDelegate

    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        premiumSubject.send(customerInfo.entitlements[entitlementId]?.isActive == true)
    }

    // MARK: - Offerings

    func fetchOfferings(variant: PaywallVariant) async throws -> [PaywallPackage] {
        do {
            let offerings = try await Purchases.shared.getOfferings()
            let packages = offerings.current?.availablePackages ?? []
            return packages.compactMap { mapPackage($0) }
        } catch {
            throw AppError.wrap(error)
        }
    }

    func purchase(packageId: String) async throws {
        do {
            let offerings = try await Purchases.shared.getOfferings()
            guard let pkg = offerings.current?.availablePackages.first(where: { $0.identifier == packageId })
            else { throw AppError.productNotFound }

            let result = try await Purchases.shared.purchase(package: pkg)
            if !result.userCancelled {
                premiumSubject.send(result.customerInfo.entitlements[entitlementId]?.isActive == true)
            }
        } catch let appError as AppError {
            throw appError
        } catch {
            throw AppError.purchaseFailed(error.localizedDescription)
        }
    }

    func restorePurchases() async throws {
        do {
            let info = try await Purchases.shared.restorePurchases()
            premiumSubject.send(info.entitlements[entitlementId]?.isActive == true)
        } catch {
            throw AppError.restoreFailed
        }
    }

    // MARK: - Package mapping

    private func mapPackage(_ pkg: Package) -> PaywallPackage {
        let product = pkg.storeProduct
        let isYearly = pkg.packageType == .annual

        return PaywallPackage(
            id: pkg.identifier,
            productId: product.productIdentifier,
            title: isYearly ? "Yearly" : "Monthly",
            priceDisplay: product.localizedPriceString + (isYearly ? " / year" : " / month"),
            cadence: isYearly ? "after 7-day free trial" : "billed monthly",
            trialDisplay: isYearly ? "Free for 7 days" : nil,
            isBestValue: isYearly
        )
    }
}
