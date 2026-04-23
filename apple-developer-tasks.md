# Apple Developer Enrollment — Deferred Tasks (BudgetApp)

## Current enrollment status — Free tier (as of 2026-04-21)

The developer is enrolled in the **free Apple Developer account** (Apple ID personal team), **not** the paid Apple Developer Program (USD $99/yr). Do **not** scatter TODOs into `features.md` or code comments — this file is the single source of truth for everything that still needs the paid program.

### What the free tier unlocks (can do now)

- Code-sign and run on a personal iOS device (7-day provisioning profile — re-sign weekly).
- Register Bundle IDs via Xcode's automatic signing (Personal Team).
- Access developer documentation, forums, beta OS downloads.
- Use Firebase Auth, Firebase Analytics, Firestore, Crashlytics — these are Google-side, not Apple-side.
- Use Google Sign-In for dev/test accounts (production OAuth client still blocked — see item 6).
- Set `DEVELOPMENT_TEAM` in `project.yml` to the Personal Team ID once the user provides it (needed for on-device builds; not strictly needed for simulator or CI).

### What still requires the **paid** Apple Developer Program

Items 1 through 7 below are all still blocked. Paid-only gates:

- App Store Connect access → blocks subscriptions, RevenueCat live, TestFlight, App Store submission.
- APNs auth key generation → blocks push notifications.
- Sign in with Apple capability → blocks item 7.
- Plaid iOS SDK production signing → blocks item 3.
- Provisioning profiles longer than 7 days → blocks external beta distribution.

---

Each item is formatted as:
- **What it unlocks** — the user-facing capability that lights up.
- **Blocked because** — the specific Developer-account requirement.
- **Files / keys to touch when ready** — exact entry points so a future agent can execute without re-deriving the plan.

---

## 1. App Store Connect — create Pro subscription products

- **What it unlocks:** real monthly + yearly purchases in `PaywallView`. Replaces the current `#if DEBUG` "Skip Paywall" button.
- **Blocked because:** subscription products can only be created in App Store Connect, which requires the **paid** Apple Developer Program (free tier does not grant App Store Connect access).
- **Files / keys to touch when ready:**
  - App Store Connect: create two auto-renewing subscriptions (`budgetapp.pro.monthly`, `budgetapp.pro.yearly`) in a subscription group named `BudgetApp Pro`. Attach to entitlement `pro`. Mark yearly as "best value" with a 7-day free trial.
  - (Optional) add a `.storekit` configuration file to the Xcode scheme for local simulator testing.

## 2. RevenueCat — swap placeholder API key for live key

- **What it unlocks:** real RevenueCat offerings load in `PaywallView` and real purchases flow through `PaymentService.purchase(package:)`.
- **Blocked because:** live key requires App Store Connect products (item 1) wired to a RevenueCat offering.
- **Phase 3d status:** SDK integrated. `RevenueCatPaymentService` is live in `AppContainer.makeDefault()`. `BudgetApp.storekit` provides local simulator purchase flow with matching product IDs. Entitlement ID is `"premium"` (per project.md §1129).
- **Current key status (2026-04-22):** `SecretsLoader.revenueCatAPIKey` holds a RevenueCat **Test Store** key. The key committed in `4a114f1` had a case-sensitivity typo (`kfl` vs `kfL`) that caused `Invalid API Key` errors; fixed in `f52f664`. If RevenueCat rejections return, first diff the committed string against the dashboard value character-by-character before assuming the key is revoked.
- **Still needed on the RevenueCat dashboard side:** create an Offering attached to the Test Store app containing products matching `BudgetApp.storekit` (`budgetapp.pro.yearly`, `budgetapp.pro.monthly`), both tied to entitlement `premium`. Without this, `fetchOfferings` returns an empty package list and the onboarding paywall renders no purchase options.
- **Files / keys to touch when the paid program lands:**
  - Replace the Test Store key in [BudgetApp/Core/Config/SecretsLoader.swift](BudgetApp/Core/Config/SecretsLoader.swift#L15) with the live publishable iOS SDK key (`appl_…`) from the RevenueCat dashboard.
  - RevenueCat dashboard: attach `budgetapp.pro.monthly` + `budgetapp.pro.yearly` to entitlement `premium`; mark yearly as "best value".
  - Remove the `#if DEBUG Skip Paywall` button in [BudgetApp/Views/Paywall/PaywallView.swift](BudgetApp/Views/Paywall/PaywallView.swift) once end-to-end purchases work in sandbox.

## 3. Plaid integration — bank linking + auto-subscription detection *(biggest deferred item)*

- **What it unlocks:**
  - Secure bank/credit-card account linking (Monarch/Copilot-style) via OAuth — users never type credentials into BudgetApp.
  - Automatic transaction import + categorization.
  - Automatic recurring-charge detection → populates the Subscriptions screen without manual entry.
  - The net-worth dashboard (asset balances pulled live from linked accounts).
- **Blocked because:**
  - Plaid production access requires underwriting review (1–2 weeks) against a registered company/LLC.
  - Plaid Link SDK needs the app signed with a production cert (requires the **paid** Apple Developer Program; free tier's 7-day personal profiles will not pass Plaid's production checks).
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
- **Blocked because:** TestFlight requires an App Store Connect listing, which requires the **paid** Apple Developer Program.
- **Files / keys to touch when ready:**
  - App Store Connect: create the app record with the final bundle ID.
  - Update CI workflow [.github/workflows/build.yml](.github/workflows/build.yml) to upload archives via `xcrun notarytool` or Fastlane `pilot`.
  - Set `DEVELOPMENT_TEAM` in `project.yml` `settings.base` (currently empty). Note: free tier gives a Personal Team ID that can be set here for on-device testing, but the TestFlight upload step still requires the paid program's team ID.

## 5. APNs push notifications

- **What it unlocks:**
  - Goal milestone reminders ("You're 75% to your Vacation goal! Log a contribution?").
  - Shared-budget change notifications ("Alex added $42.50 to Groceries").
  - Subscription renewal alerts ("Netflix renews tomorrow for $15.49").
  - Weekly spending summary push.
- **Blocked because:** APNs auth keys are generated in the Developer portal and require the **paid** program (free tier cannot generate APNs `.p8` keys). Firebase Cloud Messaging needs the `.p8` auth key.
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
- **Blocked because:** the Sign in with Apple capability requires a real Team ID and provisioning profile from the Developer portal, available only with the **paid** program (free tier's Personal Team cannot enable this capability).
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
