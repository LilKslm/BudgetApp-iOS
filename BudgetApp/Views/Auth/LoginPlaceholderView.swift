import SwiftUI

/// Phase 1 placeholder — full email/Google/Apple UI lands in Phase 3e.
///
/// The "Continue with demo user" button is a dev convenience that works for both
/// service modes: against `MockAuthService` it just flips the auth subject; against
/// `FirebaseAuthService` it signs into `demo@budgetapp.com`, auto-provisioning the
/// account on first run if it doesn't exist.
struct LoginPlaceholderView: View {
    @Environment(\.appContainer) private var container
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var isSigningIn = false

    private let demoEmail = "demo@budgetapp.com"
    private let demoPassword = "DemoPass1!"

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Sign in")
                    .font(AppTheme.Typography.title)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Phase 3 wires real Firebase Auth. For now, tap to continue with a demo account.")
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }

            Spacer()

            PrimaryButton("Continue with demo user", isLoading: isSigningIn) {
                continueAsDemo()
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
    }

    private func continueAsDemo() {
        isSigningIn = true
        Task {
            do {
                try await signInOrProvisionDemo()
            } catch let error as AppError {
                appViewModel.presentError(error)
            } catch {
                appViewModel.presentError(.unknown(error.localizedDescription))
            }
            isSigningIn = false
        }
    }

    // Sign in first; on a fresh Firebase project the demo user won't exist yet —
    // Firebase reports either `.userNotFound` or (with email-enumeration protection
    // enabled) `.invalidCredentials`. In both cases, create the account and Firebase's
    // auth state listener will flip `isAuthenticated` on its own.
    private func signInOrProvisionDemo() async throws {
        do {
            try await container.auth.signIn(email: demoEmail, password: demoPassword)
        } catch AppError.userNotFound, AppError.invalidCredentials {
            try await container.auth.signUp(email: demoEmail, password: demoPassword)
        }
    }
}

#Preview {
    LoginPlaceholderView()
        .environmentObject(AppViewModel())
}
