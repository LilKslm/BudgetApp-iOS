import Foundation

protocol TransactionServiceProtocol: AnyObject, Sendable {
    func fetchTransactions(for uid: String) async throws -> [Transaction]
    func addTransaction(_ txn: Transaction) async throws
    func updateTransaction(_ txn: Transaction) async throws
    func deleteTransaction(id: String, uid: String) async throws

    /// Aggregate spend by category across the given transactions.
    func spendByCategory(_ txns: [Transaction]) -> [TransactionCategory: Double]
}

final class MockTransactionService: TransactionServiceProtocol, @unchecked Sendable {
    private var byUser: [String: [Transaction]] = [:]

    func fetchTransactions(for uid: String) async throws -> [Transaction] {
        if let stored = byUser[uid] { return stored }
        let seed = Self.seedTransactions(uid: uid)
        byUser[uid] = seed
        return seed
    }

    func addTransaction(_ txn: Transaction) async throws {
        byUser[txn.ownerUid, default: []].insert(txn, at: 0)
    }

    func updateTransaction(_ txn: Transaction) async throws {
        guard var list = byUser[txn.ownerUid],
              let idx = list.firstIndex(where: { $0.id == txn.id }) else {
            throw AppError.documentNotFound
        }
        list[idx] = txn
        byUser[txn.ownerUid] = list
    }

    func deleteTransaction(id: String, uid: String) async throws {
        byUser[uid]?.removeAll { $0.id == id }
    }

    func spendByCategory(_ txns: [Transaction]) -> [TransactionCategory: Double] {
        Dictionary(grouping: txns, by: \.category).mapValues { list in
            list.reduce(0) { $0 + $1.amount }
        }
    }

    private static func seedTransactions(uid: String) -> [Transaction] {
        let now = Date.now
        let cal = Calendar.current
        func daysAgo(_ d: Int) -> Date { cal.date(byAdding: .day, value: -d, to: now) ?? now }
        return [
            Transaction(id: UUID().uuidString, ownerUid: uid, budgetId: nil, sharedBudgetId: nil, amount: 42.50, category: .groceries,     merchant: "Whole Foods",    notes: nil, date: daysAgo(0), createdAt: now, createdByUid: uid, plaidTxnId: nil),
            Transaction(id: UUID().uuidString, ownerUid: uid, budgetId: nil, sharedBudgetId: nil, amount: 18.75, category: .restaurants,   merchant: "Blue Bottle",    notes: nil, date: daysAgo(1), createdAt: now, createdByUid: uid, plaidTxnId: nil),
            Transaction(id: UUID().uuidString, ownerUid: uid, budgetId: nil, sharedBudgetId: nil, amount: 329.00, category: .electronics,  merchant: "Apple Store",    notes: "New keyboard", date: daysAgo(3), createdAt: now, createdByUid: uid, plaidTxnId: nil),
            Transaction(id: UUID().uuidString, ownerUid: uid, budgetId: nil, sharedBudgetId: nil, amount: 55.00, category: .transportation, merchant: "Shell",          notes: nil, date: daysAgo(5), createdAt: now, createdByUid: uid, plaidTxnId: nil),
            Transaction(id: UUID().uuidString, ownerUid: uid, budgetId: nil, sharedBudgetId: nil, amount: 14.99, category: .subscriptions, merchant: "Netflix",        notes: nil, date: daysAgo(6), createdAt: now, createdByUid: uid, plaidTxnId: nil)
        ]
    }
}
