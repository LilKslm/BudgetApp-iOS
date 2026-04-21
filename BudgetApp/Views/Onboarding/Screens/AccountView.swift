import SwiftUI

struct AccountView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @StateObject private var authVM = AuthViewModel()
    @State private var isSignUp = true

    var body: some View {
        OnboardingScaffold(progress: coordinator.progress) {
            VStack(spacing: AppTheme.Spacing.xl) {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text(isSignUp ? "Create your account" : "Welcome back")
                        .font(AppTheme.Typography.title)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .padding(.top, AppTheme.Spacing.lg)

                    Text("Your plan is saved to your account — access it from any device.")
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // Sign up / log in toggle
                Picker("", selection: $isSignUp) {
                    Text("Sign up").tag(true)
                    Text("Log in").tag(false)
                }
                .pickerStyle(.segmented)

                // Email + password fields
                VStack(spacing: AppTheme.Spacing.sm) {
                    TextField("Email", text: $authVM.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .stroke(AppTheme.Colors.divider, lineWidth: 1)
                        )

                    HStack {
                        Group {
                            if authVM.showPassword {
                                TextField("Password", text: $authVM.password)
                            } else {
                                SecureField("Password", text: $authVM.password)
                            }
                        }
                        .textContentType(isSignUp ? .newPassword : .password)
                        .autocapitalization(.none)

                        Button(action: { authVM.showPassword.toggle() }) {
                            Image(systemName: authVM.showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                        }
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .stroke(AppTheme.Colors.divider, lineWidth: 1)
                    )
                }

                if let error = authVM.error {
                    Text(error.errorDescription ?? "Something went wrong.")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.danger)
                        .multilineTextAlignment(.center)
                }

                PrimaryButton(isSignUp ? "Create account" : "Log in", isLoading: authVM.isLoading) {
                    Task { await submit() }
                }

                // Divider
                HStack {
                    Rectangle().fill(AppTheme.Colors.divider).frame(height: 1)
                    Text("or").font(AppTheme.Typography.caption).foregroundStyle(AppTheme.Colors.textTertiary)
                    Rectangle().fill(AppTheme.Colors.divider).frame(height: 1)
                }

                // Social buttons
                VStack(spacing: AppTheme.Spacing.sm) {
                    SocialAuthButton(icon: "apple.logo", label: "Continue with Apple") {
                        Task { await signInSocial(method: "apple") }
                    }
                    SocialAuthButton(icon: "g.circle.fill", label: "Continue with Google") {
                        Task { await signInSocial(method: "google") }
                    }
                }

                Spacer(minLength: AppTheme.Spacing.xl)
            }
        }
        .onChange(of: authVM.error) { _, newError in
            // Error already shown inline; haptic feedback
            if newError != nil { /* haptics via VM in future */ }
        }
    }

    private func submit() async {
        if isSignUp {
            await authVM.signUp()
        } else {
            await authVM.signIn()
        }
        if authVM.error == nil {
            coordinator.completeAccount()
        }
    }

    private func signInSocial(method: String) async {
        if method == "apple" {
            await authVM.signInWithApple()
        } else {
            await authVM.signInWithGoogle()
        }
        if authVM.error == nil {
            coordinator.completeAccount()
        }
    }
}

private struct SocialAuthButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                Text(label)
                    .font(AppTheme.Typography.callout)
            }
            .foregroundStyle(AppTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(AppTheme.Colors.divider, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
