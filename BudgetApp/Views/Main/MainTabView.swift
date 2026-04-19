import SwiftUI

enum MainTab: Hashable {
    case home, budgets, transactions, goals, profile
}

struct MainTabView: View {
    @State private var selection: MainTab = .home

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tag(MainTab.home)
                .tabItem { Label("Home", systemImage: "house.fill") }

            BudgetsListView()
                .tag(MainTab.budgets)
                .tabItem { Label("Budgets", systemImage: "chart.pie.fill") }

            TransactionsListView()
                .tag(MainTab.transactions)
                .tabItem { Label("Transactions", systemImage: "list.bullet.rectangle.fill") }

            GoalsListView()
                .tag(MainTab.goals)
                .tabItem { Label("Goals", systemImage: "target") }

            ProfileView()
                .tag(MainTab.profile)
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
        .tint(AppTheme.Colors.accent)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel())
        .environment(\.appContainer, AppContainer.shared)
}
