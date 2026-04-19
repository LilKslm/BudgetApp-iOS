import SwiftUI

/// Phase 1 placeholder — the real 18-screen onboarding ships in Phase 2
/// (10-question quiz → results → pain → how-we-help → reviews → feature tour → custom plan → paywall).
struct OnboardingPlaceholderView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            AppTheme.Gradients.backgroundWash.ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer()

                VStack(spacing: AppTheme.Spacing.md) {
                    Circle()
                        .fill(AppTheme.Gradients.primary)
                        .frame(width: 96, height: 96)
                        .overlay(
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .themeShadow(AppTheme.Shadow.raised)

                    Text("Welcome to BudgetApp")
                        .font(AppTheme.Typography.title)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text("Track, save, and watch your goals come to life.")
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.Spacing.xl)
                }

                Spacer()

                PrimaryButton("Continue") {
                    appViewModel.completeOnboarding()
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.xl)
            }
        }
    }
}

#Preview {
    OnboardingPlaceholderView()
        .environmentObject(AppViewModel())
}
