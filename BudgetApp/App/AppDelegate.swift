import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppLogger.info("BudgetApp launched")

        // Firebase + RevenueCat initialization lands in Phase 3 per project.md.
        // Keeping the AppDelegate in place now so Phase 1 has the right wiring point
        // (and FirebaseApp.configure() + PaymentService.shared.configure(apiKey:) slot in here cleanly).

        return true
    }
}
