#!/bin/sh
# PreToolUse/Bash: no direct push to PROTECTED_BRANCHES, and no PR into
# PROMOTION_ONLY_BRANCHES unless its --head is in PROMOTION_HEADS.
. "$(dirname "$0")/lib.sh"
CMD=$(field tool_input.command)
[ -n "$CMD" ] || exit 0
CWD=$(field cwd)
[ -n "$CWD" ] || CWD=$ROOT
CURRENT=$(git -C "$CWD" symbolic-ref --short HEAD 2>/dev/null) || CURRENT=
SWITCHED=

protected() { in_list "$1" "$PROTECTED_BRANCHES"; }
stop() { deny "Blocked: no direct push to protected branch '$1'. Open a PR with /pr. A human decides what reaches production."; }

while IFS= read -r seg; do
  set -- $seg
  while [ $# -gt 0 ]; do
    case "$1" in *=*|sudo|env|command|time|then|do|else) shift ;; *) break ;; esac
  done
  case "${1:-}" in
    git|*/git)
      shift
      while [ $# -gt 0 ]; do
        case "$1" in -C|-c) shift; [ $# -gt 0 ] && shift ;; -*) shift ;; *) break ;; esac
      done
      case "${1:-}" in switch|checkout) SWITCHED=1 ;; esac
      [ "${1:-}" = push ] || continue
      shift
      n=0
      for t in "$@"; do
        case "$t" in
          --all|--mirror|--branches) [ -n "$PROTECTED_BRANCHES" ] && deny "Blocked: '$t' would push protected branches too. Push one topic branch." ;;
          -*) ;;
          *)
            n=$((n + 1))
            [ "$n" -gt 1 ] || continue     # first word is the remote
            b=${t#+}; b=${b##*:}; b=${b#refs/heads/}
            case "$b" in HEAD|@) [ -n "$SWITCHED" ] || b=$CURRENT ;; esac
            protected "$b" && stop "$b" ;;
        esac
      done
      if [ "$n" -lt 2 ] && [ -z "$SWITCHED" ] && protected "$CURRENT"; then stop "$CURRENT"; fi
      ;;
    gh|*/gh)
      [ "${2:-}" = pr ] && [ "${3:-}" = create ] || continue
      shift 3
      base= head=
      while [ $# -gt 0 ]; do
        case "$1" in
          --base=*) base=${1#*=} ;;
          --head=*) head=${1#*=} ;;
          -B=*) base=${1#*=} ;;
          -H=*) head=${1#*=} ;;
          --base|-B) base=${2:-} ;;
          --head|-H) head=${2:-} ;;
        esac
        shift
      done
      if [ -n "$base" ] && in_list "$base" "$PROMOTION_ONLY_BRANCHES" && ! in_list "$head" "$PROMOTION_HEADS"; then
        deny "Blocked: '$base' is promotion-only. Target the integration branch, or release with /ship."
      fi
      ;;
  esac
done <<SEGMENTS
$(segments "$CMD")
SEGMENTS
exit 0
