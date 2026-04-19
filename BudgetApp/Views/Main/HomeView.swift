import SwiftUI

struct HomeView: View {
    @Environment(\.appContainer) private var container
    @State private var budgets: [Budget] = []
    @State private var transactions: [Transaction] = []
    @State private var goals: [SavingsGoal] = []
    @State private var subscriptions: [Subscription] = []

    private let mockUid = "mock-user"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    heroBalance
                    goalsPreview
                    subscriptionsPreview
                    recentTransactions
                }
                .padding(AppTheme.Spacing.lg)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await loadData()
            }
        }
    }

    // MARK: - Sections

    private var heroBalance: some View {
        GradientCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("This month")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.white.opacity(0.8))
                Text(totalSpent, format: .currency(code: "USD"))
                    .font(AppTheme.Typography.heroNumber)
                Text(spentVsBudgetedCopy)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }

    private var goalsPreview: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Savings goals")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            if goals.isEmpty {
                EmptyInlineCard(
                    title: "Start your first goal",
                    message: "Pick a theme and watch it come to life."
                )
            } else {
                ForEach(goals) { goal in
                    GoalPreviewRow(goal: goal)
                }
            }
        }
    }

    private var subscriptionsPreview: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Subscriptions")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text(totalMonthlySubs, format: .currency(code: "USD"))
                    .font(AppTheme.Typography.largeNumber)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("\(subscriptions.count) active • normalized monthly")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
    }

    private var recentTransactions: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Recent")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            ForEach(transactions.prefix(5)) { txn in
                TransactionRow(transaction: txn)
            }
        }
    }

    // MARK: - Data

    private func loadData() async {
        do {
            async let budgetsTask = container.budgets.fetchBudgets(for: mockUid)
            async let txnsTask = container.transactions.fetchTransactions(for: mockUid)
            async let goalsTask = container.goals.fetchSavingsGoals(for: mockUid)
            async let subsTask = container.subscriptions.fetchSubscriptions(for: mockUid)
            budgets = try await budgetsTask
            transactions = try await txnsTask
            goals = try await goalsTask
            subscriptions = try await subsTask
        } catch {
            AppLogger.error("HomeView load failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Derived

    private var totalSpent: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }

    private var totalBudgeted: Double {
        budgets.reduce(0) { $0 + $1.totalBudgeted }
    }

    private var totalMonthlySubs: Double {
        container.subscriptions.totalMonthlySpend(subscriptions)
    }

    private var spentVsBudgetedCopy: String {
        guard totalBudgeted > 0 else { return "No budget yet" }
        let remaining = max(totalBudgeted - totalSpent, 0)
        return "\(remaining.formatted(.currency(code: "USD"))) left of \(totalBudgeted.formatted(.currency(code: "USD")))"
    }
}

// MARK: - Inline subviews

private struct GoalPreviewRow: View {
    let goal: SavingsGoal

    var body: some View {
        SurfaceCard {
            HStack(spacing: AppTheme.Spacing.md) {
                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                    .fill(AppTheme.Gradients.primarySoft)
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: goal.theme.sfSymbol)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.accentDeep)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    ProgressBar(progress: goal.progress)
                    Text("\(goal.currentAmount.formatted(.currency(code: "USD"))) of \(goal.targetAmount.formatted(.currency(code: "USD")))")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
        }
    }
}

private struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(AppTheme.Colors.surfaceMuted)
                Capsule()
                    .fill(AppTheme.Gradients.primary)
                    .frame(width: max(0, geo.size.width * progress))
            }
        }
        .frame(height: 6)
    }
}

private struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                .fill(transaction.category.tint)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: transaction.category.sfSymbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.merchant)
                    .font(AppTheme.Typography.callout.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text(transaction.category.displayName)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            Spacer()

            Text(transaction.amount, format: .currency(code: "USD"))
                .font(AppTheme.Typography.callout.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }
}

private struct EmptyInlineCard: View {
    let title: String
    let message: String

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text(message)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(\.appContainer, AppContainer.shared)
}
