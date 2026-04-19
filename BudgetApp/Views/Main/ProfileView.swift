import SwiftUI

struct ProfileView: View {
    @Environment(\.appContainer) private var container
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: AppTheme.Spacing.md) {
                        Circle()
                            .fill(AppTheme.Gradients.primary)
                            .frame(width: 56, height: 56)
                            .overlay(
                                Text("BA")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundStyle(.white)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Demo User")
                                .font(AppTheme.Typography.headline)
                            Text("demo@budgetapp.com")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(AppTheme.Colors.surface)
                }

                Section("Subscription") {
                    HStack {
                        Text(container.payments.isPremium ? "BudgetApp Pro" : "Free plan")
                            .font(AppTheme.Typography.callout)
                        Spacer()
                        if !container.payments.isPremium {
                            Text("Upgrade")
                                .font(AppTheme.Typography.captionBold)
                                .foregroundStyle(AppTheme.Colors.accent)
                        }
                    }
                    .listRowBackground(AppTheme.Colors.surface)
                }

                Section("Preferences") {
                    Label("Appearance", systemImage: "circle.lefthalf.filled").listRowBackground(AppTheme.Colors.surface)
                    Label("Notifications", systemImage: "bell.fill").listRowBackground(AppTheme.Colors.surface)
                    Label("Export data", systemImage: "square.and.arrow.up").listRowBackground(AppTheme.Colors.surface)
                }

                #if DEBUG
                Section("Debug") {
                    Button("Reset onboarding") {
                        appViewModel._debugResetOnboarding()
                    }
                    .listRowBackground(AppTheme.Colors.surface)

                    Button("Sign out") {
                        try? container.auth.signOut()
                    }
                    .listRowBackground(AppTheme.Colors.surface)

                    Button("Toggle Pro") {
                        let current = container.payments.isPremium
                        (container.payments as? MockPaymentService)?._debugSetPremium(!current)
                    }
                    .listRowBackground(AppTheme.Colors.surface)
                }
                #endif
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.background)
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environment(\.appContainer, AppContainer.shared)
        .environmentObject(AppViewModel())
}
