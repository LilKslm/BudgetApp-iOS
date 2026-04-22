import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Handles user-scoped subcollections: `users/{uid}/{collection}/{documentId}`.
/// Top-level `users/{uid}` documents are managed by `FirestoreUserService`.
final class FirestoreDataService: DataServiceProtocol {
    private let db = Firestore.firestore()

    private func userScopedRef(collection: String, documentId: String) throws -> DocumentReference {
        guard let uid = Auth.auth().currentUser?.uid else { throw AppError.notAuthenticated }
        return db.collection("users").document(uid).collection(collection).document(documentId)
    }

    func fetch<T: Decodable>(collection: String, documentId: String) async throws -> T {
        let ref = try userScopedRef(collection: collection, documentId: documentId)
        let snapshot = try await ref.getDocument()
        guard snapshot.exists else { throw AppError.documentNotFound }
        do {
            return try snapshot.data(as: T.self)
        } catch {
            throw AppError.decodingFailed(error.localizedDescription)
        }
    }

    func save<T: Encodable>(_ object: T, collection: String, documentId: String) async throws {
        let ref = try userScopedRef(collection: collection, documentId: documentId)
        do {
            let data = try Firestore.Encoder().encode(object)
            try await ref.setData(data)
        } catch let appError as AppError {
            throw appError
        } catch {
            throw AppError.wrap(error)
        }
    }

    func update(collection: String, documentId: String, fields: [String: Any]) async throws {
        let ref = try userScopedRef(collection: collection, documentId: documentId)
        do {
            try await ref.updateData(fields)
        } catch {
            throw AppError.wrap(error)
        }
    }

    func delete(collection: String, documentId: String) async throws {
        let ref = try userScopedRef(collection: collection, documentId: documentId)
        do {
            try await ref.delete()
        } catch {
            throw AppError.wrap(error)
        }
    }
}
