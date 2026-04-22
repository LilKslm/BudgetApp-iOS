import Foundation

/// Selects between mock and real service implementations at container build time.
///
/// - SwiftUI previews always get mocks (no Firebase plist available in the preview host).
/// - Debug + Release both default to real services so Xcode Run talks to Firebase/RevenueCat
///   without needing per-machine scheme edits.
/// - Launch arg `-useMocks` forces mocks in Debug (useful for offline dev or when the
///   Firebase plist is missing).
enum AppEnvironment {
    private static var isRunningForPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    static var shouldUseMockServices: Bool {
        if isRunningForPreviews { return true }
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("-useMocks")
        #else
        return false
        #endif
    }

    static var shouldUseMockPayments: Bool {
        shouldUseMockServices
    }
}
