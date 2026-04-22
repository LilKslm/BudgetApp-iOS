import Foundation
import Combine
import FirebaseAuth

final class FirebaseAuthService: AuthServiceProtocol {
    private let authSubject: CurrentValueSubject<Bool, Never>
    private var listenerHandle: AuthStateDidChangeListenerHandle?

    var currentUserId: String? { Auth.auth().currentUser?.uid }
    var isAuthenticated: Bool { Auth.auth().currentUser != nil }
    var authStatePublisher: AnyPublisher<Bool, Never> { authSubject.eraseToAnyPublisher() }

    init() {
        authSubject = CurrentValueSubject<Bool, Never>(Auth.auth().currentUser != nil)
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.authSubject.send(user != nil)
        }
    }

    deinit {
        if let handle = listenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw mapAuthError(error)
        }
    }

    func signUp(email: String, password: String) async throws {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            throw mapAuthError(error)
        }
    }

    func signInWithGoogle() async throws {
        throw AppError.notImplemented("Google Sign-In is coming soon. Use email sign-in for now.")
    }

    func signInWithApple() async throws {
        throw AppError.notImplemented("Sign in with Apple is coming soon. Use email sign-in for now.")
    }

    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw AppError.wrap(error)
        }
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { throw AppError.notAuthenticated }
        do {
            try await user.delete()
        } catch {
            throw mapAuthError(error)
        }
    }

    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw mapAuthError(error)
        }
    }

    // MARK: - Error mapping

    private func mapAuthError(_ error: Error) -> AppError {
        let code = AuthErrorCode(rawValue: (error as NSError).code)?.code
        switch code {
        case .wrongPassword, .invalidCredential, .invalidEmail:
            return .invalidCredentials
        case .userNotFound:
            return .userNotFound
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .networkUnavailable
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
