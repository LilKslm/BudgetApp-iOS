import UIKit
import FirebaseCore

@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate {
    nonisolated func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        MainActor.assumeIsolated {
            AppLogger.info("BudgetApp launched")

            if !AppEnvironment.shouldUseMockServices {
                SecretsLoader.warnIfFirebaseConfigMissing()
                if SecretsLoader.hasFirebaseConfig, FirebaseApp.app() == nil {
                    FirebaseApp.configure()
                    AppLogger.info("Firebase configured")
                }
            }

            // Mock payments no-op; RevenueCat impl calls Purchases.configure(...).
            AppContainer.shared.payments.configure()
        }
        return true
    }
}
