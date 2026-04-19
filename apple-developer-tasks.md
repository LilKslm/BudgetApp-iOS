# Apple Developer Enrollment — Deferred Tasks (BudgetApp)

Everything here is **blocked until Apple Developer Program enrollment completes**. When that lands, work through this list top-to-bottom. Do **not** scatter these TODOs into `features.md` or code comments — this file is the single source of truth.

Each item is formatted as:
- **What it unlocks** — the user-facing capability that lights up.
- **Blocked because** — the specific Developer-account requirement.
- **Files / keys to touch when ready** — exact entry points so a future agent can execute without re-deriving the plan.

---

## 1. App Store Connect — create Pro subscription products

- **What it unlocks:** real monthly + yearly purchases in `PaywallView`. Replaces the current `#if DEBUG` "Skip Paywall" button.
- **Blocked because:** subscription products can only be created in App Store Connect, which requires a paid Developer account.
- **Files / keys to touch when ready:**
  - App Store Connect: create two auto-renewing subscriptions (`budgetapp.pro.monthly`, `budgetapp.pro.yearly`) in a subscription group named `BudgetApp Pro`. Attach to entitlement `pro`. Mark yearly as "best value" with a 7-day free trial.
  - (Optional) add a `.storekit` configuration file to the Xcode scheme for local simulator testing.

## 2. RevenueCat — swap test API key for live key

- **What it unlocks:** real RevenueCat offerings load in `PaywallView` and real purchases flow through `PaymentService.purchase(package:)`.
- **Blocked because:** live key requires App Store Connect products (item 1) wired to a RevenueCat offering.
- **Files / keys to touch when ready:**
  - Replace the test key in the `Purchases.configure(withAPIKey:)` call inside [BudgetApp/App/AppDelegate.swift](BudgetApp/App/AppDelegate.swift).
  - RevenueCat dashboard: attach both products to entitlement `pro`; mark yearly as "best value".
  - Remove the `#if DEBUG Skip Paywall` button in [BudgetApp/Views/Paywall/PaywallView.swift](BudgetApp/Views/Paywall/PaywallView.swift) once purchases work end-to-end.

## 3. Plaid integration — bank linking + auto-subscription detection *(biggest deferred item)*

- **What it unlocks:**
  - Secure bank/credit-card account linking (Monarch/Copilot-style) via OAuth — users never type credentials into BudgetApp.
  - Automatic transaction import + categorization.
  - Automatic recurring-charge detection → populates the Subscriptions screen without manual entry.
  - The net-worth dashboard (asset balances pulled live from linked accounts).
- **Blocked because:**
  - Plaid production access requires underwriting review (1–2 weeks) against a registered company/LLC.
  - Plaid Link SDK needs the app signed with a production cert (requires Apple Developer enrollment).
  - We need a **Firebase Cloud Functions backend** to hold the Plaid secret key and perform `/item/public_token/exchange` server-side — the secret must never ship in the client.
  - Paid Plaid plan (~$0.30/active-item/month) after the free dev tier.
- **Files / keys to touch when ready:**
  - Plaid Dashboard: register app, complete underwriting, generate production client ID + secret. Store secret in Firebase Functions config.
  - New Firebase Functions project: `functions/src/plaid/exchangeToken.ts`, `functions/src/plaid/syncTransactions.ts`, `functions/src/plaid/webhook.ts`.
  - `Podfile`: add `pod 'Plaid'`.
  - New `PlaidService.swift` (client) wrapping the Plaid iOS SDK.
  - New `BankLinkingView.swift` — launches `PLKPlaidLink`, passes public token to Functions for exchange.
  - Firestore: add `users/{uid}/plaidItems/{itemId}` subcollection (stores item ID + institution metadata — **never** the access token on the client).
  - Firestore: add `users/{uid}/accounts/{accountId}` subcollection (balances, mask, type).
  - `TransactionsView`: add a "linked" badge to imported transactions vs. manual ones.
  - `SubscriptionsView`: consume Plaid recurring-transactions endpoint, dedupe against manually-entered subs.
  - Update `firestore.rules` to lock `plaidItems/**` and `accounts/**` to `request.auth.uid == uid`. Republish.
  - Pro-gate the bank-linking entry point (`PaymentService.isPremium` check).

