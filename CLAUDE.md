# BudgetApp — Claude Operational Rules

> Project-specific rules. These **override** defaults. Read before any non-trivial work.

## Source of Truth Hierarchy

1. `project.md` (workspace root) — **authoritative** iOS infrastructure blueprint.
2. `appcreation.md` (workspace root) — lessons learned, do/don't playbook.
3. `apple-developer-tasks.md` (workspace root) — every task blocked on the **paid** Apple Developer Program. Free-tier enrollment active as of 2026-04-21; see that file's "Current enrollment status" section for what the free tier unlocks.
4. `BudgetApp/features.md` — product-specific roadmap, phase plan, non-goals.
5. `BudgetApp/project.yml` — XcodeGen spec. `.xcodeproj` is **gitignored** and regenerated from this.
6. `tasks/todo.md` / `tasks/lessons.md` — current work + self-improvement log.
7. Auto-memory at `C:\Users\khali\.claude\projects\c--Users-khali-Desktop-Budgettracking\memory\MEMORY.md`.

When `project.md` conflicts with anything else, `project.md` wins.

## Environment

- **OS:** Windows 11. **No local Xcode.** Never run `xcodebuild`, `xcrun`, `pod install`, `xcodegen` locally.
- **Shell:** bash on Windows — Unix syntax (`/dev/null`, forward slashes).
- **Builds:**
  - CI: `.github/workflows/build.yml` on macos-15 runner with Xcode 16. Pipeline: `brew install xcodegen → xcodegen generate → pod install → xcodebuild`.
  - MacInCloud: manual visual verification. Always use the full command block from `appcreation.md §2` verbatim.

## Tech Stack (Non-Negotiable)

- SwiftUI, iOS 17 deployment (iOS 16 floor available).
- **CocoaPods, NOT SPM** — Xcode 26 beta SPM static frameworks fail bundle validation (see `appcreation.md §12.3`).
- Firebase: Auth, Firestore, Analytics, Crashlytics.
- RevenueCat (entitlement: `pro`).
- MVVM + protocol-based DI. Every service has a protocol + mock.
- `async/await` throughout. Callbacks banned.
- All errors funnel through `AppError`.
- All design tokens in `AppTheme`. No hardcoded hex.

## Workflow Rules

1. **Plan mode for ANY non-trivial task** (3+ steps or architectural decisions).
2. **Subagents liberally** for exploration/research to keep main context clean.
3. **Self-improvement loop** — after any user correction, append to `tasks/lessons.md` with the pattern and the why.
4. **Verification before done** — never mark complete without proof. CI green + MacInCloud visual verification.
5. **Demand elegance (balanced)** — pause on non-trivial changes and ask if there's a more elegant way. Don't over-engineer simple fixes.
6. **Autonomous bug fixing** — given a bug report, just fix it. Point at logs/errors, resolve.

## Task Management

1. Plan → write to `tasks/todo.md` with checkable items.
2. Verify plan → check in before implementing.
3. Track progress → mark items as you go.
4. Explain changes → high-level summary per step.
5. Document results → add review section to `tasks/todo.md`.
6. Capture lessons → update `tasks/lessons.md` after any correction.

## Critical Don'ts (from `appcreation.md §14`)

- **DON'T** run Xcode commands locally on Windows.
- **DON'T** claim UI works without MacInCloud visual verification.
- **DON'T** open `.xcodeproj` — always `.xcworkspace`.
- **DON'T** commit `.xcodeproj` — it's gitignored, regenerated from `project.yml`.
- **DON'T** edit `BudgetApp/Resources/Info.plist` directly — add keys to `project.yml`'s `info.plist` dict.
- **DON'T** use SPM.
- **DON'T** hardcode hex colors in views — use `AppTheme`.
- **DON'T** touch root collections (`sharedBudgets`, `budgetInvites`) from a ViewModel — go through `SharingService`.
- **DON'T** instantiate `UIFeedbackGenerator` directly — use `HapticService`.
- **DON'T** use callbacks — use `async/await`.
- **DON'T** force-unwrap — use `guard let` + `throw`.
- **DON'T** scatter Apple-Developer-blocked tasks — they go in `apple-developer-tasks.md`.
- **DON'T** forget to republish Firestore rules after editing `firestore.rules`.

## Core Principles

- **Simplicity first.** Minimal code impact per change.
- **No laziness.** Find root causes. No temporary fixes. Senior-engineer standards.
- **Mock-first.** Build each phase against mocks; swap real services in the phase where they belong.
