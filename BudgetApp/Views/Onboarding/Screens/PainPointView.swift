import SwiftUI

struct PainPointView: View {
    @ObservedObject var coordinator: OnboardingCoordinator

    var body: some View {
        OnboardingScaffold(progress: coordinator.progress) {
            VStack(spacing: AppTheme.Spacing.xl) {
                Circle()
                    .fill(AppTheme.Gradients.hero)
                    .frame(width: 96, height: 96)
                    .overlay(
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                    .themeShadow(AppTheme.Shadow.raised)
                    .padding(.top, AppTheme.Spacing.lg)

                VStack(spacing: AppTheme.Spacing.sm) {
                    Text(headline)
                        .font(AppTheme.Typography.title)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: AppTheme.Spacing.sm) {
                    StatRow(stat: "78%", label: "of people who try to budget alone give up within 3 months.")
                    StatRow(stat: "$2,400", label: "average annual loss from forgotten subscriptions and impulse buys.")
                    StatRow(stat: "1 in 3", label: "adults couldn't cover a $400 emergency without borrowing.")
                }

                Spacer(minLength: AppTheme.Spacing.xxl)

                PrimaryButton("I want to change this") {
                    coordinator.advance()
                }
            }
        }
    }

    private var headline: String {
        let frustration = coordinator.quizAnswers.biggestFrustration ?? "no_stick"
        switch frustration {
        case "too_manual":   return "Manual tracking shouldn't take your whole Sunday."
        case "complicated":  return "Budgeting shouldn't need a finance degree."
        case "restrictive":  return "A budget should feel like freedom, not a cage."
        default:             return "Budgeting shouldn't feel like punishment."
        }
    }

    private var subtitle: String {
        let stress = coordinator.quizAnswers.moneyStress ?? "a_lot"
        if stress == "a_lot" || stress == "daily" {
            return "You're carrying real financial stress. Most budgeting apps make it worse — not better."
        }
        return "Most budgeting apps are built to track the past, not build your future."
    }
}

private struct StatRow: View {
    let stat: String
    let label: String

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            Text(stat)
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.accent)
                .frame(width: 72, alignment: .leading)

            Text(label)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            Spacer(minLength: 0)
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
    }
}
