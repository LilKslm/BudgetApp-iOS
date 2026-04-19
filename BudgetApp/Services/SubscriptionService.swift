import Foundation

protocol SubscriptionServiceProtocol: AnyObject {
    func fetchSubscriptions(for uid: String) async throws -> [Subscription]
    func addSubscription(_ sub: Subscription) async throws
    func updateSubscription(_ sub: Subscription) async throws
    func deleteSubscription(id: String, uid: String) async throws

    /// Total normalized monthly spend across subscriptions.
    func totalMonthlySpend(_ subs: [Subscription]) -> Double
}

final class MockSubscriptionService: SubscriptionServiceProtocol {
    private var byUser: [String: [Subscription]] = [:]

    func fetchSubscriptions(for uid: String) async throws -> [Subscription] {
        if let stored = byUser[uid] { return stored }
        let seed = Self.seedSubscriptions(uid: uid)
        byUser[uid] = seed
        return seed
    }

    func addSubscription(_ sub: Subscription) async throws {
        byUser[sub.ownerUid, default: []].append(sub)
    }

    func updateSubscription(_ sub: Subscription) async throws {
        guard var list = byUser[sub.ownerUid],
              let idx = list.firstIndex(where: { $0.id == sub.id }) else {
            throw AppError.documentNotFound
        }
        list[idx] = sub
        byUser[sub.ownerUid] = list
    }

    func deleteSubscription(id: String, uid: String) async throws {
        byUser[uid]?.removeAll { $0.id == id }
    }

    func totalMonthlySpend(_ subs: [Subscription]) -> Double {
        subs.reduce(0) { $0 + $1.cadence.monthlyEquivalent(of: $1.amount) }
    }

    private static func seedSubscriptions(uid: String) -> [Subscription] {
        let cal = Calendar.current
        func future(_ days: Int) -> Date { cal.date(byAdding: .day, value: days, to: .now) ?? .now }
        return [
            Subscription(id: UUID().uuidString, ownerUid: uid, name: "Netflix",   amount: 15.49, cadence: .monthly, category: .subscriptions, nextRenewalDate: future(4),  createdAt: .now, plaidRecurringId: nil),
            Subscription(id: UUID().uuidString, ownerUid: uid, name: "Spotify",   amount: 10.99, cadence: .monthly, category: .subscriptions, nextRenewalDate: future(12), createdAt: .now, plaidRecurringId: nil),
            Subscription(id: UUID().uuidString, ownerUid: uid, name: "iCloud+",   amount:  2.99, cadence: .monthly, category: .subscriptions, nextRenewalDate: future(20), createdAt: .now, plaidRecurringId: nil)
        ]
    }
}
