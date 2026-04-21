import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var showPassword = false
    @Published var isLoading = false
    @Published var error: AppError?

    private let auth: AuthServiceProtocol
    private let analytics: AnalyticsServiceProtocol

    init(container: AppContainer = .shared) {
        self.auth = container.auth
        self.analytics = container.analytics
    }

    func signUp() async {
        guard !email.isEmpty, !password.isEmpty else {
            error = .invalidCredentials
            return
        }
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            try await auth.signUp(email: email, password: password)
            analytics.track(.signUp(method: "email"))
        } catch let e as AppError {
            error = e
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
