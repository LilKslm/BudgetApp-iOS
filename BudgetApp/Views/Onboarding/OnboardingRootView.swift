import SwiftUI

struct OnboardingRootView: View {
    @StateObject private var coordinator = OnboardingCoordinator()
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.appContainer) private var container

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            Color.clear
                .navigationDestination(for: OnboardingStep.self) { step in
                    destinationView(for: step)
                        .navigationBarHidden(true)
                }
        }
        .onAppear {
            // Track start only on a true fresh session (step 1, no prior answers).
            if coordinator.currentStep == .quiz(index: 0),
               coordinator.quizAnswers == QuizAnswers() {
                container.analytics.track(.onboardingStarted)
            }
        }
        .onDisappear {
            if let step = coordinator.currentStep, step != .paywall {
                container.analytics.track(.onboardingQuizAbandoned(atStep: step.stepNumber))
            }
        }
    }

    @ViewBuilder
    private func destinationView(for step: OnboardingStep) -> some View {
        switch step {
        case .quiz(let index):
            QuizQuestionView(
                question: quizQuestions[index],
                questionIndex: index,
                selected: coordinator.selectedAnswer(for: index),
                coordinator: coordinator
            )

        case .results:
            QuizResultsView(coordinator: coordinator)

        case .pain:
            PainPointView(coordinator: coordinator)

        case .howWeHelp:
            HowWeHelpView(coordinator: coordinator)

        case .reviews:
            ReviewsView(coordinator: coordinator)

        case .featureTour:
            FeatureTourView(coordinator: coordinator)

        case .customPlan:
            CustomPlanView(coordinator: coordinator)

        case .notificationPrompt:
            NotificationPromptView(coordinator: coordinator)

        case .account:
            AccountView(coordinator: coordinator)

        case .paywall:
            PaywallView(coordinator: coordinator)
                .environmentObject(appViewModel)
        }
    }
}
