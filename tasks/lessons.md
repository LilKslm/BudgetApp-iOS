# BudgetApp — Lessons Log

> Append-only log of corrections, surprises, and self-improvement notes. Read at session start to avoid repeating mistakes.

Format for each entry:
```
## YYYY-MM-DD — Short title
**What happened:** (the mistake or surprise)
**Why:** (root cause)
**Rule going forward:** (prevention)
```

---

<!-- Add entries below. Most recent first. -->

## 2026-04-22 — Misdiagnosed a typo as a revoked RevenueCat key
**What happened:** RevenueCat launch logs showed `Invalid API Key` + `revoked` errors. I spent a full turn documenting the key as "rejected by backend — possibly revoked or belongs to a deleted project" in `apple-developer-tasks.md` and recommended the user regenerate the key. When the user pasted the actual key from the dashboard, it differed from the committed key by one character: `kfl` (lowercase l) vs `kfL` (uppercase L) at position 21. Case-sensitive typo, not a dashboard-side problem.
**Why:** Took RevenueCat's "revoked" wording at face value and jumped to a dashboard-level explanation without doing the cheapest check first: ask the user to paste the key shown in the dashboard and diff it against the committed string. An "invalid key" error from a provider could mean the key is wrong, revoked, expired, rate-limited, or for a different environment — "revoked" is just one hypothesis in that class.
**Rule going forward:** When a third-party auth/API error says "invalid key" / "revoked" / "unauthorized", before writing up a root-cause or recommending dashboard work, **diff the committed credential character-by-character against what the dashboard shows**. Ask the user to paste the exact value. Secrets strings are the one place a one-character typo can look identical at a glance — especially `l`/`I`/`1`, `O`/`0`, and case variants. This check costs one turn and eliminates the most common failure mode.

## 2026-04-22 — Wrote a lesson, failed to execute it on the spot
**What happened:** After fixing `LoginPlaceholderView`'s broken `as? MockAuthService` cast, I wrote a lesson saying *"when flipping a service default, grep every call site … dev-affordance buttons (one-tap login, seed-data, **skip-paywall**) are the highest-risk category."* I named the exact next failure, then moved on without grepping. Result: the user reported "skip paywall button doesn't work" in the next turn — `PaywallPlaceholderView` and `ProfileView.Toggle Pro` had the identical `as? MockPaymentService` cast I'd just diagnosed. Two debug affordances quietly broken since `a91ce3d`, predictable from the lesson I'd just written.
**Why:** Writing down a rule is not the same as executing it. Lessons are prospective ("future agents"), but the *present* agent — me — is the one with the grep tool open and the context loaded. Deferring execution to some future session is the worst time to apply a pattern-match lesson, because the pattern is freshest right now.
**Rule going forward:** Any lesson that names a *pattern* (not a one-off typo) is a work item for this turn, not just a note for later. Before writing the lesson, run the grep that the lesson prescribes. If the lesson says "grep every call site of X", do it before committing. Treat the lesson's rule as a checklist item you must execute, not just describe. If the grep surfaces more call sites, fix them in the same commit as the original bug — the two-fix commit is the proof the lesson stuck.

## 2026-04-22 — `FirebaseApp.app()` logs I-COR000003 when called pre-configure
**What happened:** Launch console showed `The default Firebase app has not yet been configured` between the "BudgetApp launched" log and "Firebase configured" log. The surprise was that nothing *looked* like it touched Firebase in that window — but the culprit was our own `FirebaseApp.app() == nil` existence check in `AppDelegate` that we added to guard against double-configure.
**Why:** FirebaseCore's `+[FIRApp defaultApp]` (what Swift's `FirebaseApp.app()` bridges to) logs `I-COR000003` whenever it runs before `configure()`, regardless of whether the caller cares about the result. A "just checking" accessor is not a silent accessor.
**Rule going forward:** Never probe Firebase state before `FirebaseApp.configure()`. `application(_:didFinishLaunchingWithOptions:)` runs exactly once per process — a pre-configure existence check is dead weight. If you need re-entrancy protection, track it in a Swift `Bool`, not via a FirebaseCore accessor.

