import Foundation

enum DebtTheme: String, Codable, CaseIterable, Identifiable {
    case chainBreaker
    case mountainDescent

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chainBreaker:    return "Chain Breaker"
        case .mountainDescent: return "Mountain Descent"
        }
    }

    var sfSymbol: String {
        switch self {
        case .chainBreaker:    return "link"
        case .mountainDescent: return "mountain.2.fill"
        }
    }
}

struct Debt: Codable, Identifiable, Equatable {
    var id: String
    var ownerUid: String
    var name: String
    var originalAmount: Double
    var currentBalance: Double
    var minimumPayment: Double
    var apr: Double
    var theme: DebtTheme
    var createdAt: Date
    var payments: [DebtPayment]

    /// 0..1 — share of the debt already paid down.
    var progress: Double {
        guard originalAmount > 0 else { return 0 }
        let paid = max(originalAmount - currentBalance, 0)
        return min(paid / originalAmount, 1)
    }
}

struct DebtPayment: Codable, Identifiable, Equatable {
    var id: String
    var amount: Double
    var date: Date
    var note: String?
}
