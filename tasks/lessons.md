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
