import Foundation

/// All writes against sharedBudgets / budgetInvites go through this service —
/// ViewModels must never touch those collections directly (per appcreation.md §12.10).
protocol SharingServiceProtocol: AnyObject {
    func createInvite(fromUid: String, budgetName: String) async throws -> BudgetInvite
    func claimInvite(code: String, byUid: String) async throws -> SharedBudget
    func fetchSharedBudgets(for uid: String) async throws -> [SharedBudget]
    func addTransaction(_ txn: Transaction, toSharedBudgetId: String) async throws
}

final class MockSharingService: SharingServiceProtocol {
    private var invites: [String: BudgetInvite] = [:]
    private var sharedBudgets: [String: SharedBudget] = [:]
    private var sharedTxns: [String: [Transaction]] = [:]

    func createInvite(fromUid: String, budgetName: String) async throws -> BudgetInvite {
        let sharedId = UUID().uuidString
        let budget = SharedBudget(
            id: sharedId,
            name: budgetName,
            members: [fromUid],
            periodStart: Calendar.current.dateInterval(of: .month, for: .now)?.start ?? .now,
            allocations: [],
            createdAt: .now,
            createdByUid: fromUid
        )
        sharedBudgets[sharedId] = budget

        let code = Self.generateInviteCode()
        let invite = BudgetInvite(
            id: code,
            fromUid: fromUid,
            sharedBudgetId: sharedId,
            status: .pending,
            createdAt: .now,
            expiresAt: .now.addingTimeInterval(60 * 60 * 24 * 7),
            claimedByUid: nil
        )
        invites[code] = invite
        return invite
    }

    func claimInvite(code: String, byUid: String) async throws -> SharedBudget {
        guard var invite = invites[code] else { throw AppError.inviteNotFound }
        guard invite.status == .pending else { throw AppError.inviteAlreadyClaimed }
        guard invite.expiresAt > .now else { throw AppError.inviteExpired }

        guard var budget = sharedBudgets[invite.sharedBudgetId] else { throw AppError.documentNotFound }
        if !budget.members.contains(byUid) { budget.members.append(byUid) }

        invite.status = .claimed
        invite.claimedByUid = byUid
        invites[code] = invite
        sharedBudgets[budget.id] = budget
        return budget
    }

    func fetchSharedBudgets(for uid: String) async throws -> [SharedBudget] {
        sharedBudgets.values.filter { $0.members.contains(uid) }
    }

    func addTransaction(_ txn: Transaction, toSharedBudgetId: String) async throws {
        guard let budget = sharedBudgets[toSharedBudgetId] else { throw AppError.documentNotFound }
        guard budget.members.contains(txn.createdByUid) else { throw AppError.notAMember }
        sharedTxns[toSharedBudgetId, default: []].insert(txn, at: 0)
    }

    private static func generateInviteCode() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<6).map { _ in chars.randomElement()! })
    }
}
