# BudgetApp — Current Work

> Live task tracker. Updated as work progresses. Completed phases get archived to `tasks/done/` rather than deleted.

---

## Phase 1 — Scaffolding + Mocked Home ✅ COMPLETE

- [x] Create project docs — `CLAUDE.md`, `BudgetApp/features.md`, `apple-developer-tasks.md`
- [x] Infra scaffolding — `project.yml`, `Podfile`, `.github/workflows/build.yml`, `.gitignore`
- [x] Core layer — `AppTheme`, `AppError`, `AppLogger`, `AppContainer`
- [x] Services — `HapticService` + all protocols + mocks
- [x] App entry — `BudgetAppApp`, `AppDelegate`, `ContentView`, `AppViewModel`
- [x] `MainTabView` + 5 placeholder tabs (Home, Budgets, Transactions, Goals, Profile)
- [x] Components — `PrimaryButton`, `GradientCard`, `LoadingView`, `ErrorView`, `EmptyStateView`, `SurfaceCard`
- [x] `Assets.xcassets` with `AppIcon` placeholder
- [x] CI green on `main`
- [x] MacInCloud visual verification — 5-tab MainTabView, gradient visible, dark mode works
- [x] Podfile BoringSSL-GRPC `-G` flag fix (parallel `if` blocks in `post_install`)

---

## Phase 2 — Full Onboarding Flow ✅ COMPLETE (pending MacInCloud verification)

**Goal:** 19-screen onboarding (all mocked, no Firebase/RevenueCat). Quiz → Results → Pain → How-We-Help → Reviews → Feature Tour → Custom Plan → Notification Prompt → Account → Paywall → MainTabView.

- [x] `OnboardingStep` enum (19 steps, `stepNumber`, `allowsBack`)
- [x] `OnboardingCoordinator` — `NavigationStack` driver, `UserDefaults` resume, analytics
- [x] `OnboardingRootView` — `NavigationStack(path:)` + `navigationDestination(for:)`
- [x] `OnboardingScaffold` + `OnboardingProgressBar` components
- [x] `QuizQuestions` — 10 questions with options
- [x] `QuizQuestionView` + `QuizOptionButton`
- [x] `QuizResultsView` — personalized callouts from quiz answers
- [x] `PainPointView` — personalized headline + 3 stat rows
- [x] `HowWeHelpView` — 3 differentiation rows
- [x] `ReviewsView` — swipeable testimonial cards
- [x] `FeatureTourView` — 4-page tour with pure-SwiftUI mock previews
- [x] `CustomPlanBuilder` + `CustomPlanView`
- [x] `NotificationPromptView` — mock permission request
- [x] `AccountView` + `AuthViewModel` — sign up / log in (mocked)
- [x] `PaywallView` — standard + discounted variants (mocked)
- [x] `NotificationService` protocol + mock, wired into `AppContainer`
- [x] `PaywallVariant` enum in `PaymentService`
- [x] Analytics events for notification, account, discount paywall
- [x] DEBUG skip buttons in `ProfileView`
- [x] Build errors fixed — `Color(hex:)` type, `body` name conflict
- [x] `appcreation.md` updated — rebuild vs. pull-only decision table

### Phase 2 exit criteria
- [ ] **MacInCloud visual verification** — pull only: `cd ~/budgetapp-ios && git pull`, then ▶
  - Golden path: Q1–10 → Results → Pain → How-We-Help → Reviews → Feature Tour → Custom Plan → Notification → Account → Paywall
  - Purchase completes → lands in MainTabView
  - Progress bar animates across all screens
  - Swipe back works on quiz questions, blocked on post-quiz screens

---

## Current Phase: **Phase 3 — Firebase + RevenueCat (Real Services)**

**Goal:** Swap mock services for real ones. Quiz answers persist to Firestore. Auth works. RevenueCat paywall live.

### Blocked until **paid** Apple Developer Program enrollment
- Free-tier enrollment is active (2026-04-21) — covers on-device code signing only
- See `apple-developer-tasks.md` for the full list and the free-tier unlocked-vs-blocked breakdown

### Sub-phase 3a — Firebase foundation + secrets plumbing
- [x] `AppEnvironment` + `SecretsLoader` (DEBUG/RELEASE split, `-firebaseLive` launch arg)
- [x] `GoogleService-Info.plist.sample` committed; real plist stays gitignored
- [x] `scripts/decrypt-secrets.sh` (idempotent, no-op when `GS_INFO_B64` unset)
- [x] `AppDelegate` calls `FirebaseApp.configure()` guarded on plist presence + `FirebaseApp.app() == nil`
- [x] `AppContainer.makeDefault()` DEBUG/RELEASE factory (real-impl branch falls back to mocks until 3b–3d land)
- [x] CI "Decode GoogleService-Info.plist" step added to `.github/workflows/build.yml`
- [ ] MacInCloud smoke: launch → console logs `Firebase configured` once (requires Firebase project + plist drop)

### Sub-phase 3b — FirebaseAuth + Firestore user document ✅
- [x] `AppError.notImplemented` added (social auth stubs surface this)
- [x] `UserServiceProtocol` + `MockUserService` in `Services/UserService.swift`
- [x] `FirebaseAuthService` in `Services/Firebase/` (Google/Apple throw `.notImplemented`)
- [x] `FirestoreUserService` in `Services/Firebase/` (async `Firestore.Encoder` + `setData`)
- [x] `AppContainer` — `users: UserServiceProtocol` slot; `makeDefault()` wires real impls for release
- [x] `AuthViewModel.completeSignUp(quizAnswers:)` — sign up → create doc → rollback on Firestore fail
- [x] `AccountView` threads `coordinator.quizAnswers` into `completeSignUp`
- [x] `OnboardingCoordinator.completeAccount()` calls `clearResume()` (Firestore is now source of truth)
- [ ] MacInCloud verification: sign up → Firebase Auth console shows user + `users/{uid}` doc with `quiz_answers`

