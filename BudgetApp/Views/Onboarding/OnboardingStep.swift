import Foundation

enum OnboardingStep: Hashable, CaseIterable {
    case quiz(index: Int)   // 0–9
    case results
    case pain
    case howWeHelp
    case reviews
    case featureTour
    case customPlan
    case notificationPrompt
    case account
    case paywall

    static var allCases: [OnboardingStep] {
        (0..<10).map { .quiz(index: $0) } + [
            .results, .pain, .howWeHelp, .reviews,
            .featureTour, .customPlan, .notificationPrompt,
            .account, .paywall
        ]
    }

    var stepNumber: Int {
        switch self {
        case .quiz(let i):       return i + 1
        case .results:           return 11
        case .pain:              return 12
        case .howWeHelp:         return 13
        case .reviews:           return 14
        case .featureTour:       return 15
        case .customPlan:        return 16
        case .notificationPrompt: return 17
        case .account:           return 18
        case .paywall:           return 19
        }
    }

    static let totalSteps = 19

    /// Whether the user can navigate back from this step.
    var allowsBack: Bool {
        switch self {
        case .quiz: return true
        default:    return false
        }
    }
}
