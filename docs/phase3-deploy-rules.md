# Phase 3 — Deploy Firestore Rules

Run once after Phase 3 is cloned on any machine with Node.js.

## One-time setup

```bash
npm install -g firebase-tools
firebase login
```

## Deploy rules

```bash
firebase deploy --only firestore:rules
```

## Verify in Firebase Console

After deploy, **always** confirm publication in the console — a silent `permission-denied`
in the app almost always means rules were not published:

1. Firebase Console → your project → Firestore Database → **Rules** tab
2. Confirm the rule set shown matches `firestore.rules` in this repo
3. Click **Publish** if it shows "Unsaved changes"

## Test in Rules Playground

In the Firebase Console Rules Playground, verify:

| Operation | Path | Auth UID matches doc UID | Expected |
|-----------|------|--------------------------|----------|
| `get` | `/users/abc` | `abc` (same) | ✅ allowed |
| `get` | `/users/abc` | `xyz` (different) | ❌ denied |
| `create` | `/users/abc` | `abc`, `data.id == "abc"` | ✅ allowed |
| `create` | `/users/abc` | `abc`, `data.id != "abc"` | ❌ denied |
| `get` | `/sharedBudgets/x` | any | ❌ denied |

## Firestore index notes

Phase 3 has no composite queries so no `firestore.indexes.json` is needed yet.
Add one when Phase 4 introduces list queries with `where` + `orderBy`.
