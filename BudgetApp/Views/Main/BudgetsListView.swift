import SwiftUI

struct BudgetsListView: View {
    @Environment(\.appContainer) private var container
    @State private var budgets: [Budget] = []
    @State private var loading = true

    private let mockUid = "mock-user"

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    LoadingView(message: "Loading budgets…")
                } else if budgets.isEmpty {
                    EmptyStateView(
                        icon: "chart.pie",
                        title: "No budgets yet",
                        message: "Create your first budget to start tracking category spending.",
                        actionTitle: "Create budget",
                        action: {}
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppTheme.Spacing.md) {
                            ForEach(budgets) { budget in
                                BudgetCard(budget: budget)
                            }
                        }
                        .padding(AppTheme.Spacing.lg)
                    }
                    .background(AppTheme.Colors.background)
                }
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Phase 4 wires creation flow
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await load()
            }
        }
    }

    private func load() async {
        do {
            budgets = try await container.budgets.fetchBudgets(for: mockUid)
        } catch {
            AppLogger.error("BudgetsListView load failed: \(error.localizedDescription)")
        }
        loading = false
    }
}

private struct BudgetCard: View {
    let budget: Budget

    var body: some View {
        GradientCard(gradient: AppTheme.Gradients.primary) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text(budget.name)
                    .font(AppTheme.Typography.headline)
                Text(budget.totalBudgeted, format: .currency(code: "USD"))
                    .font(AppTheme.Typography.heroNumber)
                Text("\(budget.allocations.count) categories")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
    }
}

#Preview {
    BudgetsListView()
        .environment(\.appContainer, AppContainer.shared)
}
