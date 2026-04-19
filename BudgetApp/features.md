# BudgetApp — Product Roadmap

> Product-specific vision, phase plan, feature list, and non-goals. Infrastructure lives in `project.md`; build lessons live in `appcreation.md`. This file is about **what we're shipping and why**.

---

## Vision

A **budget tracking app that feels like a game you're winning**. Users don't just log transactions — they watch their savings goals build visually, their debts shrink, their subscription waste get flagged. Inspired by Monarch, Buddy, Copilot, Rocket Money — but with gamified progress visualization as the signature differentiator.

## Target User

- US-first, English-first at launch.
- Millennial / Gen Z consumer who has tried to budget before and bounced.
- Single users **and** couples/roommates sharing finances.
- Users who want help but don't want to feel lectured. Tone: encouraging, not parental.

## Signature Differentiator

**Progressive goal visualizations.** For savings: the car, house, vacation, etc. builds itself as you contribute. For debt: a chain breaks link-by-link, a mountain is descended. This turns passive tracking into active progress-watching.

---

## Core Features

### Ship at MVP (Phases 1–6)

- **Manual transaction tracking** — amount, category, merchant, date, notes.
- **Multiple budgets** — per month, per label (Household, Business, Project), switchable.
- **Category breakdown** — "You spent $X on Electronics this month" with pie + bar views.
- **Subscriptions tracker** — manual entry, renewal reminders, total-monthly-cost card.
- **Savings goals** — name, target amount, target date, visual theme, contribution log.
- **Debt goals** — original amount, current balance, APR, min payment, visual theme.
- **Progressive goal visualizations** — 6 savings themes (Car, House, Vacation, Emergency/Piggy Bank, Wedding/Ring, Electronics/Laptop) + 2 debt themes (Chain-Breaker, Mountain-Descent).
- **Shared budgets** (Pro) — invite a partner via code/link, co-edit transactions, attribution per edit.
- **Paywall** (hard, post-onboarding) with standard + discounted variant.
- **Onboarding** — 10-question quiz → Results → Pain → How-We-Help → Reviews → Feature Tour → Custom Plan → Paywall.
- **Light + dark mode**, green-gradient accent system.

### Post-Enrollment (Tracked in `apple-developer-tasks.md`)

- **Plaid bank linking** — secure OAuth-based account connection, auto-imported transactions, auto-categorization.
- **Auto-subscription detection** — derived from Plaid recurring charges.
- **Push notifications** — goal milestones, shared-budget changes, subscription renewal alerts.
- **TestFlight / App Store distribution.**

### Later (Not MVP)

- Export to CSV (Pro).
- Recurring transaction templates.
- Bill-reminder system with push notifications.
- Net-worth dashboard (requires Plaid for asset accounts).
- Multi-currency.
- Localization beyond English.

---

## Non-Goals

These are intentionally **not** what BudgetApp is. If in doubt, decline.

- **Investment advice / brokerage.** We show data; we don't recommend trades.
- **Credit score monitoring.** Different product, different compliance.
- **Bill pay / money movement.** We surface info; we don't move funds.
- **Envelope budgeting purism.** YNAB owns that. We're flexible categorization.
- **Financial coaching chat.** Maybe later with an LLM — not MVP.
- **Business accounting.** Personal + household only.

---

## Phased Build Plan

Source: `C:\Users\khali\.claude\plans\read-the-appcreation-md-and-gentle-popcorn.md`. Summary:

| Phase | Scope |
|---|---|
| **1** | Scaffolding, AppTheme, mock services, MainTabView with placeholder screens. CI green. |
| **2** | Full onboarding flow (10-quiz + results + pain + how-we-help + reviews + tour + custom plan + notif + account + paywall) with mock state. |
| **3** | Firebase + RevenueCat + real services. Quiz answers sync to Firestore. |
| **4** | Core budgeting + goals + subscription UI + goal visualizations. **Biggest phase.** |
| **5** | Shared budgets (co-edit invite flow). |
| **6** | Polish — real icon, dark-mode QA, empty states, privacy manifest, App Store prep. |

**Rule: mock before real.** Every phase uses mocks first so UI + logic are complete before the network is wired.

---

## Pro Gating

**Free tier (genuinely useful, raises trial conversion):**
- Manual transactions
- One budget
- One savings goal + one debt goal
- Subscription tracker (manual)

**Pro:**
- Unlimited budgets + goals
- Shared budgets (co-edit)
- Plaid bank linking *(when it ships)*
- Auto-subscription detection *(when it ships)*
- CSV export *(post-MVP)*

---

## Identity (Placeholder)

- **Name:** `BudgetApp` — placeholder. Real name TBD.
- **Bundle ID:** `com.budgetapp.app` — will change with rename.
- **Icon:** solid green gradient 1024 PNG until commissioned art is ready.

Rename checklist when the real name is chosen:
- `project.yml` — app name, bundle ID, scheme
- Create new Firebase project with production bundle ID → swap `GoogleService-Info.plist`
- Update `Localizable.strings` `app.name` key
- Update `BudgetApp/` folder name
- Update CI workflow references
- Update App Store Connect app record (post-enrollment)
