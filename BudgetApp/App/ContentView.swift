import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            Group {
                switch appViewModel.state {
                case .loading:
                    LoadingSplashView()

                case .onboarding:
                    OnboardingPlaceholderView()

                case .unauthenticated:
                    LoginPlaceholderView()

                case .paywall:
                    PaywallPlaceholderView()

                case .authenticated:
                    MainTabView()
                }
            }
            .transition(.opacity)
        }
        .animation(AppTheme.Motion.soft, value: appViewModel.state)
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { appViewModel.presentedError != nil },
                set: { if !$0 { appViewModel.presentedError = nil } }
            ),
            presenting: appViewModel.presentedError
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { err in
            Text(err.errorDescription ?? "Unknown error")
        }
    }
}

private struct LoadingSplashView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Circle()
                .fill(AppTheme.Gradients.primary)
                .frame(width: 72, height: 72)
                .overlay(
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                )
                .themeShadow(AppTheme.Shadow.raised)
            ProgressView()
        }
    }
}
