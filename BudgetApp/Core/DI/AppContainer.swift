import Foundation

/// Central dependency container. Phase 1 wires mocks; Phase 3 swaps in real services.
/// Tests construct their own container with custom mocks.
@MainActor
final class AppContainer {
    static let shared = AppContainer()

    let auth: AuthServiceProtocol
    let data: DataServiceProtocol
    let analytics: AnalyticsServiceProtocol
    let payments: PaymentServiceProtocol
    let budgets: BudgetServiceProtocol
    let transactions: TransactionServiceProtocol
    let subscriptions: SubscriptionServiceProtocol
    let goals: GoalServiceProtocol
    let sharing: SharingServiceProtocol
    let haptics: HapticServiceProtocol

    init(
        auth: AuthServiceProtocol = MockAuthService(),
        data: DataServiceProtocol = MockDataService(),
        analytics: AnalyticsServiceProtocol = MockAnalyticsService(),
        payments: PaymentServiceProtocol = MockPaymentService(),
        budgets: BudgetServiceProtocol = MockBudgetService(),
        transactions: TransactionServiceProtocol = MockTransactionService(),
        subscriptions: SubscriptionServiceProtocol = MockSubscriptionService(),
        goals: GoalServiceProtocol = MockGoalService(),
        sharing: SharingServiceProtocol = MockSharingService(),
        haptics: HapticServiceProtocol = HapticService()
    ) {
        self.auth = auth
        self.data = data
        self.analytics = analytics
        self.payments = payments
        self.budgets = budgets
        self.transactions = transactions
        self.subscriptions = subscriptions
        self.goals = goals
        self.sharing = sharing
        self.haptics = haptics
    }
}
