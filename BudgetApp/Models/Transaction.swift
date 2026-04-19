import Foundation

struct Transaction: Codable, Identifiable, Equatable {
    var id: String
    var ownerUid: String
    /// nil when this transaction is tracked outside a specific budget (e.g. shared-budget txns use sharedBudgetId instead)
    var budgetId: String?
    var sharedBudgetId: String?
    var amount: Double
    var category: TransactionCategory
    var merchant: String
    var notes: String?
    var date: Date
    var createdAt: Date
    /// UID of whoever logged this — mostly relevant for shared budgets.
    var createdByUid: String
    /// nil for manual entries; Plaid-imported transactions carry a Plaid transaction ID (Phase: Plaid).
    var plaidTxnId: String?
}
