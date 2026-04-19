import SwiftUI

/// Hero card surface used on Home, Budget Detail, and Goal Detail.
/// Uses AppTheme.Gradients.primary per appcreation.md §5 rule: accent surfaces use the brand gradient, not Colors.accent.
struct GradientCard<Content: View>: View {
    let content: () -> Content
    let gradient: LinearGradient

    init(
        gradient: LinearGradient = AppTheme.Gradients.primary,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.gradient = gradient
        self.content = content
    }

    var body: some View {
        content()
            .padding(AppTheme.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(gradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous))
            .themeShadow(AppTheme.Shadow.card)
    }
}

/// Standard surface card — lower emphasis than GradientCard.
struct SurfaceCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(AppTheme.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
            .themeShadow(AppTheme.Shadow.card)
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.md) {
        GradientCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Working balance")
                    .font(AppTheme.Typography.caption)
                Text("$2,870.00")
                    .font(AppTheme.Typography.heroNumber)
            }
        }

        SurfaceCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("This month")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text("$1,342.18 spent")
                    .font(AppTheme.Typography.largeNumber)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }
        }
    }
    .padding()
    .background(AppTheme.Colors.background)
}
