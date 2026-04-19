import Foundation

protocol BudgetServiceProtocol: AnyObject {
    func fetchBudgets(for uid: String) async throws -> [Budget]
    func createBudget(_ budget: Budget) async throws
    func updateBudget(_ budget: Budget) async throws
    func deleteBudget(id: String, uid: String) async throws
}

final class MockBudgetService: BudgetServiceProtocol {
    private var budgets: [String: [Budget]] = [:]

    func fetchBudgets(for uid: String) async throws -> [Budget] {
        if let stored = budgets[uid] { return stored }
        let seed = Self.seedBudgets(uid: uid)
        budgets[uid] = seed
        return seed
    }

    func createBudget(_ budget: Budget) async throws {
        budgets[budget.ownerUid, default: []].append(budget)
    }

    func updateBudget(_ budget: Budget) async throws {
        guard var list = budgets[budget.ownerUid],
              let idx = list.firstIndex(where: { $0.id == budget.id }) else {
            throw AppError.documentNotFound
        }
        list[idx] = budget
        budgets[budget.ownerUid] = list
    }

    func deleteBudget(id: String, uid: String) async throws {
        budgets[uid]?.removeAll { $0.id == id }
    }

    private static func seedBudgets(uid: String) -> [Budget] {
        let startOfMonth = Calendar.current.dateInterval(of: .month, for: .now)?.start ?? .now
        let allocations: [CategoryAllocation] = [
            .init(category: .groceries, amount: 500),
            .init(category: .restaurants, amount: 200),
            .init(category: .transportation, amount: 150),
            .init(category: .utilities, amount: 180),
            .init(category: .entertainment, amount: 100)
        ]
        return [
            Budget(
                id: UUID().uuidString,
                ownerUid: uid,
                name: "Monthly Budget",
                periodStart: startOfMonth,
                allocations: allocations,
                createdAt: .now
            )
        ]
    }
}
