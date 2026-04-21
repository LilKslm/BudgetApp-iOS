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

### Ready to implement (no enrollment needed)
- [ ] Wire `FirebaseAuthService` replacing `MockAuthService`
- [ ] Wire `FirestoreUserService` — persist `QuizAnswers` + user profile on account creation
- [ ] Wire `FirebaseAnalyticsService` replacing `MockAnalyticsService`
- [ ] Wire `CrashlyticsService`
- [ ] Real `RevenueCatPaymentService` (sandbox testing possible with personal Apple ID)
- [ ] Real `NotificationService` (UNUserNotificationCenter)
- [ ] E2E test: sign up → quiz → paywall → purchase → MainTabView

---

## Upcoming Phases (Summary)

- **Phase 4:** Core budgeting + transactions + subscription tracker + gamified goal visualizations
- **Phase 5:** Shared budgets (co-edit via invite code)
- **Phase 6:** Polish — real icon, dark-mode QA, empty states, privacy manifest, App Store prep

---

## Review Log

### Phase 1 (complete)
- Shipped: full app scaffold, 5-tab MainTabView, CI pipeline, MacInCloud verified
- Surprise: CocoaPods `inhibit_all_warnings!` + static linkage injects `-GCC_WARN_INHIBIT_ALL_WARNINGS` into per-file flags; clang 16 parses `-G<word>` as unsupported `-G`. CI masked it via Python patch; MacInCloud exposed it.
- Fix: Parallel `if` blocks in `post_install` (lesson logged)

### Phase 2 (complete — MacInCloud pending)
- Shipped: Full 19-screen onboarding, all mocked. Coordinator pattern with resume, analytics, discounted paywall variant.
- Surprises: `Color(hex:)` takes `UInt32` not `String`; `body` is reserved in `View` structs (both lessons logged)
- Next: MacInCloud verification, then Phase 3
