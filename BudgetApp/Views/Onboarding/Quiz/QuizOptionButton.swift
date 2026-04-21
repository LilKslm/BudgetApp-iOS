import SwiftUI

struct QuizOptionButton: View {
    let option: QuizOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                if let emoji = option.emoji {
                    VStack(spacing: 2) {
                        Text(emoji)
                            .font(Font.custom("AppleColorEmoji", size: 22))
                        Text(emojiDebug(emoji))
                            .font(.system(size: 8))
                            .foregroundStyle(.red)
                    }
                    .frame(width: 56, alignment: .center)
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

    // Temporary diagnostic — prints the codepoint(s) in hex. If the red text
    // shows the right hex (e.g. "1F60C") but the emoji still renders as tofu,
    // the string is correct and the problem is font-side.
    private func emojiDebug(_ s: String) -> String {
        s.unicodeScalars.map { String($0.value, radix: 16, uppercase: true) }
            .joined(separator: " ")
    }
}
