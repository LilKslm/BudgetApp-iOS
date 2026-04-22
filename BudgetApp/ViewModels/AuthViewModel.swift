import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var showPassword = false
    @Published var isLoading = false
    @Published var error: AppError?

    private let auth: AuthServiceProtocol
    private let users: UserServiceProtocol
    private let analytics: AnalyticsServiceProtocol

    init(container: AppContainer = .shared) {
        self.auth = container.auth
        self.users = container.users
        self.analytics = container.analytics
    }

    /// Sign up + create Firestore user doc atomically. Rolls back the Auth user
    /// if the Firestore write fails so no orphaned credentials exist.
    func completeSignUp(quizAnswers: QuizAnswers) async {
        guard !email.isEmpty, !password.isEmpty else {
            error = .invalidCredentials
            return
        }
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            try await auth.signUp(email: email, password: password)
            guard let uid = auth.currentUserId else { throw AppError.notAuthenticated }
            let user = AppUser(
                id: uid,
                email: email,
                displayName: nil,
                isPremium: false,
                createdAt: Date(),
                onboardingCompleted: false,
                quizAnswers: quizAnswers
            )
            do {
                try await users.createUserDocument(user)
            } catch {
                try? await auth.deleteAccount()
                throw AppError.wrap(error)
            }
            analytics.track(.signUp(method: "email"))
        } catch let e as AppError {
            self.error = e
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            error = .invalidCredentials
            return
        }
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            try await auth.signIn(email: email, password: password)
            analytics.track(.login(method: "email"))
        } catch let e as AppError {
            error = e
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func signInWithGoogle() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            try await auth.signInWithGoogle()
            analytics.track(.login(method: "google"))
        } catch let e as AppError {
            error = e
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func signInWithApple() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            try await auth.signInWithApple()
            analytics.track(.login(method: "apple"))
        } catch let e as AppError {
            error = e
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }
}
