import Foundation

enum AppError: LocalizedError, Equatable {
    // Auth
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case notAuthenticated

    // Network / Data
    case networkUnavailable
    case decodingFailed(String)
    case documentNotFound
    case permissionDenied

    // Payments
    case purchaseFailed(String)
    case restoreFailed
    case productNotFound

    // Sharing
    case inviteNotFound
    case inviteExpired
    case inviteAlreadyClaimed
    case notAMember

    // Generic
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:     return "Invalid email or password."
        case .userNotFound:           return "No account found with that email."
        case .emailAlreadyInUse:      return "An account already exists for this email."
        case .weakPassword:           return "Password must be at least 8 characters."
        case .notAuthenticated:       return "You need to be signed in to do that."
        case .networkUnavailable:     return "No internet connection. Please try again."
        case .decodingFailed(let m):  return "Data error: \(m)"
        case .documentNotFound:       return "Requested data not found."
        case .permissionDenied:       return "You don't have permission to do that."
        case .purchaseFailed(let m):  return "Purchase failed: \(m)"
        case .restoreFailed:          return "Could not restore purchases."
        case .productNotFound:        return "Subscription product unavailable."
        case .inviteNotFound:         return "That invite code is invalid."
        case .inviteExpired:          return "That invite has expired."
        case .inviteAlreadyClaimed:   return "That invite has already been used."
        case .notAMember:             return "You're not a member of this shared budget."
        case .unknown(let m):         return m
        }
    }

    static func wrap(_ error: Error) -> AppError {
        if let app = error as? AppError { return app }
        return .unknown(error.localizedDescription)
    }
}