## 4. TestFlight distribution

- **What it unlocks:** shipping internal/external builds to beta testers. Pre-App-Store QA loop.
- **Blocked because:** TestFlight requires an App Store Connect listing, which requires enrollment.
- **Files / keys to touch when ready:**
  - App Store Connect: create the app record with the final bundle ID.
  - Update CI workflow [.github/workflows/build.yml](.github/workflows/build.yml) to upload archives via `xcrun notarytool` or Fastlane `pilot`.
  - Set `DEVELOPMENT_TEAM` in `project.yml` `settings.base` (currently empty).

## 5. APNs push notifications

- **What it unlocks:**
  - Goal milestone reminders ("You're 75% to your Vacation goal! Log a contribution?").
  - Shared-budget change notifications ("Alex added $42.50 to Groceries").
  - Subscription renewal alerts ("Netflix renews tomorrow for $15.49").
  - Weekly spending summary push.
- **Blocked because:** APNs auth keys are generated in the Developer portal. Firebase Cloud Messaging needs the `.p8` auth key.
- **Files / keys to touch when ready:**
  - Developer portal: generate APNs auth key (`.p8`), note the key ID + team ID.
  - Firebase Console → Project Settings → Cloud Messaging: upload the key.
  - `project.yml`: add push-notifications capability + `aps-environment` entitlement + `UIBackgroundModes: remote-notification`.
  - Add `UNUserNotificationCenter` registration on app launch (real version of the soft-ask in onboarding).
  - Wire `NotificationService` token persistence to `users/{uid}.fcmToken`.
  - Cloud Functions: Firestore triggers on `sharedBudgets/{id}/transactions/{txn}` write → FCM push to the other member.

## 6. Google Sign-In — production OAuth client

- **What it unlocks:** Google sign-in works for users not on the test allowlist. Required before external beta.
- **Blocked because:** the production OAuth client needs the real bundle ID registered against an App Store app record.
- **Files / keys to touch when ready:**
  - Google Cloud Console: create iOS OAuth 2.0 client for the final bundle ID.
  - Update `CFBundleURLSchemes` in `project.yml` with the production reversed client ID.
  - Verify `GoogleService-Info.plist` is the production config (not a Firebase-test variant).

## 7. Sign in with Apple — production cert

- **What it unlocks:** Apple sign-in option on `LoginView` and during onboarding. Required by App Store Review Guidelines when any third-party sign-in (Google) is offered.
- **Blocked because:** the Sign in with Apple capability requires a real Team ID and provisioning profile from the Developer portal.
- **Files / keys to touch when ready:**
  - `project.yml`: add `com.apple.developer.applesignin` entitlement.
  - Developer portal: enable Sign in with Apple on the app ID.
  - Firebase Console: enable Apple provider, upload the Services ID and private key.
  - Extend `AuthService` with `signInWithApple()` using `ASAuthorizationAppleIDProvider`.
  - Add the Apple-branded button to `LoginView`.

## 8. Real app icon commission

- **What it unlocks:** final brand identity in Home Screen + App Store listing.
- **Blocked because:** we're still on the placeholder name `BudgetApp`. Commissioning art before the name is locked wastes the commission.
- **Files / keys to touch when ready:**
  - Commission 1024×1024 PNG per Apple's icon guidelines.
  - Drop into `BudgetApp/Resources/Assets.xcassets/AppIcon.appiconset/`.
  - `project.yml` already has `ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon` (per `appcreation.md §8` — empty string fails on Xcode 26 with *"None of the input catalogs contained a matching app icon set."*)

---

## Process notes

- Prefer landing items in the order above — each later item depends on earlier ones.
- When a task gets picked up, move it to a **"Completed"** section at the bottom with a date and commit hash, rather than deleting. History is useful.
- If an enrollment-blocked need surfaces during later phases, append it here with the same three-field format.
