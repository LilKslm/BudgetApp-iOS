import SwiftUI

struct NotificationPromptView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @Environment(\.appContainer) private var container
    @State private var isRequesting = false

    private let reasons = [
        ("flag.fill", "Goal milestones — celebrate every win"),
        ("bell.badge.fill", "Bill reminders — never miss a due date"),
        ("arrow.triangle.2.circlepath", "Shared budget updates — stay in sync")
    ]

    var body: some View {
        OnboardingScaffold(progress: coordinator.progress) {
            VStack(spacing: AppTheme.Spacing.xl) {
                VStack(spacing: AppTheme.Spacing.md) {
                    Circle()
                        .fill(AppTheme.Gradients.primary)
                        .frame(width: 88, height: 88)
                        .overlay(
                            Image(systemName: "bell.fill")
                                .font(.system(size: 38, weight: .semibold))
                                .foregroundStyle(.white)
                        )
                        .themeShadow(AppTheme.Shadow.raised)
                        .padding(.top, AppTheme.Spacing.sm)

                    Text("Never miss a milestone.")
                        .font(AppTheme.Typography.title)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Turn on notifications so we can celebrate your wins with you.")
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(reasons, id: \.0) { icon, text in
                        HStack(spacing: AppTheme.Spacing.md) {
                            Image(systemName: icon)
                                .foregroundStyle(AppTheme.Colors.accent)
                                .font(.system(size: 16))
                                .frame(width: 24)
                            Text(text)
                                .font(AppTheme.Typography.body)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                            Spacer()
                        }
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            }
        } footer: {
            VStack(spacing: AppTheme.Spacing.sm) {
                PrimaryButton(isRequesting ? "Turning on..." : "Turn on notifications", isLoading: isRequesting) {
                    Task { await requestPermission(granted: true) }
                }

                Button("Not now") {
                    Task { await requestPermission(granted: false) }
                }
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
    }

    private func requestPermission(granted: Bool) async {
        isRequesting = true
        defer { isRequesting = false }
        if granted {
            _ = await container.notifications.requestPermission()
        }
        coordinator.notificationDecision = granted
        container.analytics.track(.onboardingNotificationDecision(granted: granted))
        container.haptics.impact(.light)
        coordinator.advance()
    }
}
