import SwiftUI

/// Phase 1 placeholder — full `PaywallView` with standard + discounted variants lands in Phase 2,
/// real RevenueCat purchases in Phase 3. Debug unlock button will disappear post-enrollment
/// (tracked in apple-developer-tasks.md item 2).
struct PaywallPlaceholderView: View {
    @Environment(\.appContainer) private var container

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            VStack(spacing: AppTheme.Spacing.md) {
                Text("Unlock BudgetApp Pro")
                    .font(AppTheme.Typography.title)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Shared budgets, unlimited goals, bank linking, and more.")
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }

            Spacer()

            #if DEBUG
            PrimaryButton("Skip paywall (DEBUG)") {
                (container.payments as? MockPaymentService)?._debugSetPremium(true)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.xl)
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Gradients.backgroundWash)
    }
}

#Preview {
    PaywallPlaceholderView()
}
