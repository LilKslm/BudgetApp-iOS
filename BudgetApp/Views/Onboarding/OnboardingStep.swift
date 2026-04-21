import Foundation

enum OnboardingStep: Hashable, CaseIterable {
    case quiz(index: Int)   // 0–14
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
        (0..<15).map { .quiz(index: $0) } + [
            .results, .pain, .howWeHelp, .reviews,
            .featureTour, .customPlan, .notificationPrompt,
            .account, .paywall
        ]
    }

    var stepNumber: Int {
        switch self {
        case .quiz(let i):        return i + 1
        case .results:            return 16
        case .pain:               return 17
        case .howWeHelp:          return 18
        case .reviews:            return 19
        case .featureTour:        return 20
        case .customPlan:         return 21
        case .notificationPrompt: return 22
        case .account:            return 23
        case .paywall:            return 24
        }
    }

    static let totalSteps = 24

    var allowsBack: Bool {
        switch self {
        case .quiz: return true
        default:    return false
        }
    }
}
