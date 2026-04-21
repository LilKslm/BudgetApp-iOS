import SwiftUI

/// Shared chrome for every onboarding screen: background, progress bar, optional back button, scrollable content.
struct OnboardingScaffold<Content: View>: View {
    let progress: Double
    let allowsBack: Bool
    let onBack: (() -> Void)?
    @ViewBuilder let content: () -> Content

    init(
        progress: Double,
        allowsBack: Bool = false,
        onBack: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.progress = progress
        self.allowsBack = allowsBack
        self.onBack = onBack
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.Gradients.backgroundWash.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header row: back + progress
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

                    OnboardingProgressBar(progress: progress)

                    Spacer().frame(width: 36)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.bottom, AppTheme.Spacing.md)

                ScrollView {
                    content()
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
