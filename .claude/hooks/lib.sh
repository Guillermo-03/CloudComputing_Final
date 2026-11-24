# Shared helpers for the guardrail hooks. Sourced, not run.
# Fail-open: anything that cannot be read or parsed allows the action (exit 0).
set -f
INPUT=$(cat)
ROOT=${CLAUDE_PROJECT_DIR:-}
CONF="$ROOT/.claude/guardrails.conf"
[ -n "$ROOT" ] && [ -f "$CONF" ] || exit 0
sh -n "$CONF" 2>/dev/null || exit 0      # a typo in the config must not block everything
. "$CONF"

field() {  # field <a.b> : read one value from the hook's JSON input
  v=$(printf '%s' "$INPUT" | jq -r ".$1 // empty" 2>/dev/null) || v=
  if [ -z "$v" ]; then
    v=$(printf '%s' "$INPUT" | python3 -c '
import sys, json
d = json.load(sys.stdin)
for k in sys.argv[1].split("."):
    d = d.get(k, "") if isinstance(d, dict) else ""
print(d or "")' "$1" 2>/dev/null) || v=
  fi
  printf '%s' "$v"
}

deny() { printf '%s\n' "$1" >&2; exit 2; }

in_list() {  # in_list <item> <space-separated list>
  for i in $2; do [ "$1" = "$i" ] && return 0; done
  return 1
}

# One simple command per line. Simple quoted words are unquoted ("main" -> main),
# other quoted text is dropped so commit messages are not mistaken for commands.
segments() {
  printf '%s' "$1" | tr '\n' '\001' | sed \
    -e 's/"\([A-Za-z0-9_.\/:+@=-]*\)"/\1/g' \
    -e "s/'\([A-Za-z0-9_.\/:+@=-]*\)'/\1/g" \
    -e 's/"[^"]*"//g' -e "s/'[^']*'//g" \
    -e 's/[0-9]*>[>&]*[[:space:]]*[A-Za-z0-9_.\/-]*//g' | tr '\001;&|()' '\n\n\n\n\n\n'
  printf '\n'
}

rel_path() {  # path of the edited file relative to the project root
  fp=$(field tool_input.file_path)
  [ -n "$fp" ] || fp=$(field tool_input.notebook_path)
  [ -n "$fp" ] || exit 0
  real=$(cd -P "$ROOT" 2>/dev/null && pwd)
  case "$fp" in
    "$ROOT"/*) printf '%s' "${fp#"$ROOT"/}" ;;
    "$real"/*) printf '%s' "${fp#"$real"/}" ;;
  esac
}
