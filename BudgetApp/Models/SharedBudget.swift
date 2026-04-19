import Foundation

struct SharedBudget: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    /// UIDs of the two (for MVP) members who can read + write this budget.
    var members: [String]
    var periodStart: Date
    var allocations: [CategoryAllocation]
    var createdAt: Date
    var createdByUid: String
}

struct BudgetInvite: Codable, Identifiable, Equatable {
    /// Invite code doubles as the document ID.
    var id: String
    var fromUid: String
    var sharedBudgetId: String
    var status: InviteStatus
    var createdAt: Date
    var expiresAt: Date
    var claimedByUid: String?
}

enum InviteStatus: String, Codable {
    case pending
    case claimed
    case expired
    case revoked
}
