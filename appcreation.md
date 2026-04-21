# App Creation — Lessons Learned

> A consolidated playbook for future Claude instances building iOS apps from scratch (initial project: **Chronos**, a screen-time ranked game). Read this before touching anything. It captures what worked, what broke, and the exact sequences that save hours.

---

## 0. Orientation — Read These First

Before any non-trivial decision, read these in order:

1. **`project.md`** (workspace root) — **authoritative** iOS infrastructure blueprint. Stack, folder structure, services, MVVM patterns, error model, analytics events, monetization. When project.md and anything else disagree, project.md wins.
2. **`features.md`** (inside the app folder, e.g. `Chronos/features.md`) — product-specific roadmap, phase plan, ranked system, vision/non-goals.
3. **`apple-developer-tasks.md`** (workspace root) — single source of truth for everything blocked on Apple Developer Program enrollment. Never scatter these TODOs into `features.md` or code comments.
4. **`Chronos/project.yml`** — XcodeGen spec. Source of truth for bundle ID, deployment target, capabilities, Info.plist keys. `.xcodeproj` is **gitignored** and regenerated from this.
5. **`CLAUDE.md`** (root) — project-specific operational rules that override defaults.
6. **Auto-memory** at `C:\Users\khali\.claude\projects\c--Users-khali-Desktop-App-first-try\memory\MEMORY.md` — consult before starting, update when you learn something worth persisting across sessions.

---

## 1. The Environment You're Working In

- **User's OS:** Windows 11. **No local Xcode.** Do NOT attempt `xcodebuild`, `xcrun`, `pod install`, or any Xcode-specific command locally — they will fail.
- **Shell:** bash on Windows — use Unix syntax (`/dev/null`, forward slashes), not Windows CMD syntax.
- **Builds happen in two places:**
  1. **GitHub Actions CI** — `.github/workflows/build.yml` runs on every push to `main`. macos-15 runner with Xcode 16. Pipeline: `brew install xcodegen` → `xcodegen generate` → `pod install` → `xcodebuild`.
  2. **MacInCloud** — for manual visual verification. See §2 for the exact sequence.
- **Push to `main`, let CI validate.** Never claim a UI change works without visual verification on MacInCloud or screenshots from the user.

---

## 2. MacInCloud Build Sequence

### 2a. Full rebuild (fresh clone OR after project.yml / Podfile changes)

Use this when: first time on a machine, OR `project.yml` changed (capabilities, Info.plist keys, targets), OR `Podfile` changed (pods added/removed/updated).

```bash
cd ~/budgetapp-ios
git checkout main
git pull
xcodegen generate
pod install
rm -rf ~/Library/Developer/Xcode/DerivedData
open BudgetApp.xcworkspace
```

Then in Xcode: hit ▶ (or Product → Run).

**Why each line matters:**
- `git checkout main` — stale clones silently diverge; always make sure you're on main.
- `xcodegen generate` — `.xcodeproj` is gitignored, must be regenerated after every pull.
- `pod install` — must run after every `xcodegen generate`; CocoaPods injects workspace-level build settings.
- `rm -rf ~/Library/Developer/Xcode/DerivedData` — Xcode caches aggressively; stale DerivedData causes phantom build failures.
- `open BudgetApp.xcworkspace` — **workspace, not `.xcodeproj`**. CocoaPods requires the workspace.

### 2b. Pull-only (pure Swift source changes)

Use this when: only `.swift` files changed — no `project.yml`, no `Podfile`, no new capabilities, no new pods.

```bash
cd ~/budgetapp-ios && git pull
```

Then hit ▶ in Xcode (workspace already open). No xcodegen or pod install needed.

### 2c. How to know which one applies

Claude will always tell you explicitly at the end of every push:

> **MacInCloud: full rebuild** (project.yml changed — new capability added)

or

> **MacInCloud: pull only** (Swift files only — `cd ~/budgetapp-ios && git pull`, then ▶)

If Claude forgets to say, ask. Never guess.

### What changed vs. what command it triggers

| What changed | Command needed |
|---|---|
| `.swift` files only | `git pull` + ▶ |
| `project.yml` | full rebuild |
| `Podfile` | full rebuild |
| New pod added | full rebuild |
| New capability / URL scheme | full rebuild |
| `Info.plist` keys via `project.yml` | full rebuild |

