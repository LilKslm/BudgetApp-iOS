import SwiftUI

/// Shared chrome for every onboarding screen: background, progress bar, optional back button,
/// scrollable content, and a pinned footer (usually the primary action button).
struct OnboardingScaffold<Content: View, Footer: View>: View {
    let progress: Double
    let allowsBack: Bool
    let onBack: (() -> Void)?
    @ViewBuilder let content: () -> Content
    @ViewBuilder let footer: () -> Footer

    init(
        progress: Double,
        allowsBack: Bool = false,
        onBack: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.progress = progress
        self.allowsBack = allowsBack
        self.onBack = onBack
        self.content = content
        self.footer = footer
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.Gradients.backgroundWash.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: AppTheme.Spacing.md) {
                    if allowsBack {
                        Button(action: { onBack?() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                .frame(width: 36, height: 36)
                        }
                    } else {
                        Spacer().frame(width: 36)
                    }

                    MoneyBillProgressView(progress: progress)

                    Spacer().frame(width: 36)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.bottom, AppTheme.Spacing.md)

                ScrollView {
                    content()
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.bottom, AppTheme.Spacing.md)
                }

                footer()
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.sm)
                    .padding(.bottom, AppTheme.Spacing.sm)
            }
        }
        .navigationBarHidden(true)
    }
}

extension OnboardingScaffold where Footer == EmptyView {
    init(
        progress: Double,
        allowsBack: Bool = false,
        onBack: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            progress: progress,
            allowsBack: allowsBack,
            onBack: onBack,
            content: content,
            footer: { EmptyView() }
        )
    }
}
