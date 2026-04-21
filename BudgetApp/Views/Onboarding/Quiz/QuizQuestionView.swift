import SwiftUI

struct QuizQuestionView: View {
    let question: QuizQuestion
    let questionIndex: Int
    let selected: String?
    @ObservedObject var coordinator: OnboardingCoordinator

    var body: some View {
        OnboardingScaffold(
            progress: coordinator.progress,
            allowsBack: questionIndex > 0,
            onBack: coordinator.back
        ) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text("Question \(questionIndex + 1) of 10")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)

                    Text(question.prompt)
                        .font(AppTheme.Typography.title)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    if let sub = question.subtitle {
                        Text(sub)
                            .font(AppTheme.Typography.callout)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
                .padding(.top, AppTheme.Spacing.md)

                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(question.options) { opt in
                        QuizOptionButton(
                            option: opt,
                            isSelected: selected == opt.value
                        ) {
                            coordinator.answer(questionIndex: questionIndex, answer: opt.value)
                        }
                    }
                }
            }
        }
    }
}
