import SwiftUI

struct ReviewsView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var currentIndex = 0

    // TODO: Replace with real App Store reviews before launch (Phase 6).
    private let reviews: [(name: String, location: String, quote: String)] = [
        (
            name: "Sarah M.",
            location: "Chicago, IL",
            quote: "I tried four budgeting apps before this one. BudgetApp is the first one I've actually stuck with past week one. The goal animations make saving feel real."
        ),
        (
            name: "Jordan T.",
            location: "Austin, TX",
            quote: "My partner and I used to argue about money every month. Shared budgets changed everything — we're both looking at the same numbers now."
        ),
        (
            name: "Priya K.",
            location: "New York, NY",
            quote: "I didn't realize I was spending $340 a month on subscriptions until BudgetApp flagged it. Cancelled six and paid off my credit card in three months."
        )
    ]

    var body: some View {
        OnboardingScaffold(progress: coordinator.progress) {
            VStack(spacing: AppTheme.Spacing.xl) {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text("People love it.")
                        .font(AppTheme.Typography.title)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.top, AppTheme.Spacing.sm)

                    Text("Don't take our word for it.")
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }

                TabView(selection: $currentIndex) {
                    ForEach(Array(reviews.enumerated()), id: \.offset) { i, review in
                        ReviewCard(review: review)
                            .tag(i)
                            .padding(.horizontal, 4)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 220)
                .animation(AppTheme.Motion.standard, value: currentIndex)

                HStack(spacing: 6) {
                    ForEach(0..<reviews.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentIndex ? AppTheme.Colors.accent : AppTheme.Colors.divider)
                            .frame(width: i == currentIndex ? 20 : 6, height: 6)
                            .animation(AppTheme.Motion.quick, value: currentIndex)
                    }
                }
            }
        } footer: {
            PrimaryButton("Continue") {
                coordinator.advance()
            }
        }
    }
}

private struct ReviewCard: View {
    let review: (name: String, location: String, quote: String)

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundStyle(AppTheme.Colors.warning)
                        .font(.system(size: 14))
                }
            }

            Text("\"\(review.quote)\"")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .lineLimit(5)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text(review.name)
                    .font(AppTheme.Typography.captionBold)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text(review.location)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
        .themeShadow(AppTheme.Shadow.card)
    }
}