---

## 3. Tech Stack — Do Not Deviate

| Layer | Choice | Why |
|-------|--------|-----|
| UI | Swift / SwiftUI, iOS 16+ | iOS 17+ features allowed, but 16 is the floor |
| Auth | Firebase Auth (email/password + Google Sign-In) | Mature, free tier, works with Firestore rules |
| Database | Firestore | Real-time listeners, offline cache, integrates with Auth |
| Analytics | Firebase Analytics | Free, funnel-ready |
| Crash reporting | Firebase Crashlytics | Free, wired in AppDelegate |
| Payments | RevenueCat | Abstracts StoreKit, entitlements server-side |
| Architecture | MVVM + protocol-based DI | Testable; every service has a protocol + mock |
| Concurrency | `async/await` throughout | Callbacks are **banned** |
| Dependency tool | **CocoaPods**, NOT SPM | SPM is incompatible with Xcode 26 beta static frameworks |

### CocoaPods vs SPM — Critical

`project.md` shows SPM commands, but in practice we had to switch to **CocoaPods** because SPM's static frameworks fail bundle validation on Xcode 26 beta. Always use CocoaPods. Always open `.xcworkspace`, never `.xcodeproj`.

---

## 4. Architecture Rules (Non-Negotiable)

- **Every service has a protocol AND a mock.** `AuthServiceProtocol` + `MockAuthService`. ViewModels accept the protocol, defaulting to the real implementation. Tests inject the mock.
- **Design tokens are centralized** in `AppTheme`. Colors, gradients, sizes, spacing, fonts, animations. **No hardcoded hex values elsewhere.** Changing `AppTheme` should propagate the redesign globally.
- **`@MainActor` for any function touching `@Published`.** Or wrap the mutation in `await MainActor.run { ... }`.
- **Never force-unwrap in production code.** Use `guard let` / `throw AppError.userNotFound` instead.
- **`weak self` in Combine sinks and callbacks.** Not needed in `async` functions.
- **Loading-state pattern** — every async ViewModel function follows this:
  ```swift
  isLoading = true
  defer { isLoading = false }
  do { /* work */ } catch { self.error = .unknown(error) }
  ```
- **All errors funnel through `AppError`** (enum in `Core/Errors/AppError.swift`). Map Firebase/RevenueCat errors at the service boundary — ViewModels only see `AppError`.

---

## 5. Design System

- **Accent surfaces use `AppTheme.Gradients.primary`** (blue→purple): progress rings, active hourly bars, active tab icons, primary buttons, chart lines, improvement percentages. Not `Colors.accent`.
- **Tab bar uses `.safeAreaInset(edge: .bottom, spacing: 0)`.** Do not add manual bottom padding in screens — the inset handles clearance.
- **Haptics go through `HapticService`.** Call `HapticService.success()` / `.impact(.light)` / `.selection()` — never instantiate `UIFeedbackGenerator` directly in views.
- **Intentional visual exceptions** (leave alone unless redesigning):
  - `StreakBadge` uses its own gradient pill style.
  - `MotivationalCard` uses `Colors.cardGreen`.
- **Strings go in `Localizable.strings`** with dotted keys (`screen.section.role`). Onboarding copy can stay inline until a translator is briefed.

---

## 6. Firestore Conventions

- **Security rules** live at `Chronos/firestore.rules` (source of truth), but **CocoaPods does not publish them**. After any rules change, open Firebase Console → Firestore → Rules, paste the file, click **Publish**. A silent `permission-denied` that looks like a client bug is almost always unpublished rules.
- **Service-mediated writes only.** For anything with invariants (dedupe, bidirectional edges, status transitions) — e.g. friend graph — all writes go through a dedicated service (`FriendService`). Never let a ViewModel touch root collections directly.
- **User-scoped data lives under `users/{uid}/...`** subcollections. Root collections are reserved for cross-user indexes (`friendRequests`, `friendCodes`) with explicit rules.

---

## 7. Pro-Gating Pattern

The Friends tab is Pro-gated. Free users see an upsell card that routes to the paywall. **Mirror this gate on any future social surface** — never expose friend-graph data behind the paywall.

`AppState.paywall` routes to `PaywallView` after onboarding. RevenueCat entitlement ID is `"pro"`. Check `PaymentService.isPremium` before rendering Pro surfaces.

