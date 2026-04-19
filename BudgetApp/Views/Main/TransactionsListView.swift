import SwiftUI

struct TransactionsListView: View {
    @Environment(\.appContainer) private var container
    @State private var transactions: [Transaction] = []
    @State private var loading = true

    private let mockUid = "mock-user"

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    LoadingView(message: "Loading transactions…")
                } else if transactions.isEmpty {
                    EmptyStateView(
                        icon: "list.bullet.rectangle",
                        title: "No transactions",
                        message: "Add your first transaction to see spending insights.",
                        actionTitle: "Add transaction",
                        action: {}
                    )
                } else {
                    List {
                        ForEach(groupedByDay, id: \.0) { (day, txns) in
                            Section(header: Text(day).font(AppTheme.Typography.captionBold).foregroundStyle(AppTheme.Colors.textSecondary)) {
                                ForEach(txns) { txn in
                                    TransactionListRow(transaction: txn)
                                        .listRowBackground(AppTheme.Colors.surface)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(AppTheme.Colors.background)
                }
            }
            .navigationTitle("Transactions")
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

    private var groupedByDay: [(String, [Transaction])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let grouped = Dictionary(grouping: transactions) { formatter.string(from: $0.date) }
        return grouped.sorted { $0.key > $1.key }
    }

    private func load() async {
        do {
            transactions = try await container.transactions.fetchTransactions(for: mockUid)
        } catch {
            AppLogger.error("TransactionsListView load failed: \(error.localizedDescription)")
        }
        loading = false
    }
}

private struct TransactionListRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                .fill(transaction.category.tint)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: transaction.category.sfSymbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.merchant)
                    .font(AppTheme.Typography.callout.weight(.semibold))
                Text(transaction.category.displayName)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            Spacer()

            Text(transaction.amount, format: .currency(code: "USD"))
                .font(AppTheme.Typography.callout.weight(.semibold))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TransactionsListView()
        .environment(\.appContainer, AppContainer.shared)
}
