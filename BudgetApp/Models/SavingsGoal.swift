import Foundation

enum SavingsGoalTheme: String, Codable, CaseIterable, Identifiable {
    case car
    case house
    case vacation
    case emergencyFund
    case wedding
    case electronics

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .car:           return "Car"
        case .house:         return "House"
        case .vacation:      return "Vacation"
        case .emergencyFund: return "Emergency Fund"
        case .wedding:       return "Wedding"
        case .electronics:   return "Electronics"
        }
    }

    /// Fallback SF Symbol used in list cells before the custom GoalVisualizationView is in view.
    var sfSymbol: String {
        switch self {
        case .car:           return "car.fill"
        case .house:         return "house.fill"
        case .vacation:      return "beach.umbrella.fill"
        case .emergencyFund: return "shield.fill"
        case .wedding:       return "heart.fill"
        case .electronics:   return "laptopcomputer"
        }
    }
}

struct SavingsGoal: Codable, Identifiable, Equatable {
    var id: String
    var ownerUid: String
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var theme: SavingsGoalTheme
    var targetDate: Date?
    var createdAt: Date
    var contributions: [GoalContribution]

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(max(currentAmount / targetAmount, 0), 1)
    }
}

struct GoalContribution: Codable, Identifiable, Equatable {
    var id: String
    var amount: Double
    var date: Date
    var note: String?
}