---

## 8. XcodeGen & Info.plist — Gotchas

- **`.xcodeproj` is gitignored** — regenerate with `xcodegen generate` after every pull.
- **Info.plist is auto-generated** (`GENERATE_INFOPLIST_FILE: YES` in `project.yml`). The physical file at `Chronos/Resources/Info.plist` is excluded from the target — editing it does nothing. **Add keys via `project.yml`'s `info.plist` dict.**
- **`ASSETCATALOG_COMPILER_APPICON_NAME` must be set to `AppIcon`** (non-empty). Empty string fails on Xcode 26 with: *"None of the input catalogs contained a matching app icon set."*
- **App icon is a placeholder** — solid indigo 1024×1024 PNG. Commission real art late in the project.
- **Windows CRLF warnings** from git are harmless for `.swift`, `.yml`, `.json`. PNGs are binary and unaffected.

---

## 9. Phased Build Plan (Pattern to Reuse)

A 6-phase build plan kept this shippable at every step:

| Phase | Scope |
|-------|-------|
| **1** | Home + Profile + Settings screens with **mock data**, theme, tab bar, CI wired |
| **2** | Full onboarding flow (questions → shock screen → counterfactual → plan) with local `UserDefaults` state |
| **3** | Firebase Auth + Firestore (CocoaPods), Google Sign-In, RevenueCat paywall, real data services |
| **4** | Core game loop (ranked system, points engine, celebration) — placeholders for commissioned assets |
| **5** | Social layer (friends, leaderboards, duels) |
| **6** | Notifications, localization, App Store submission, polish |

**Rule: mock before real.** Every phase uses mock services first (`MockDataService`, `MockAuthService`) so UI and logic are complete before the network is wired.

---

## 10. What's Blocked on Apple Developer Enrollment

Keep a **single file** (`apple-developer-tasks.md`) listing every deferred task. **Do not scatter these into `features.md` or code comments.** Each item uses this format:

- **What it unlocks** — user-facing capability that lights up.
- **Blocked because** — specific Developer-account requirement.
- **Files / keys to touch when ready** — exact entry points so a future agent can execute without re-deriving the plan.

The current deferred list (6 items):
1. App Store Connect subscription products
2. RevenueCat live API key (test key fine for sandbox)
3. FamilyControls + DeviceActivityMonitor (needs real device)
4. TestFlight distribution
5. APNs push notifications
6. Google Sign-In production OAuth client
7. Phone auth + contacts-based friend discovery
8. Push notifications for friend requests

---

## 11. Skills & How to Use Them

