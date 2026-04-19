import SwiftUI
import Combine

enum AppState: Equatable {
    case loading
    case onboarding
    case unauthenticated
    case paywall
    case authenticated
}

@MainActor
final class AppViewModel: ObservableObject {
    @Published var state: AppState = .loading
    @Published var presentedError: AppError?

    private let auth: AuthServiceProtocol
    private let payments: PaymentServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    private let onboardingKey = "hasSeenOnboarding"

    /// Phase 1 default: spin up against the mock container. Phase 3 swaps to the real one in `BudgetAppApp`.
    init(container: AppContainer = .shared) {
        self.auth = container.auth
        self.payments = container.payments
        bootstrap()
    }

    private func bootstrap() {
        auth.authStatePublisher
            .combineLatest(payments.isPremiumPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuth, isPremium in
                self?.route(isAuthenticated: isAuth, isPremium: isPremium)
            }
            .store(in: &cancellables)

        // Seed initial state once — publishers above will drive subsequent transitions.
        route(isAuthenticated: auth.isAuthenticated, isPremium: payments.isPremium)
    }

    private func route(isAuthenticated: Bool, isPremium: Bool) {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)

        if !hasSeenOnboarding {
            state = .onboarding
        } else if !isAuthenticated {
            state = .unauthenticated
        } else if !isPremium {
            state = .paywall
        } else {
            state = .authenticated
        }
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: onboardingKey)
        route(isAuthenticated: auth.isAuthenticated, isPremium: payments.isPremium)
    }

    func presentError(_ error: AppError) {
        presentedError = error
    }

    // MARK: - Debug helpers (removed post-Phase 3)

    func _debugResetOnboarding() {
        UserDefaults.standard.removeObject(forKey: onboardingKey)
        route(isAuthenticated: auth.isAuthenticated, isPremium: payments.isPremium)
    }
}
