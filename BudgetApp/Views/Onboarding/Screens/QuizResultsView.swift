import SwiftUI

struct QuizResultsView: View {
    @ObservedObject var coordinator: OnboardingCoordinator

    var body: some View {
        OnboardingScaffold(progress: coordinator.progress) {
            VStack(spacing: AppTheme.Spacing.xl) {
                VStack(spacing: AppTheme.Spacing.md) {
                    Circle()
                        .fill(AppTheme.Gradients.primary)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .themeShadow(AppTheme.Shadow.raised)
                        .padding(.top, AppTheme.Spacing.lg)

                    Text("Here's what we learned about you")
                        .font(AppTheme.Typography.title)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(callouts, id: \.icon) { item in
                        ResultCalloutRow(icon: item.icon, text: item.text)
                    }
                }

                Spacer(minLength: AppTheme.Spacing.xxl)

                PrimaryButton("Build my plan") {
                    coordinator.advance()
                }
            }
        }
    }

    private struct CalloutItem { let icon: String; let text: String }

    private var callouts: [CalloutItem] {
        var items: [CalloutItem] = []

        if let stress = coordinator.quizAnswers.moneyStress,
           stress == "a_lot" || stress == "daily" {
            items.append(CalloutItem(icon: "heart.fill", text: "You're dealing with real money stress. You're not alone — 68% of users start the same way."))
        } else {
            items.append(CalloutItem(icon: "heart.fill", text: "You're thinking about your finances — that already puts you ahead."))
        }

        if let habit = coordinator.quizAnswers.currentTrackingHabit, habit == "none" || habit == "mental" {
            items.append(CalloutItem(icon: "chart.bar.fill", text: "Most people who don't track spend 23% more than they think they do."))
        } else {
            items.append(CalloutItem(icon: "chart.bar.fill", text: "You already have a tracking habit — we'll make it effortless."))
        }

        if let subs = coordinator.quizAnswers.subscriptionAwareness, subs == "none" || subs == "few" {
            items.append(CalloutItem(icon: "creditcard.fill", text: "The average person has $219 in subscriptions they've forgotten about."))
        } else {
            items.append(CalloutItem(icon: "creditcard.fill", text: "Knowing your subscriptions is step one — we'll help you trim the rest."))
        }

        return items
    }
}

private struct ResultCalloutRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.Colors.accent)
                .font(.system(size: 18))
                .frame(width: 28)
                .padding(.top, 2)

            Text(text)
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
    }
}
