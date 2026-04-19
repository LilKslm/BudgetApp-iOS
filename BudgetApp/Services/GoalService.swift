import Foundation

protocol GoalServiceProtocol: AnyObject {
    // Savings
    func fetchSavingsGoals(for uid: String) async throws -> [SavingsGoal]
    func createSavingsGoal(_ goal: SavingsGoal) async throws
    func logContribution(goalId: String, uid: String, contribution: GoalContribution) async throws
    func deleteSavingsGoal(id: String, uid: String) async throws

    // Debt
    func fetchDebts(for uid: String) async throws -> [Debt]
    func createDebt(_ debt: Debt) async throws
    func logDebtPayment(debtId: String, uid: String, payment: DebtPayment) async throws
    func deleteDebt(id: String, uid: String) async throws
}

final class MockGoalService: GoalServiceProtocol {
    private var savings: [String: [SavingsGoal]] = [:]
    private var debts: [String: [Debt]] = [:]

    // MARK: - Savings

    func fetchSavingsGoals(for uid: String) async throws -> [SavingsGoal] {
        if let stored = savings[uid] { return stored }
        let seed = Self.seedSavings(uid: uid)
        savings[uid] = seed
        return seed
    }

    func createSavingsGoal(_ goal: SavingsGoal) async throws {
        savings[goal.ownerUid, default: []].append(goal)
    }

    func logContribution(goalId: String, uid: String, contribution: GoalContribution) async throws {
        guard var list = savings[uid], let idx = list.firstIndex(where: { $0.id == goalId }) else {
            throw AppError.documentNotFound
        }
        list[idx].contributions.append(contribution)
        list[idx].currentAmount += contribution.amount
        savings[uid] = list
    }

    func deleteSavingsGoal(id: String, uid: String) async throws {
        savings[uid]?.removeAll { $0.id == id }
    }

    // MARK: - Debt

    func fetchDebts(for uid: String) async throws -> [Debt] {
        if let stored = debts[uid] { return stored }
        let seed = Self.seedDebts(uid: uid)
        debts[uid] = seed
        return seed
    }

    func createDebt(_ debt: Debt) async throws {
        debts[debt.ownerUid, default: []].append(debt)
    }

    func logDebtPayment(debtId: String, uid: String, payment: DebtPayment) async throws {
        guard var list = debts[uid], let idx = list.firstIndex(where: { $0.id == debtId }) else {
            throw AppError.documentNotFound
        }
        list[idx].payments.append(payment)
        list[idx].currentBalance = max(list[idx].currentBalance - payment.amount, 0)
        debts[uid] = list
    }

    func deleteDebt(id: String, uid: String) async throws {
        debts[uid]?.removeAll { $0.id == id }
    }

    // MARK: - Seeds

    private static func seedSavings(uid: String) -> [SavingsGoal] {
        [
            SavingsGoal(
                id: UUID().uuidString,
                ownerUid: uid,
                name: "Emergency Fund",
                targetAmount: 5_000,
                currentAmount: 1_250,
                theme: .emergencyFund,
                targetDate: Calendar.current.date(byAdding: .month, value: 10, to: .now),
                createdAt: .now,
                contributions: [
                    GoalContribution(id: UUID().uuidString, amount: 500, date: .now.addingTimeInterval(-60*60*24*30), note: nil),
                    GoalContribution(id: UUID().uuidString, amount: 500, date: .now.addingTimeInterval(-60*60*24*14), note: nil),
                    GoalContribution(id: UUID().uuidString, amount: 250, date: .now.addingTimeInterval(-60*60*24*3),  note: nil)
                ]
            )
        ]
    }

    private static func seedDebts(uid: String) -> [Debt] {
        [
            Debt(
                id: UUID().uuidString,
                ownerUid: uid,
                name: "Credit Card",
                originalAmount: 3_000,
                currentBalance: 1_800,
                minimumPayment: 75,
                apr: 22.99,
                theme: .chainBreaker,
                createdAt: .now,
                payments: [
                    DebtPayment(id: UUID().uuidString, amount: 600, date: .now.addingTimeInterval(-60*60*24*45), note: nil),
                    DebtPayment(id: UUID().uuidString, amount: 600, date: .now.addingTimeInterval(-60*60*24*15), note: nil)
                ]
            )
        ]
    }
}
