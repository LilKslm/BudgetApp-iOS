import Foundation

/// Selects between mock and real service implementations at container build time.
///
/// - `#if DEBUG` builds default to mocks so previews, unit tests, and simulator dev
///   loops never depend on Firebase/RevenueCat secrets.
/// - Launch arg `-firebaseLive` flips a DEBUG build to real services without recompile,
///   so MacInCloud smoke tests exercise the real stack.
/// - Release builds always use real services.
enum AppEnvironment {
    static var shouldUseMockServices: Bool {
        #if DEBUG
        return !ProcessInfo.processInfo.arguments.contains("-firebaseLive")
        #else
        return false
        #endif
    }

    static var shouldUseMockPayments: Bool {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-useRealPayments") { return false }
        return shouldUseMockServices
        #else
        return false
        #endif
    }
}
