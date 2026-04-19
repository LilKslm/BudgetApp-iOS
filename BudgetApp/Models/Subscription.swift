import Foundation

enum SubscriptionCadence: String, Codable, CaseIterable {
    case weekly, monthly, quarterly, yearly

    var displayName: String {
        switch self {
        case .weekly:    return "Weekly"
        case .monthly:   return "Monthly"
        case .quarterly: return "Quarterly"
        case .yearly:    return "Yearly"
        }
    }

    /// Normalized monthly cost for aggregate displays.
    func monthlyEquivalent(of amount: Double) -> Double {
        switch self {
        case .weekly:    return amount * 52.0 / 12.0
        case .monthly:   return amount
        case .quarterly: return amount / 3.0
        case .yearly:    return amount / 12.0
        }
    }
}

struct Subscription: Codable, Identifiable, Equatable {
    var id: String
    var ownerUid: String
    var name: String
    var amount: Double
    var cadence: SubscriptionCadence
    var category: TransactionCategory
    var nextRenewalDate: Date
    var createdAt: Date
    /// Set when auto-detected from Plaid (Phase: Plaid). nil means manually entered.
    var plaidRecurringId: String?
}
