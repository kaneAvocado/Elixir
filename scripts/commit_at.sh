#!/usr/bin/env bash
# Usage: ./scripts/commit_at.sh "2026-01-13T19:30:00+03:00" "commit message" [paths...]
set -euo pipefail
DATE="${1:?date required}"
MSG="${2:?message required}"
shift 2
export GIT_AUTHOR_DATE="$DATE"
export GIT_COMMITTER_DATE="$DATE"
if [ "$#" -gt 0 ]; then
  git add "$@"
else
  git add -A
fi
git commit -m "$MSG"
