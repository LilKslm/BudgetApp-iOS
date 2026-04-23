import Foundation

/// Resolves bundled secrets and exposes publishable keys.
///
/// `GoogleService-Info.plist` is gitignored and only present on machines that have
/// decoded the CI secret (or placed the file manually on MacInCloud). When missing we
/// log a warning and skip Firebase init so fresh clones and forks still build.
///
/// The RevenueCat key below is the **publishable** iOS SDK key — safe to commit per
/// RevenueCat's docs. The live server-side key never ships in the client.
enum SecretsLoader {
    /// RevenueCat publishable iOS SDK key. Swap to the live project key once the
    /// paid Apple Developer Program unlocks App Store Connect products
    /// (apple-developer-tasks.md item 2).
    static let revenueCatAPIKey = "test_PJKgaCQaUCINWsixkfLMuIeuENQ"

    /// True when `GoogleService-Info.plist` is present in the main bundle.
    static var hasFirebaseConfig: Bool {
        Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil
    }

    /// Logs a warning when the plist is absent. Call once at launch before
    /// attempting `FirebaseApp.configure()`.
    static func warnIfFirebaseConfigMissing() {
        guard !hasFirebaseConfig else { return }
        AppLogger.warn(
            "GoogleService-Info.plist not found — Firebase services disabled. " +
            "Drop the plist into BudgetApp/Resources/ (see GoogleService-Info.plist.sample)."
        )
    }
}
