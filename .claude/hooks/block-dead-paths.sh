#!/bin/sh
# PreToolUse/Edit: no edits to DEAD_PATHS (legacy, generated, vendored).
. "$(dirname "$0")/lib.sh"
REL=$(rel_path)
[ -n "$REL" ] || exit 0
for p in $DEAD_PATHS; do
  case "$REL" in
    $p) deny "Blocked: $REL matches dead path '$p'. Edit the live source instead (CLAUDE.md, Project profile)." ;;
  esac
done
exit 0
