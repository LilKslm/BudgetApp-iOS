import SwiftUI

struct PaywallView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.appContainer) private var container

    @State private var packages: [PaywallPackage] = []
    @State private var isLoading = false
    @State private var isPurchasing = false
    @State private var purchaseError: AppError?

    private var variant: PaywallVariant {
        coordinator.showingDiscountedPaywall ? .discounted : .standard
    }

    var body: some View {
        ZStack {
            AppTheme.Gradients.backgroundWash.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Progress bar (no back button on paywall)
                    HStack {
                        Spacer().frame(width: 36)
                        OnboardingProgressBar(progress: coordinator.progress)
                        Spacer().frame(width: 36)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.sm)

                    // Hero
                    heroSection

                    // Feature bullets
                    featureBulletsSection

                    // Packages
                    if isLoading {
                        ProgressView()
                            .padding(.vertical, AppTheme.Spacing.xl)
                    } else {
                        packagesSection
                    }

                    // Error
                    if let error = purchaseError {
                        Text(error.errorDescription ?? "Purchase failed.")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.danger)
                            .multilineTextAlignment(.center)
                    }

                    // Footer
                    footerSection
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }

            // Purchase loading overlay
            if isPurchasing {
                Color.black.opacity(0.35).ignoresSafeArea()
                VStack(spacing: AppTheme.Spacing.md) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.4)
                    Text("Processing…")
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(.white)
                }
            }
        }
        .navigationBarHidden(true)
        // Re-run when variant switches to discounted so the new package list loads.
        .task(id: coordinator.showingDiscountedPaywall) { await loadPackages() }
    }

    // MARK: - Sections

    private var heroSection: some View {
        GradientCard {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)

                Text(coordinator.showingDiscountedPaywall ? "One-time offer: 50% off" : "Unlock BudgetApp Pro")
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(coordinator.showingDiscountedPaywall
                     ? "This offer is only available right now."
                     : "Everything you need to take control of your money.")
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
    }

    private var featureBulletsSection: some View {
        let bullets: [(String, String)] = [
            ("infinity", "Unlimited budgets & goals"),
            ("person.2.fill", "Shared budgets with a partner"),
            ("chart.pie.fill", "Full spending breakdown"),
            ("bell.badge.fill", "Goal milestone alerts"),
            ("creditcard.fill", "Subscription tracker"),
            ("arrow.triangle.2.circlepath", "Bank linking (coming soon)")
        ]
        return VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            ForEach(bullets, id: \.0) { icon, label in
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: icon)
                        .foregroundStyle(AppTheme.Colors.accent)
                        .font(.system(size: 15))
                        .frame(width: 22)
                    Text(label)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundStyle(AppTheme.Colors.success)
                        .font(.system(size: 13, weight: .semibold))
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
    }

    private var packagesSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ForEach(packages) { pkg in
                PackageCard(package: pkg) {
                    Task { await purchase(pkg) }
                }
            }
        }
    }

    private var footerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            if !coordinator.showingDiscountedPaywall {
                Button("Not now") {
                    coordinator.declineFirstPaywall()
                    container.analytics.track(.paywallDismissed)
                }
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textSecondary)
            } else {
                Text("This offer won't appear again.")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }

            Button("Restore Purchases") {
                Task { await restore() }
            }
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.textTertiary)

            Text("Cancel anytime. Billed through the App Store.")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Actions

    private func loadPackages() async {
        isLoading = true
        defer { isLoading = false }
        do {
            packages = try await container.payments.fetchOfferings(variant: variant)
        } catch {
            purchaseError = .unknown(error.localizedDescription)
        }
    }

    private func purchase(_ pkg: PaywallPackage) async {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }
        container.analytics.track(.paywallPurchaseTapped(productId: pkg.productId))
        do {
            try await container.payments.purchase(packageId: pkg.id)
            container.analytics.track(.paywallPurchaseCompleted(productId: pkg.productId))
            coordinator.completePurchase()
            container.haptics.success()
            appViewModel.completeOnboarding()
        } catch let e as AppError {
            purchaseError = e
        } catch {
            purchaseError = .purchaseFailed(error.localizedDescription)
        }
    }

    private func restore() async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await container.payments.restorePurchases()
            container.analytics.track(.paywallRestored)
            coordinator.completePurchase()
            appViewModel.completeOnboarding()
        } catch {
            purchaseError = .restoreFailed
        }
    }
}

// MARK: - Package card

private struct PackageCard: View {
    let package: PaywallPackage
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text(package.title)
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        if package.isBestValue {
                            Text("BEST VALUE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.Colors.accent)
                                .clipShape(Capsule())
                        }
                    }
                    if let trial = package.trialDisplay {
                        Text(trial)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.success)
                    }
                    Text(package.cadence)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(package.priceDisplay)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(package.isBestValue ? AppTheme.Colors.accent : AppTheme.Colors.divider,
                            lineWidth: package.isBestValue ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
