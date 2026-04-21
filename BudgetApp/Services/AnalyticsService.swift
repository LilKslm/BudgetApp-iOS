import Foundation

enum AnalyticsEvent {
    // Auth
    case login(method: String)
    case signUp(method: String)
    case logout

    // Onboarding
    case onboardingStarted
    case onboardingStepCompleted(step: Int)
    case onboardingQuizAnswered(questionIndex: Int, answer: String)
    case onboardingCompleted

    // Paywall
    case paywallShown(trigger: String, variant: String)
    case paywallDismissed
    case paywallPurchaseTapped(productId: String)
    case paywallPurchaseCompleted(productId: String)
    case paywallRestored

    // Feature
    case budgetCreated
    case transactionAdded(category: String)
    case subscriptionAdded
    case savingsGoalCreated(theme: String)
    case savingsContributionLogged(goalId: String, amount: Double)
    case debtCreated(theme: String)
    case debtPaymentLogged(debtId: String, amount: Double)
    case sharedBudgetInviteSent
    case sharedBudgetInviteAccepted

    // Onboarding extras
    case onboardingNotificationDecision(granted: Bool)
    case onboardingAccountCreated(method: String)
    case onboardingQuizAbandoned(atStep: Int)

    // Paywall extras
    case paywallDiscountShown

    // Navigation
    case screenViewed(name: String)
    case featureUsed(name: String)

    var name: String {
        switch self {
        case .login:                          return "login"
        case .signUp:                         return "sign_up"
        case .logout:                         return "logout"
        case .onboardingStarted:              return "onboarding_started"
        case .onboardingStepCompleted:        return "onboarding_step_completed"
        case .onboardingQuizAnswered:         return "onboarding_quiz_answered"
        case .onboardingCompleted:            return "onboarding_completed"
        case .paywallShown:                   return "paywall_shown"
        case .paywallDismissed:               return "paywall_dismissed"
        case .paywallPurchaseTapped:          return "paywall_purchase_tapped"
        case .paywallPurchaseCompleted:       return "paywall_purchase_completed"
        case .paywallRestored:                return "paywall_restored"
        case .budgetCreated:                  return "budget_created"
        case .transactionAdded:               return "transaction_added"
        case .subscriptionAdded:              return "subscription_added"
        case .savingsGoalCreated:             return "savings_goal_created"
        case .savingsContributionLogged:      return "savings_contribution_logged"
        case .debtCreated:                    return "debt_created"
        case .debtPaymentLogged:              return "debt_payment_logged"
        case .sharedBudgetInviteSent:         return "shared_budget_invite_sent"
        case .sharedBudgetInviteAccepted:     return "shared_budget_invite_accepted"
        case .onboardingNotificationDecision: return "onboarding_notification_decision"
        case .onboardingAccountCreated:       return "onboarding_account_created"
        case .onboardingQuizAbandoned:        return "onboarding_quiz_abandoned"
        case .paywallDiscountShown:           return "paywall_discount_shown"
        case .screenViewed:                   return "screen_viewed"
        case .featureUsed:                    return "feature_used"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .login(let method):                            return ["method": method]
        case .signUp(let method):                           return ["method": method]
        case .onboardingStepCompleted(let step):            return ["step": step]
        case .onboardingQuizAnswered(let i, let a):         return ["question_index": i, "answer": a]
        case .paywallShown(let trigger, let variant):       return ["trigger": trigger, "variant": variant]
        case .paywallPurchaseTapped(let id):                return ["product_id": id]
        case .paywallPurchaseCompleted(let id):             return ["product_id": id]
        case .transactionAdded(let category):               return ["category": category]
        case .savingsGoalCreated(let theme):                return ["theme": theme]
        case .savingsContributionLogged(let id, let a):     return ["goal_id": id, "amount": a]
        case .debtCreated(let theme):                       return ["theme": theme]
        case .debtPaymentLogged(let id, let a):             return ["debt_id": id, "amount": a]
        case .onboardingNotificationDecision(let granted):  return ["granted": granted]
        case .onboardingAccountCreated(let method):         return ["method": method]
        case .onboardingQuizAbandoned(let step):            return ["at_step": step]
        case .screenViewed(let name):                       return ["screen_name": name]
        case .featureUsed(let name):                        return ["feature_name": name]
        default:                                            return nil
        }
    }
}

protocol AnalyticsServiceProtocol: AnyObject {
    func track(_ event: AnalyticsEvent)
    func setUserId(_ id: String?)
    func setUserProperty(_ value: String?, for name: String)
}

final class MockAnalyticsService: AnalyticsServiceProtocol {
    private(set) var trackedEvents: [(name: String, params: [String: Any]?)] = []

    func track(_ event: AnalyticsEvent) {
        trackedEvents.append((event.name, event.parameters))
        AppLogger.debug("Analytics: \(event.name) \(event.parameters ?? [:])")
    }

    func setUserId(_ id: String?) {
        AppLogger.debug("Analytics setUserId: \(id ?? "nil")")
    }

    func setUserProperty(_ value: String?, for name: String) {
        AppLogger.debug("Analytics setUserProperty \(name) = \(value ?? "nil")")
    }
}
