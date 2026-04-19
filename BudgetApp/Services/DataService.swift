import Foundation

/// Generic data access layer. Phase 3 wires to Firestore; Phase 1 uses the in-memory mock.
/// Collections with invariants (shared budgets, invites) go through their own services —
/// never call DataService directly for those (per appcreation.md §12.10).
protocol DataServiceProtocol: AnyObject {
    func fetch<T: Decodable>(collection: String, documentId: String) async throws -> T
    func save<T: Encodable>(_ object: T, collection: String, documentId: String) async throws
    func update(collection: String, documentId: String, fields: [String: Any]) async throws
    func delete(collection: String, documentId: String) async throws
}

final class MockDataService: DataServiceProtocol {
    private var store: [String: [String: Data]] = [:]
    private let queue = DispatchQueue(label: "mock-data-service", attributes: .concurrent)

    func fetch<T: Decodable>(collection: String, documentId: String) async throws -> T {
        try queue.sync {
            guard let raw = store[collection]?[documentId] else { throw AppError.documentNotFound }
            return try JSONDecoder.appDefault.decode(T.self, from: raw)
        }
    }

    func save<T: Encodable>(_ object: T, collection: String, documentId: String) async throws {
        let encoded = try JSONEncoder.appDefault.encode(object)
        queue.sync(flags: .barrier) {
            store[collection, default: [:]][documentId] = encoded
        }
    }

    func update(collection: String, documentId: String, fields: [String: Any]) async throws {
        // Mock-only: merges at the JSON-object level. Real Firestore implementation handles this server-side.
        queue.sync(flags: .barrier) {
            guard let existing = store[collection]?[documentId] else { return }
            guard var dict = (try? JSONSerialization.jsonObject(with: existing)) as? [String: Any] else { return }
            for (k, v) in fields { dict[k] = v }
            if let merged = try? JSONSerialization.data(withJSONObject: dict) {
                store[collection]?[documentId] = merged
            }
        }
    }

    func delete(collection: String, documentId: String) async throws {
        queue.sync(flags: .barrier) {
            store[collection]?.removeValue(forKey: documentId)
        }
    }
}

extension JSONEncoder {
    static let appDefault: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
}

extension JSONDecoder {
    static let appDefault: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
