#!/bin/sh
# PreToolUse/Bash: no manual access to PROD_HOSTS, and no BLOCKED_COMMANDS.
# Plain HTTP health checks (curl) stay allowed.
. "$(dirname "$0")/lib.sh"
CMD=$(field tool_input.command)
[ -n "$CMD" ] || exit 0

while IFS= read -r seg; do
  set -- $seg
  [ $# -gt 0 ] || continue
  remote=
  for t in "$@"; do
    case "$t" in
      ssh|scp|sftp|rsync|*/ssh|*/scp|*/sftp|*/rsync) remote=1 ;;
      DOCKER_HOST=*) remote=1 ;;
      docker|*/docker)
        case " $* " in *" -H"*|*" --host"*) remote=1 ;; esac ;;
    esac
  done
  if [ -n "$remote" ]; then
    for h in $PROD_HOSTS; do
      case "$*" in *"$h"*) deny "Blocked: no manual access to production host '$h'. Use the project's deploy method (CLAUDE.md, Deploy)." ;; esac
    done
  fi
  line=" $* "
  while IFS= read -r bad; do
    set -- $bad
    [ $# -gt 0 ] || continue
    case "$line" in *" $* "*) deny "Blocked: '$*' is listed in BLOCKED_COMMANDS. Ask the human to run it." ;; esac
  done <<BLOCKED
$BLOCKED_COMMANDS
BLOCKED
done <<SEGMENTS
$(segments "$CMD")
SEGMENTS
exit 0
