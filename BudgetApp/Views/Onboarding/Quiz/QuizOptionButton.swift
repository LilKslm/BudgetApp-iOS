import SwiftUI

struct QuizOptionButton: View {
    let option: QuizOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                if let emoji = option.emoji {
                    Text(emoji)
                        .font(.title2)
                        .frame(width: 40, alignment: .center)
                }

                Text(option.label)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.accent)
                        .font(.system(size: 20))
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .fill(AppTheme.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .stroke(
                                isSelected ? AppTheme.Colors.accent : AppTheme.Colors.divider,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .animation(AppTheme.Motion.quick, value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
