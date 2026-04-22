import Foundation

/// Central dependency container. Phase 1 wires mocks; Phase 3 swaps in real services.
/// Tests construct their own container with custom mocks via the explicit init.
@MainActor
final class AppContainer {
    static let shared = AppContainer.makeDefault()

    let auth: AuthServiceProtocol
    let users: UserServiceProtocol
    let data: DataServiceProtocol
    let analytics: AnalyticsServiceProtocol
    let payments: PaymentServiceProtocol
    let budgets: BudgetServiceProtocol
    let transactions: TransactionServiceProtocol
    let subscriptions: SubscriptionServiceProtocol
    let goals: GoalServiceProtocol
    let sharing: SharingServiceProtocol
    let haptics: HapticServiceProtocol
    let notifications: NotificationServiceProtocol

    init(
        auth: AuthServiceProtocol = MockAuthService(),
        users: UserServiceProtocol = MockUserService(),
        data: DataServiceProtocol = MockDataService(),
        analytics: AnalyticsServiceProtocol = MockAnalyticsService(),
        payments: PaymentServiceProtocol = MockPaymentService(),
        budgets: BudgetServiceProtocol = MockBudgetService(),
        transactions: TransactionServiceProtocol = MockTransactionService(),
        subscriptions: SubscriptionServiceProtocol = MockSubscriptionService(),
        goals: GoalServiceProtocol = MockGoalService(),
        sharing: SharingServiceProtocol = MockSharingService(),
        haptics: HapticServiceProtocol = HapticService(),
        notifications: NotificationServiceProtocol = MockNotificationService()
    ) {
        self.auth = auth
        self.users = users
        self.data = data
        self.analytics = analytics
        self.payments = payments
        self.budgets = budgets
        self.transactions = transactions
        self.subscriptions = subscriptions
        self.goals = goals
        self.sharing = sharing
        self.haptics = haptics
        self.notifications = notifications
    }

    /// Returns the container the app launches with. DEBUG builds default to mocks so
    /// previews/tests/sim-dev-loops stay hermetic; release builds wire real services.
    /// Launch arg `-firebaseLive` forces a DEBUG build to use real services.
    ///
    /// Real service wiring lands per Phase 3 sub-phase:
    ///   3b — FirebaseAuthService + FirestoreUserService
    ///   3c — FirestoreDataService + FirebaseAnalyticsService + CrashlyticsService
    ///   3d — RevenueCatPaymentService
    /// Until each sub-phase lands, the release branch falls back to mocks so the
    /// app stays buildable and launchable between commits.
    static func makeDefault() -> AppContainer {
        if AppEnvironment.shouldUseMockServices {
            return AppContainer()
        }
        // 3b: real auth + user document storage
        let auth = FirebaseAuthService()
        let users = FirestoreUserService()
        // 3c: real data + analytics (Crashlytics wired via CrashlyticsService.shared in AppError.wrap)
        let data = FirestoreDataService()
        let analytics = FirebaseAnalyticsService()
        // 3d: RevenueCat payments
        let payments = RevenueCatPaymentService()
        return AppContainer(auth: auth, users: users, data: data, analytics: analytics, payments: payments)
    }
}
