import SwiftUI

@main
struct BudgetAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .environment(\.appContainer, AppContainer.shared)
                .tint(AppTheme.Colors.accent)
        }
    }
}

// MARK: - Environment

private struct AppContainerKey: EnvironmentKey {
    static var defaultValue: AppContainer {
        MainActor.assumeIsolated { AppContainer.shared }
    }
}

extension EnvironmentValues {
    var appContainer: AppContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}
