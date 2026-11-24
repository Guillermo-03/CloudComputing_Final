#!/bin/sh
# PostToolUse/Edit: non-blocking reminders from REMINDERS ("glob|message" lines).
. "$(dirname "$0")/lib.sh"
REL=$(rel_path)
[ -n "$REL" ] || exit 0
MSG=
while IFS='|' read -r glob text; do
  [ -n "$glob" ] && [ -n "$text" ] || continue
  case "$REL" in $glob) MSG="$MSG$text " ;; esac
done <<REMIND
$REMINDERS
REMIND
[ -n "$MSG" ] || exit 0
esc=$(printf '%s' "$MSG" | tr '\t' ' ' | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$esc"
exit 0
