import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class FirestoreUserService: UserServiceProtocol {
    private let db = Firestore.firestore()
    private let col = "users"

    func createUserDocument(_ user: AppUser) async throws {
        do {
            let data = try Firestore.Encoder().encode(user)
            try await db.collection(col).document(user.id).setData(data)
        } catch {
            throw AppError.wrap(error)
        }
    }

    func fetchUser(uid: String) async throws -> AppUser {
        let snapshot = try await db.collection(col).document(uid).getDocument()
        guard snapshot.exists else { throw AppError.documentNotFound }
        do {
            return try snapshot.data(as: AppUser.self)
        } catch {
            throw AppError.decodingFailed(error.localizedDescription)
        }
    }

    func updateQuizAnswers(_ answers: QuizAnswers, for uid: String) async throws {
        do {
            let encoded = try Firestore.Encoder().encode(answers)
            try await db.collection(col).document(uid).updateData(["quiz_answers": encoded])
        } catch {
            throw AppError.wrap(error)
        }
    }

    func setOnboardingCompleted(uid: String) async throws {
        do {
            try await db.collection(col).document(uid).updateData(["onboarding_completed": true])
        } catch {
            throw AppError.wrap(error)
        }
    }
}
