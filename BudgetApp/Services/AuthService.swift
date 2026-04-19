import Foundation
import Combine

protocol AuthServiceProtocol: AnyObject {
    var currentUserId: String? { get }
    var isAuthenticated: Bool { get }
    var authStatePublisher: AnyPublisher<Bool, Never> { get }

    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signInWithGoogle() async throws
    func signInWithApple() async throws
    func signOut() throws
    func deleteAccount() async throws
    func resetPassword(email: String) async throws
}

/// Phase 1 mock. Phase 3 replaces with Firebase-backed implementation per project.md.
final class MockAuthService: AuthServiceProtocol {
    private let authSubject = CurrentValueSubject<Bool, Never>(false)
    private(set) var currentUserId: String?

    var isAuthenticated: Bool { currentUserId != nil }
    var authStatePublisher: AnyPublisher<Bool, Never> { authSubject.eraseToAnyPublisher() }

    var shouldThrow = false
    var errorToThrow: AppError = .invalidCredentials

    func signIn(email: String, password: String) async throws {
        if shouldThrow { throw errorToThrow }
        currentUserId = "mock-user-\(email.hashValue)"
        authSubject.send(true)
    }

    func signUp(email: String, password: String) async throws {
        try await signIn(email: email, password: password)
    }

    func signInWithGoogle() async throws {
        if shouldThrow { throw errorToThrow }
        currentUserId = "mock-google-user"
        authSubject.send(true)
    }

    func signInWithApple() async throws {
        if shouldThrow { throw errorToThrow }
        currentUserId = "mock-apple-user"
        authSubject.send(true)
    }

    func signOut() throws {
        currentUserId = nil
        authSubject.send(false)
    }

    func deleteAccount() async throws {
        currentUserId = nil
        authSubject.send(false)
    }

    func resetPassword(email: String) async throws {
        // no-op
    }
}
