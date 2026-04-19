import SwiftUI

struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    init(_ title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(.white)
            .background(AppTheme.Gradients.primary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            .themeShadow(AppTheme.Shadow.card)
        }
        .disabled(isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .background(AppTheme.Colors.surfaceMuted)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        }
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.md) {
        PrimaryButton("Continue") {}
        PrimaryButton("Loading", isLoading: true) {}
        SecondaryButton(title: "Skip") {}
    }
    .padding()
    .background(AppTheme.Colors.background)
}
