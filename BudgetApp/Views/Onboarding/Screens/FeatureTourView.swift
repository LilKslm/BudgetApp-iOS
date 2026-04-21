import SwiftUI

struct FeatureTourView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var currentPage = 0

    private let pages: [(icon: String, gradient: AnyShapeStyle, title: String, subtitle: String, mockContent: AnyView)] = [
        (
            icon: "arrow.left.arrow.right",
            gradient: AnyShapeStyle(AppTheme.Gradients.primary),
            title: "Track every transaction",
            subtitle: "Two taps. Any category. Done.",
            mockContent: AnyView(TransactionsMockPreview())
        ),
        (
            icon: "chart.pie.fill",
            gradient: AnyShapeStyle(AppTheme.Gradients.primarySoft),
            title: "Budgets that breathe",
            subtitle: "Monthly, per-label, or event-based. Switch on the fly.",
            mockContent: AnyView(BudgetMockPreview())
        ),
        (
            icon: "trophy.fill",
            gradient: AnyShapeStyle(LinearGradient(
                colors: [Color(hex: 0x10B981), Color(hex: 0x059669)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )),
            title: "Goals that feel like a game",
            subtitle: "Watch your savings build visually. Every dollar moves the picture.",
            mockContent: AnyView(GoalMockPreview())
        ),
        (
            icon: "person.2.fill",
            gradient: AnyShapeStyle(LinearGradient(
                colors: [Color(hex: 0x6366F1), Color(hex: 0x8B5CF6)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )),
            title: "Shared budgets",
            subtitle: "Invite a partner. Track together. No more guessing.",
            mockContent: AnyView(SharedMockPreview())
        )
    ]

    var body: some View {
        OnboardingScaffold(progress: coordinator.progress) {
            VStack(spacing: AppTheme.Spacing.lg) {
                Text("What's waiting for you")
                    .font(AppTheme.Typography.title)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top, AppTheme.Spacing.sm)

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { i, page in
                        FeatureTourPage(
                            icon: page.icon,
                            gradient: page.gradient,
                            title: page.title,
                            subtitle: page.subtitle,
                            mockContent: page.mockContent
                        )
                        .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 340)
                .animation(AppTheme.Motion.standard, value: currentPage)

                HStack(spacing: 6) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? AppTheme.Colors.accent : AppTheme.Colors.divider)
                            .frame(width: i == currentPage ? 20 : 6, height: 6)
                            .animation(AppTheme.Motion.quick, value: currentPage)
                    }
                }
            }
        } footer: {
            if currentPage < pages.count - 1 {
                PrimaryButton("Next") {
                    withAnimation(AppTheme.Motion.standard) { currentPage += 1 }
                }
            } else {
                PrimaryButton("Let's go") {
                    coordinator.advance()
                }
            }
        }
    }
}

private struct FeatureTourPage: View {
    let icon: String
    let gradient: AnyShapeStyle
    let title: String
    let subtitle: String
    let mockContent: AnyView

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                    .fill(gradient)
                    .frame(height: 180)
                mockContent
                    .allowsHitTesting(false)
            }

            Text(title)
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text(subtitle)
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Mock previews (pure SwiftUI, no images)

private struct TransactionsMockPreview: View {
    private let items = [
        ("cart.fill", "Groceries", "-$84.50", Color.green),
        ("cup.and.saucer.fill", "Coffee", "-$6.80", Color.orange),
        ("laptopcomputer", "Software", "-$12.99", Color.blue)
    ]
    var body: some View {
        VStack(spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack {
                    Image(systemName: item.0).foregroundStyle(item.3).frame(width: 24)
                    Text(item.1).foregroundStyle(.white).font(.caption)
                    Spacer()
                    Text(item.2).foregroundStyle(.white.opacity(0.85)).font(.caption)
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct BudgetMockPreview: View {
    private let categories = [("Groceries", 0.6), ("Dining", 0.85), ("Transport", 0.4)]
    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(categories.enumerated()), id: \.offset) { _, cat in
                VStack(alignment: .leading, spacing: 3) {
                    Text(cat.0).font(.caption2).foregroundStyle(.white.opacity(0.85))
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.2)).frame(height: 6)
                            Capsule().fill(.white).frame(width: geo.size.width * cat.1, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

private struct GoalMockPreview: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "car.fill")
                .font(.system(size: 36))
                .foregroundStyle(.white)
            Text("New Car — 62%")
                .font(.caption.bold())
                .foregroundStyle(.white)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.2)).frame(height: 8)
                    Capsule().fill(.white).frame(width: geo.size.width * 0.62, height: 8)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 30)
        }
    }
}

private struct SharedMockPreview: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: -8) {
                ForEach(["K", "A"], id: \.self) { initial in
                    Circle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 36, height: 36)
                        .overlay(Text(initial).font(.caption.bold()).foregroundStyle(.white))
                }
            }
            Text("Household Budget")
                .font(.caption.bold())
                .foregroundStyle(.white)
            Text("2 contributors · $3,200 / $4,000")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}
