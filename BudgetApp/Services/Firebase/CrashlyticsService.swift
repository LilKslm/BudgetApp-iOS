import Foundation
import FirebaseCore
import FirebaseCrashlytics

/// Thin reporter forwarding errors to Crashlytics in non-DEBUG builds.
/// Safe to call before Firebase is configured — guards on FirebaseApp.app().
final class CrashlyticsService {
    static let shared = CrashlyticsService()
    private init() {}

    func record(_ error: Error) {
        guard !AppEnvironment.shouldUseMockServices, FirebaseApp.app() != nil else { return }
        Crashlytics.crashlytics().record(error: error)
    }

    func log(_ message: String) {
        guard FirebaseApp.app() != nil else { return }
        Crashlytics.crashlytics().log(message)
    }
}
