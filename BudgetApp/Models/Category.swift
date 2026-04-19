import SwiftUI

enum TransactionCategory: String, Codable, CaseIterable, Identifiable {
    case groceries
    case restaurants
    case transportation
    case housing
    case utilities
    case electronics
    case entertainment
    case shopping
    case healthcare
    case subscriptions
    case travel
    case education
    case gifts
    case personalCare
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .groceries:       return "Groceries"
        case .restaurants:     return "Restaurants"
        case .transportation:  return "Transportation"
        case .housing:         return "Housing"
        case .utilities:       return "Utilities"
        case .electronics:     return "Electronics"
        case .entertainment:   return "Entertainment"
        case .shopping:        return "Shopping"
        case .healthcare:      return "Healthcare"
        case .subscriptions:   return "Subscriptions"
        case .travel:          return "Travel"
        case .education:       return "Education"
        case .gifts:           return "Gifts"
        case .personalCare:    return "Personal Care"
        case .other:           return "Other"
        }
    }

    var sfSymbol: String {
        switch self {
        case .groceries:       return "cart.fill"
        case .restaurants:     return "fork.knife"
        case .transportation:  return "car.fill"
        case .housing:         return "house.fill"
        case .utilities:       return "bolt.fill"
        case .electronics:     return "laptopcomputer"
        case .entertainment:   return "tv.fill"
        case .shopping:        return "bag.fill"
        case .healthcare:      return "cross.case.fill"
        case .subscriptions:   return "repeat"
        case .travel:          return "airplane"
        case .education:       return "graduationcap.fill"
        case .gifts:           return "gift.fill"
        case .personalCare:    return "sparkles"
        case .other:           return "ellipsis.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .groceries:       return AppTheme.Colors.cardMint
        case .restaurants:     return AppTheme.Colors.cardPeach
        case .transportation:  return AppTheme.Colors.cardSky
        case .housing:         return AppTheme.Colors.cardLavender
        case .utilities:       return AppTheme.Colors.cardPeach
        case .electronics:     return AppTheme.Colors.cardSky
        case .entertainment:   return AppTheme.Colors.cardLavender
        case .shopping:        return AppTheme.Colors.cardPeach
        case .healthcare:      return AppTheme.Colors.cardMint
        case .subscriptions:   return AppTheme.Colors.cardLavender
        case .travel:          return AppTheme.Colors.cardSky
        case .education:       return AppTheme.Colors.cardMint
        case .gifts:           return AppTheme.Colors.cardPeach
        case .personalCare:    return AppTheme.Colors.cardLavender
        case .other:           return AppTheme.Colors.surfaceMuted
        }
    }
}
