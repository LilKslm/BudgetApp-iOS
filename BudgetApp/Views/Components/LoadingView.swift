import SwiftUI

struct LoadingView: View {
    var message: String?

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ProgressView()
                .tint(AppTheme.Colors.accent)
            if let message {
                Text(message)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
    }
}

#Preview {
    LoadingView(message: "Loading…")
}
