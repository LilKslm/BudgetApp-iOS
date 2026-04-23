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
                // Don't probe `FirebaseApp.app()` before configure — FirebaseCore logs
                // an I-COR000003 warning whenever that accessor runs pre-configure, even
                // if we discard the result. didFinishLaunching runs exactly once, so an
                // existence check isn't needed here.
                if SecretsLoader.hasFirebaseConfig {
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
