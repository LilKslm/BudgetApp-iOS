import Foundation

struct Budget: Codable, Identifiable, Equatable {
    var id: String
    var ownerUid: String
    var name: String
    /// First day of the month this budget applies to.
    var periodStart: Date
    var allocations: [CategoryAllocation]
    var createdAt: Date

    var totalBudgeted: Double {
        allocations.reduce(0) { $0 + $1.amount }
    }
}

struct CategoryAllocation: Codable, Identifiable, Equatable {
    var id: String { category.rawValue }
    var category: TransactionCategory
    var amount: Double
}