Skills available in this project:
- **`frontend-design`** — visual direction for SwiftUI views. Use when project.md is silent on look/feel. Commit to a direction, no generic AI UI.
- **`frontend-patterns`** — component composition philosophy adapted to SwiftUI (decompose views, reusable components, state patterns).
- **`backend-patterns`** — service layer, error handling, logging philosophy where it complements project.md (concepts only; most of its Node.js/React examples don't apply).
- **`security-review`** — complete pre-submit security review of pending changes.
- **`simplify`** — review changed code for reuse, quality, efficiency.
- **`claude-api`** — Anthropic SDK work (mostly irrelevant for iOS).
- **`init`**, **`review`** — scaffolding / PR review.

**Hierarchy:** `project.md` always wins. Skills supplement. If a skill conflicts with `project.md`, follow `project.md`. Only pull from skills when `project.md` is silent.

**MCP servers:**
- **Blender MCP** wired for 3D gear mesh generation. Runs on `localhost:9876`. User must open Blender → `N` → BlenderMCP panel → "Connect to Claude" before the `mcp__blender__*` tools are reachable.

---

## 12. Mistakes Made — Do Not Repeat

These are lessons earned the hard way. Do not repeat any of them.

### 12.1. Said "the UI works" without visual verification
- **What happened:** Pushed changes, said "this should work," user ran it on MacInCloud and it was broken.
- **Rule:** Never claim a UI change works without visual verification. If you can't verify it yourself, say so explicitly. Type-checking and test suites verify code correctness, not feature correctness.

### 12.2. Ran `xcodebuild` / `pod install` locally
- **What happened:** The user is on Windows. Xcode commands fail instantly.
- **Rule:** Windows machine has no Xcode. All build/validation must route through CI or MacInCloud.

### 12.3. Committed to SPM before discovering Xcode 26 incompatibility
- **What happened:** Wired Firebase via SPM per `project.md`. Static framework bundle validation failed on Xcode 26 beta. Had to rip it all out and redo via CocoaPods.
- **Rule:** When `project.md` prescribes a dependency tool, still verify it builds against the user's actual Xcode version before wiring in dependencies. Trust but verify.

### 12.4. Edited `Chronos/Resources/Info.plist` directly
- **What happened:** Changes silently had no effect. Info.plist is auto-generated from `project.yml` — the file in the repo is excluded from the target.
- **Rule:** Add Info.plist keys via `project.yml`'s `info.plist` dict, never the physical file.

### 12.5. Forgot to publish Firestore rules
- **What happened:** Client got `permission-denied` that looked like a client bug. Spent time chasing a non-existent bug. Real cause: new rules in `firestore.rules` weren't published via Firebase Console.
- **Rule:** CocoaPods doesn't deploy rules. After any `firestore.rules` change, go to Firebase Console → Firestore → Rules, paste, **Publish**.

### 12.6. Used placeholder gear PNGs with transparency on SCNCylinder
- **What happened:** Transparent pixels showed as checkerboard through `SCNView.backgroundColor = .clear`. Pivoted to procedural 3D meshes via Blender MCP.
- **Rule:** For any 3D rendering, validate the full transparency/background chain before committing to an approach.

### 12.7. Cloned on a fresh machine and tracked `origin/master`
- **What happened:** `git pull` reported "already up to date" while missing every commit since the rename. Silent divergence.
- **Rule:** Always `git checkout main` explicitly on fresh clones.

### 12.8. Forgot `pod install` after `xcodegen generate`
- **What happened:** Xcode opened but build failed because CocoaPods workspace-level settings were out of sync.
- **Rule:** `pod install` must run after every `xcodegen generate`. Always. Bake it into the MacInCloud block.

### 12.9. Hardcoded colors in views instead of using `AppTheme`
- **What happened:** Redesigning a screen required hunting hex values across 20 files.
- **Rule:** All colors/gradients/spacing live in `AppTheme`. Views reference tokens. Period.

### 12.10. Let a ViewModel write directly to `friendRequests`
- **What happened:** Invariants drifted — the same request got written twice, one side of a bidirectional edge was missing.
- **Rule:** Any collection with invariants is service-mediated. ViewModels call `FriendService.sendRequest(...)`, not Firestore directly.

---

## 13. Do's — Consistent Patterns That Worked

- **DO** read `project.md` before any non-trivial decision.
- **DO** use plan mode for 3+ step tasks or architectural decisions.
- **DO** include the full MacInCloud command block every time the user needs to verify. No partial subsets.
- **DO** build Phase N with mocks first, then swap in the real service in the phase where it belongs.
- **DO** keep Apple-Developer-blocked tasks in `apple-developer-tasks.md` with the three-field format.
- **DO** update `MEMORY.md` index when you learn something worth persisting across sessions.
- **DO** use `.safeAreaInset(edge: .bottom, spacing: 0)` for tab bars; let the inset handle screen padding.
- **DO** use `AppTheme.Gradients.primary` for accent surfaces. Not `Colors.accent`.
- **DO** funnel haptics through `HapticService`.
- **DO** write strings to `Localizable.strings` with dotted keys when the copy is stable.
- **DO** run `xcodegen generate` after every `project.yml` edit.
- **DO** push to `main` and let CI validate — treat CI as your automated build verification.
- **DO** map raw Firebase/RevenueCat errors to `AppError` at the service boundary.
- **DO** gate Pro surfaces behind `PaymentService.isPremium` consistently — one pattern, everywhere.

---

## 14. Don'ts — Never Repeat

- **DON'T** run `xcodebuild`, `xcrun`, `pod install`, or any Xcode-specific command locally on Windows.
- **DON'T** claim a UI change works without visual verification.
- **DON'T** open `.xcodeproj` — always `.xcworkspace`.
- **DON'T** commit `.xcodeproj` — it's gitignored, regenerated from `project.yml`.
- **DON'T** edit `Chronos/Resources/Info.plist` directly — add keys to `project.yml` `info.plist` dict.
- **DON'T** use SPM for new iOS projects on Xcode 26 beta — use CocoaPods.
- **DON'T** hardcode hex colors in views — use `AppTheme`.
- **DON'T** touch `friendRequests` or `users/{uid}/friends` from a ViewModel — go through `FriendService`.
- **DON'T** instantiate `UIFeedbackGenerator` directly — use `HapticService`.
- **DON'T** render `tier.sfSymbol` inline — use `RotatingGearView(tier:)` which falls back automatically.
- **DON'T** use callbacks — use `async/await`.
- **DON'T** force-unwrap — use `guard let` + `throw`.
- **DON'T** add manual bottom padding in screens when a tab bar is present — `.safeAreaInset` handles it.
- **DON'T** scatter Apple-Developer-blocked tasks across `features.md` or code comments — they go in `apple-developer-tasks.md`.
- **DON'T** commit without updating `project.yml` when adding new capabilities, URL schemes, or Info.plist keys.
- **DON'T** skip `rm -rf DerivedData` on MacInCloud — Xcode 26 beta caches aggressively.
- **DON'T** forget to publish Firestore rules after editing `firestore.rules`.

---

## 15. New-Project Checklist

When starting a new iOS app from this blueprint:

1. [ ] Copy `project.md` to the workspace root — inherit the full infrastructure.
2. [ ] Create `features.md` in the app folder — product-specific roadmap, phases, non-goals.
3. [ ] Create `apple-developer-tasks.md` at the workspace root — even if empty initially, it's where deferred tasks will land.
4. [ ] Create `CLAUDE.md` at the workspace root — operational rules, build commands, gotchas.
5. [ ] Scaffold `project.yml` for XcodeGen — bundle ID, deployment target, capabilities, Info.plist keys.
6. [ ] Set up `Podfile` with Firebase + GoogleSignIn + RevenueCat (NOT SPM on Xcode 26).
7. [ ] `.gitignore` `.xcodeproj`, `Pods/`, `DerivedData/`, `.DS_Store`.
8. [ ] Set up `.github/workflows/build.yml` with the macos-15 + Xcode 16 pipeline.
9. [ ] Scaffold Core/ folders: `DI/AppContainer.swift`, `Errors/AppError.swift`, `Logging/Logger.swift`, `Extensions/`.
10. [ ] Create `AppTheme` with all design tokens (colors, gradients, spacing, fonts, animations).
11. [ ] Scaffold service protocols + mocks — `AuthServiceProtocol` + `MockAuthService`, etc.
12. [ ] Scaffold `AppViewModel` with `AppState` enum driving `ContentView` routing.
13. [ ] Build Phase 1 entirely with mock data before adding Firebase.
14. [ ] Wire CI early. Push often. Let CI validate.
15. [ ] Configure Firebase project (Auth providers, Firestore, Analytics, Crashlytics) and download `GoogleService-Info.plist` into the project root.
16. [ ] Create `firestore.rules` with user-scoped access. Publish via Firebase Console.
17. [ ] Start `MEMORY.md` index for session-spanning notes.

---

## 16. Workflow — How to Collaborate with the User

- **Plan mode** for any non-trivial task (3+ steps or architectural decisions). Write the plan; wait for approval.
- **Subagents liberally** — delegate research, exploration, parallel analysis to keep main context clean.
- **Self-improvement loop** — after any correction, update `tasks/lessons.md` with the pattern. Ruthlessly iterate until mistake rate drops.
- **Verification before done** — never mark a task complete without proving it works. Diff behavior, run tests, demonstrate correctness.
- **Demand elegance (balanced)** — for non-trivial changes, pause and ask "is there a more elegant way?" For simple fixes, don't over-engineer.
- **Autonomous bug fixing** — given a bug report, just fix it. Don't ask for hand-holding. Point at logs/errors/failing tests, resolve them.
- **Task management** — plan → verify plan → track progress → explain changes → document results → capture lessons.
- **Simplicity first** — every change as simple as possible. Minimal code impact. Find root causes, not temporary fixes.

---

*Last updated: 2026-04-18. Kept in sync with `project.md`, `features.md`, `apple-developer-tasks.md`, `CLAUDE.md`, and the auto-memory index.*
