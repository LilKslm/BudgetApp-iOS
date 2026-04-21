import SwiftUI

struct HowWeHelpView: View {
    @ObservedObject var coordinator: OnboardingCoordinator

    private let steps: [(icon: String, color: Color, title: String, detail: String)] = [
        ("bolt.fill",        AppTheme.Colors.accent,   "Track without friction",
         "Log a transaction in two taps. No spreadsheet. No Sunday catch-up."),
        ("chart.pie.fill",   AppTheme.Colors.cardSky,  "See every dollar clearly",
         "Know where your money actually goes — not where you think it goes."),
        ("trophy.fill",      AppTheme.Colors.cardMint, "Watch goals build like a game",
         "Every dollar saved moves your visual. Saving becomes something you want to do.")
    ]

    var body: some View {
        OnboardingScaffold(progress: coordinator.progress) {
            VStack(spacing: AppTheme.Spacing.xl) {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text("Here's how BudgetApp works")
                        .font(AppTheme.Typography.title)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.top, AppTheme.Spacing.sm)

                    Text("Three things we do differently.")
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: AppTheme.Spacing.md) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                        HelpStepRow(
                            number: i + 1,
                            icon: step.icon,
                            tint: step.color,
                            title: step.title,
                            detail: step.detail
                        )
                    }
                }
            }
        } footer: {
            PrimaryButton("Sounds good") {
                coordinator.advance()
            }
        }
    }
}

private struct HelpStepRow: View {
    let number: Int
    let icon: String
    let tint: Color
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                    .fill(tint.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text(detail)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
    }
}
