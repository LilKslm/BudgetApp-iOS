import SwiftUI
import Combine

@MainActor
final class OnboardingCoordinator: ObservableObject {
    @Published var path: [OnboardingStep] = []
    @Published var quizAnswers = QuizAnswers()
    @Published var notificationDecision: Bool? = nil
    @Published var showingDiscountedPaywall = false
    @Published var isAuthDone = false

    private let analytics: AnalyticsServiceProtocol
    private let stepResumeKey = "onboardingCurrentStep"
    private let answersResumeKey = "onboardingQuizAnswers"

    init(container: AppContainer = .shared) {
        self.analytics = container.analytics
        restoreIfNeeded()
        // Seed first step if nothing to resume so NavigationStack never starts with an empty path.
        if path.isEmpty {
            path = [.quiz(index: 0)]
            persistStep(.quiz(index: 0))
        }
    }

    // MARK: - Navigation

    func advance() {
        guard let current = currentStep else { return }
        let next = nextStep(after: current)
        path.append(next)
        analytics.track(.onboardingStepCompleted(step: next.stepNumber))
        persistStep(next)
    }

    func back() {
        guard !path.isEmpty, currentStep?.allowsBack == true else { return }
        path.removeLast()
        if let prev = currentStep { persistStep(prev) }
    }

    func answer(questionIndex: Int, answer: String) {
        applyAnswer(questionIndex: questionIndex, answer: answer)
        analytics.track(.onboardingQuizAnswered(questionIndex: questionIndex, answer: answer))
        persistAnswers()
        advance()
    }

    func declineFirstPaywall() {
        showingDiscountedPaywall = true
        analytics.track(.paywallDiscountShown)
    }

    func completeAccount() {
        isAuthDone = true
        advance()
    }

    func completePurchase() {
        clearResume()
    }

    // MARK: - Helpers

    var currentStep: OnboardingStep? { path.last }

    var progress: Double {
        let step = currentStep?.stepNumber ?? 0
        return Double(step) / Double(OnboardingStep.totalSteps)
    }

    private func nextStep(after step: OnboardingStep) -> OnboardingStep {
        switch step {
        case .quiz(let i):
            return i < 9 ? .quiz(index: i + 1) : .results
        case .results:         return .pain
        case .pain:            return .howWeHelp
        case .howWeHelp:       return .reviews
        case .reviews:         return .featureTour
        case .featureTour:     return .customPlan
        case .customPlan:      return .notificationPrompt
        case .notificationPrompt: return .account
        case .account:         return .paywall
        case .paywall:         return .paywall
        }
    }

    // MARK: - Quiz answer mapping

    private func applyAnswer(questionIndex: Int, answer: String) {
        switch questionIndex {
        case 0: quizAnswers.moneyStress = answer
        case 1: quizAnswers.pastBudgetingAttempts = answer
        case 2: quizAnswers.currentTrackingHabit = answer
        case 3: quizAnswers.biggestFrustration = answer
        case 4: quizAnswers.savingsCushion = answer
        case 5: quizAnswers.debtSituation = answer
        case 6: quizAnswers.subscriptionAwareness = answer
        case 7: quizAnswers.firstSavingsGoal = answer
        case 8: quizAnswers.sharedFinances = answer
        case 9: quizAnswers.moneyConfidence = answer
        default: break
        }
    }

    func selectedAnswer(for questionIndex: Int) -> String? {
        switch questionIndex {
        case 0: return quizAnswers.moneyStress
        case 1: return quizAnswers.pastBudgetingAttempts
        case 2: return quizAnswers.currentTrackingHabit
        case 3: return quizAnswers.biggestFrustration
        case 4: return quizAnswers.savingsCushion
        case 5: return quizAnswers.debtSituation
        case 6: return quizAnswers.subscriptionAwareness
        case 7: return quizAnswers.firstSavingsGoal
        case 8: return quizAnswers.sharedFinances
        case 9: return quizAnswers.moneyConfidence
        default: return nil
        }
    }

    // MARK: - Resume persistence

    private func persistStep(_ step: OnboardingStep) {
        UserDefaults.standard.set(step.stepNumber, forKey: stepResumeKey)
    }

    private func persistAnswers() {
        guard let data = try? JSONEncoder().encode(quizAnswers) else { return }
        UserDefaults.standard.set(data, forKey: answersResumeKey)
    }

    private func restoreIfNeeded() {
        let savedStep = UserDefaults.standard.integer(forKey: stepResumeKey)
        guard savedStep > 0 else { return }

        if let data = UserDefaults.standard.data(forKey: answersResumeKey),
           let answers = try? JSONDecoder().decode(QuizAnswers.self, from: data) {
            quizAnswers = answers
        }

        // Rebuild path up to the saved step
        var rebuilt: [OnboardingStep] = []
        var step: OnboardingStep = .quiz(index: 0)
        rebuilt.append(step)
        while step.stepNumber < savedStep {
            let next = nextStep(after: step)
            if next.stepNumber <= savedStep {
                rebuilt.append(next)
                step = next
            } else { break }
        }
        path = rebuilt
    }

    func clearResume() {
        UserDefaults.standard.removeObject(forKey: stepResumeKey)
        UserDefaults.standard.removeObject(forKey: answersResumeKey)
    }
}
