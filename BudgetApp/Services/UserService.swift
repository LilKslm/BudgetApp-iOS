import Foundation

protocol UserServiceProtocol: AnyObject {
    func createUserDocument(_ user: AppUser) async throws
    func fetchUser(uid: String) async throws -> AppUser
    func updateQuizAnswers(_ answers: QuizAnswers, for uid: String) async throws
    func setOnboardingCompleted(uid: String) async throws
}

final class MockUserService: UserServiceProtocol {
    private var store: [String: AppUser] = [:]
    var shouldThrow = false

    func createUserDocument(_ user: AppUser) async throws {
        if shouldThrow { throw AppError.permissionDenied }
        store[user.id] = user
    }

    func fetchUser(uid: String) async throws -> AppUser {
        if shouldThrow { throw AppError.documentNotFound }
        guard let user = store[uid] else { throw AppError.documentNotFound }
        return user
    }

    func updateQuizAnswers(_ answers: QuizAnswers, for uid: String) async throws {
        if shouldThrow { throw AppError.permissionDenied }
        store[uid]?.quizAnswers = answers
    }

    func setOnboardingCompleted(uid: String) async throws {
        if shouldThrow { throw AppError.permissionDenied }
        store[uid]?.onboardingCompleted = true
    }
}
