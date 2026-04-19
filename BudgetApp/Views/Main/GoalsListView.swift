import SwiftUI

struct GoalsListView: View {
    @Environment(\.appContainer) private var container
    @State private var savings: [SavingsGoal] = []
    @State private var debts: [Debt] = []
    @State private var loading = true

    private let mockUid = "mock-user"

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    LoadingView(message: "Loading goals…")
                } else if savings.isEmpty && debts.isEmpty {
                    EmptyStateView(
                        icon: "target",
                        title: "No goals yet",
                        message: "Create a savings goal or add a debt to start making progress.",
                        actionTitle: "Create goal",
                        action: {}
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                            if !savings.isEmpty {
                                sectionHeader("Saving for")
                                ForEach(savings) { goal in
                                    SavingsGoalCard(goal: goal)
                                }
                            }
                            if !debts.isEmpty {
                                sectionHeader("Paying off")
                                ForEach(debts) { debt in
                                    DebtCard(debt: debt)
                                }
                            }
                        }
                        .padding(AppTheme.Spacing.lg)
                    }
                    .background(AppTheme.Colors.background)
                }
            }
            .navigationTitle("Goals")
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

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(AppTheme.Typography.headline)
            .foregroundStyle(AppTheme.Colors.textPrimary)
    }

    private func load() async {
        do {
            async let savingsTask = container.goals.fetchSavingsGoals(for: mockUid)
            async let debtsTask = container.goals.fetchDebts(for: mockUid)
            savings = try await savingsTask
            debts = try await debtsTask
        } catch {
            AppLogger.error("GoalsListView load failed: \(error.localizedDescription)")
        }
        loading = false
    }
}

private struct SavingsGoalCard: View {
    let goal: SavingsGoal

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                HStack {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                        .fill(AppTheme.Gradients.primarySoft)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Image(systemName: goal.theme.sfSymbol)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(AppTheme.Colors.accentDeep)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(goal.name)
                            .font(AppTheme.Typography.headline)
                        Text("\(Int(goal.progress * 100))% complete")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Text(goal.currentAmount, format: .currency(code: "USD"))
                        .font(AppTheme.Typography.callout.weight(.semibold))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AppTheme.Colors.surfaceMuted)
                        Capsule()
                            .fill(AppTheme.Gradients.primary)
                            .frame(width: max(0, geo.size.width * goal.progress))
                    }
                }
                .frame(height: 8)
            }
        }
    }
}

private struct DebtCard: View {
    let debt: Debt

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                HStack {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                        .fill(AppTheme.Colors.cardPeach)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Image(systemName: debt.theme.sfSymbol)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(debt.name)
                            .font(AppTheme.Typography.headline)
                        Text("\(Int(debt.progress * 100))% paid off")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Text(debt.currentBalance, format: .currency(code: "USD"))
                        .font(AppTheme.Typography.callout.weight(.semibold))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AppTheme.Colors.surfaceMuted)
                        Capsule()
                            .fill(AppTheme.Gradients.primary)
                            .frame(width: max(0, geo.size.width * debt.progress))
                    }
                }
                .frame(height: 8)
            }
        }
    }
}

#Preview {
    GoalsListView()
        .environment(\.appContainer, AppContainer.shared)
}