### Sub-phase 3c — FirestoreDataService + rules + Analytics/Crashlytics ✅
- [x] `FirestoreDataService` — user-scoped subcollections `users/{uid}/{collection}/{id}`
- [x] `FirebaseAnalyticsService` — maps `AnalyticsEvent` → `Analytics.logEvent`; DEBUG asserts on name length + reserved prefixes + param cap
- [x] `CrashlyticsService` — singleton, records errors in release builds; hooked into `AppError.wrap()`
- [x] `firestore.rules` + `firebase.json` + `docs/phase3-deploy-rules.md` (Rules Playground test matrix included)
- [ ] Run `firebase deploy --only firestore:rules` + verify in Firebase Console → Rules → Publish

### Sub-phase 3d — RevenueCat + local StoreKit config ✅
- [x] `RevenueCatPaymentService` (entitlement `premium`; user-cancel detection; maps RC `Package` → `PaywallPackage`)
- [x] `BudgetApp.storekit` — `budgetapp.pro.yearly` ($49.99/yr, 7-day trial) + `budgetapp.pro.monthly` ($7.99/mo)
- [x] `project.yml` `schemes:` block → `storeKitConfiguration: BudgetApp/Resources/BudgetApp.storekit`
- [x] `RevenueCatPaymentService` wired in `AppContainer.makeDefault()` release branch
- [x] `AppDelegate` already calls `container.payments.configure()` → triggers `Purchases.configure(withAPIKey:)` on RC impl
- [ ] Update `SecretsLoader.revenueCatAPIKey` with real key from RevenueCat dashboard

### Phase 3 exit
- [ ] E2E on MacInCloud: sign up → quiz → paywall → purchase → MainTabView with entitlement persisted

---

## Upcoming Phases (Summary)

- **Phase 4:** Core budgeting + transactions + subscription tracker + gamified goal visualizations
- **Phase 5:** Shared budgets (co-edit via invite code)
- **Phase 6:** Polish — real icon, dark-mode QA, empty states, privacy manifest, App Store prep

---

## Review Log

### 2026-04-22 — Fix Skip-Paywall + Toggle-Pro (same root cause as login button)
- Second casualty of the `a91ce3d` service-default flip: `PaywallPlaceholderView`'s "Skip paywall (DEBUG)" button and `ProfileView`'s "Toggle Pro" button both did `(container.payments as? MockPaymentService)?._debugSetPremium(...)`. With `container.payments` now being `RevenueCatPaymentService` in Debug, the cast returns nil, the optional chain silently no-ops, buttons do nothing. Meta-lesson logged: I wrote the "grep every call site" rule yesterday but didn't execute it on the other concrete call sites.
- `PaymentServiceProtocol` — lifted `_debugSetPremium(_:)` onto the protocol so both impls satisfy it.
- `RevenueCatPaymentService` — implements `_debugSetPremium` as a local `premiumSubject.send(value)`; harmless since any real customerInfo update from the SDK will overwrite it. Safe DEBUG test seam.
- `PaywallPlaceholderView` + `ProfileView` — replaced broken casts with direct `container.payments._debugSetPremium(...)` calls.
- Grep confirms zero remaining `as? Mock*Service` casts in the codebase.
- RevenueCat "Invalid API Key" spam in the console is unrelated — same Test Store key rejection tracked in [apple-developer-tasks.md](apple-developer-tasks.md) item 2.

### 2026-04-22 — Post-real-services-flip fixes
- After `a91ce3d` flipped Debug default to real services, the Phase-1 "Continue with mock user" button silently failed: it hit real Firebase with `demo@budgetapp.com` / `mockpass`, threw, and `try?` swallowed the error.
- [BudgetApp/Views/Auth/LoginPlaceholderView.swift](BudgetApp/Views/Auth/LoginPlaceholderView.swift) rewritten — loading state + `AppViewModel.presentError` on failure + signIn-then-signUp fallback on `.userNotFound`/`.invalidCredentials` (auto-provisions the demo user on first run against a fresh Firebase project). Works for both `MockAuthService` and `FirebaseAuthService`.
- [BudgetApp/App/AppDelegate.swift](BudgetApp/App/AppDelegate.swift) — dropped the `FirebaseApp.app() == nil` pre-configure check; that accessor itself logs `I-COR000003 The default Firebase app has not yet been configured` when called pre-configure, which was the source of the warning in launch logs.
- [apple-developer-tasks.md](apple-developer-tasks.md) item 2 updated — documents that the current Test Store key `test_PJKgaCQaUCINWsixkflMuIeuENQ` is being rejected by RevenueCat at launch (`Invalid API Key`), with interim unblock paths (regenerate Test Store key OR launch with `-useMocks`).

### Phase 1 (complete)
- Shipped: full app scaffold, 5-tab MainTabView, CI pipeline, MacInCloud verified
- Surprise: CocoaPods `inhibit_all_warnings!` + static linkage injects `-GCC_WARN_INHIBIT_ALL_WARNINGS` into per-file flags; clang 16 parses `-G<word>` as unsupported `-G`. CI masked it via Python patch; MacInCloud exposed it.
- Fix: Parallel `if` blocks in `post_install` (lesson logged)

### Phase 2 (complete — MacInCloud pending)
- Shipped: Full 19-screen onboarding, all mocked. Coordinator pattern with resume, analytics, discounted paywall variant.
- Surprises: `Color(hex:)` takes `UInt32` not `String`; `body` is reserved in `View` structs (both lessons logged)
- Next: MacInCloud verification, then Phase 3
