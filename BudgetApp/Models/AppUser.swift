import Foundation

struct AppUser: Codable, Identifiable, Equatable {
    let id: String
    var email: String
    var displayName: String?
    var isPremium: Bool
    var createdAt: Date
    var onboardingCompleted: Bool
    var quizAnswers: QuizAnswers?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case isPremium   = "is_premium"
        case createdAt   = "created_at"
        case onboardingCompleted = "onboarding_completed"
        case quizAnswers = "quiz_answers"
    }
}

struct QuizAnswers: Codable, Equatable {
    var moneyStress: String?
    var pastBudgetingAttempts: String?
    var currentTrackingHabit: String?
    var biggestFrustration: String?
    var savingsCushion: String?
    var debtSituation: String?
    var subscriptionAwareness: String?
    var firstSavingsGoal: String?
    var sharedFinances: String?
    var moneyConfidence: String?
}
