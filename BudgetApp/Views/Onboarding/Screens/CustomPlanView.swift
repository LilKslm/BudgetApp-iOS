import SwiftUI

struct CustomPlanView: View {
    @ObservedObject var coordinator: OnboardingCoordinator

    private var plan: CustomPlan {
        CustomPlanBuilder.build(from: coordinator.quizAnswers)
    }

    var body: some View {
        OnboardingScaffold(progress: coordinator.progress) {
            VStack(spacing: AppTheme.Spacing.xl) {
                // Hero gradient card
                GradientCard {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("Your Plan")
                            .font(AppTheme.Typography.captionBold)
                            .foregroundStyle(.white.opacity(0.75))

                        Text(plan.heroHeadline)
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(.white)

                        Text(plan.subheadline)
                            .font(AppTheme.Typography.callout)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                .padding(.top, AppTheme.Spacing.lg)

                // Estimated savings
                SurfaceCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Estimated monthly savings")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                            Text(plan.estimatedMonthlySavings)
                                .font(AppTheme.Typography.largeNumber)
                                .foregroundStyle(AppTheme.Colors.accent)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(AppTheme.Colors.accent)
                    }
                }

                // Focus areas
                VStack(spacing: AppTheme.Spacing.sm) {
                    HStack {
                        Text("Your focus areas")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        Spacer()
                    }

                    ForEach(Array(plan.focusAreas.enumerated()), id: \.offset) { _, area in
                        FocusAreaRow(area: area)
                    }
                }

                Spacer(minLength: AppTheme.Spacing.lg)

                PrimaryButton("This is my plan") {
                    coordinator.advance()
                }
            }
        }
    }
}

private struct FocusAreaRow: View {
    let area: FocusArea

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                    .fill(AppTheme.Colors.accent.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: area.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(area.title)
                    .font(AppTheme.Typography.captionBold)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text(area.description)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
    }
}
