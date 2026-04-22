#!/usr/bin/env bash
# Decode the base64-encoded GoogleService-Info.plist from the GS_INFO_B64 env var
# into BudgetApp/Resources/GoogleService-Info.plist.
#
# Idempotent: skips silently with a warning if GS_INFO_B64 is unset, so forks and
# PRs from contributors without the secret still build. The app then logs a warning
# at launch and disables Firebase (see SecretsLoader.warnIfFirebaseConfigMissing()).
#
# CI usage (see .github/workflows/build.yml):
#   env:
#     GS_INFO_B64: ${{ secrets.GS_INFO_B64 }}
#   run: bash scripts/decrypt-secrets.sh

set -euo pipefail

DEST="BudgetApp/Resources/GoogleService-Info.plist"

if [ -z "${GS_INFO_B64:-}" ]; then
  echo "GS_INFO_B64 not set — skipping GoogleService-Info.plist decode."
  echo "Build will proceed without Firebase config."
  exit 0
fi

mkdir -p "$(dirname "$DEST")"
echo "$GS_INFO_B64" | base64 --decode > "$DEST"

if [ ! -s "$DEST" ]; then
  echo "Decoded plist is empty — check GS_INFO_B64 encoding." >&2
  exit 1
fi

echo "Decoded GoogleService-Info.plist ($(wc -c < "$DEST") bytes)."
