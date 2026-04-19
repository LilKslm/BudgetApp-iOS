import SwiftUI

/// Phase 1 placeholder — real email/Google/Apple sign-in lands in Phase 3.
struct LoginPlaceholderView: View {
    @Environment(\.appContainer) private var container

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Sign in")
                    .font(AppTheme.Typography.title)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Phase 3 wires real Firebase Auth. For now, tap to continue with a mock user.")
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }

            Spacer()

            PrimaryButton("Continue with mock user") {
                Task {
                    try? await container.auth.signIn(email: "demo@budgetapp.com", password: "mockpass")
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
    }
}

#Preview {
    LoginPlaceholderView()
}
