import Foundation
import FirebaseAnalytics

final class FirebaseAnalyticsService: AnalyticsServiceProtocol {
    private static let reservedPrefixes = ["firebase_", "google_", "ga_"]

    func track(_ event: AnalyticsEvent) {
        #if DEBUG
        let name = event.name
        assert(name.count <= 40, "Analytics event name '\(name)' exceeds Firebase 40-char limit")
        for prefix in Self.reservedPrefixes {
            assert(!name.hasPrefix(prefix),
                   "Analytics event name '\(name)' uses reserved prefix '\(prefix)'")
        }
        if let params = event.parameters {
            assert(params.count <= 25, "Event '\(name)' has \(params.count) params; Firebase cap is 25")
        }
        #endif
        Analytics.logEvent(event.name, parameters: event.parameters)
    }

    func setUserId(_ id: String?) {
        Analytics.setUserID(id)
    }

    func setUserProperty(_ value: String?, for name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}