## 2026-04-22 — Service-default flip desynced the dev-login button
**What happened:** Commit `a91ce3d` flipped Debug default from `MockAuthService` to `FirebaseAuthService`. The "Continue with mock user" button in `LoginPlaceholderView` kept calling `signIn(email: "demo@budgetapp.com", password: "mockpass")` — which mocks accept as truthy but real Firebase rejects with `userNotFound`. The error was swallowed by `try?`, so the button appeared to do nothing.
**Why:** The button was written when mocks were the default and its contract ("any credentials work") was implicit in the mock implementation. Flipping the container default changed the button's runtime behavior without changing its source, so a grep for "mock" wouldn't have surfaced it as affected.
**Rule going forward:** When flipping a service default (mock↔real), grep every call site of that service and check whether each caller's preconditions still hold under the new impl. Dev-affordance buttons (one-tap login, seed-data, skip-paywall) are the highest-risk category — they rely on implicit mock semantics. Also: **never `try?` a user-triggered action** — the user sees nothing and has no signal to retry. Either surface the error through the view model or at minimum log it.

## 2026-04-20 — SwiftUI emoji rendered as tofu with `.font(.system(size:))`
**What happened:** Emojis in `QuizOptionButton` rendered as empty squares ("square with ?") even though the string was built from valid codepoints via `Unicode.Scalar(UInt32)`. Three encoding approaches all rendered tofu (raw literal, `\u{...}` escape, runtime `Unicode.Scalar` construction).
**Why:** The string content was never the problem — runtime-constructed scalars are guaranteed valid. The real cause was font cascade: `.font(.system(size: 22))` with a fixed pixel size can fail to fall back to Apple Color Emoji in SwiftUI `Text`. Dynamic Type semantic styles (`.title2`, `.title`, `.largeTitle`) reliably trigger the color-emoji fallback.
**Rule going forward:** When rendering emoji-only `Text`, use a Dynamic Type style (`.font(.title2)` etc.), not `.font(.system(size:))`. Diagnose "tofu" as a rendering/font-cascade issue before assuming an encoding issue — `Unicode.Scalar(UInt32)` construction is proof the string is correct.

## 2026-04-20 — `body` stored property conflicts with `View` protocol
**What happened:** `HelpStepRow` had `let body: String` as a stored property and `var body: some View` as required by `View`. Swift sees two properties named `body` and errors.
**Why:** `body` is a reserved name in any `View` struct — it's the required computed property.
**Rule going forward:** Never name a stored property `body` inside a `View` struct. Use `detail`, `text`, `content`, or any other name.

## 2026-04-20 — `Color(hex:)` takes `UInt32`, not `String`
**What happened:** Used `Color(hex: "#10B981")` string literal in FeatureTourView and ReviewsView. The extension signature is `init(_ hex: UInt32)`.
**Why:** Assumed the hex extension accepted strings (like web CSS). It takes an integer literal.
**Rule going forward:** Always use `Color(hex: 0xRRGGBB)` hex integer literal. Never pass a `"#RRGGBB"` string. Better yet, define all colors in `AppTheme` and reference them by name — avoids the issue entirely.

## 2026-04-20 — Podfile `next unless` chaining silently kills subsequent fixes
**What happened:** `next unless target.name.start_with?('gRPC')` short-circuited the entire loop iteration before the `BoringSSL-GRPC` flag-strip block could run. CI masked this via a Python post-`pod install` patch. MacInCloud had no such patch, so `-GCC_WARN_INHIBIT_ALL_WARNINGS` survived and caused 5× `unsupported option '-G'` clang errors.
**Why:** Ruby `next` exits the current block iteration. Stacking `next unless` guards means only the first matching target gets through — any target that doesn't match the first guard never reaches subsequent checks.
**Rule going forward:** In `post_install` hooks, use **parallel `if` blocks** (one per target-specific fix), not a chain of `next unless` guards. Each fix is self-contained and cannot be short-circuited by unrelated target checks.
