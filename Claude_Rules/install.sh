#!/bin/sh
# Install this kit into a project. Never overwrites your files.
#   sh Claude_Rules/install.sh              folder copied into a git project's root
#   sh Claude_Rules/install.sh /some/path   any other target
set -eu
SRC=$(cd "$(dirname "$0")" && pwd)
if [ $# -gt 0 ]; then
  [ -d "$1" ] || { echo "Not a folder: $1" >&2; exit 1; }
  T=$(cd "$1" && pwd)
else
  T=$(dirname "$SRC")
  [ -e "$T/.git" ] || { echo "$T is not a git root. If it is the right target, run: sh \"$SRC/install.sh\" \"$T\"" >&2; exit 1; }
fi
[ "$T" != "$HOME" ] && [ "$T" != / ] && [ "$T" != "$SRC" ] || { echo "Refusing to install into $T" >&2; exit 1; }

put() {
  if [ -e "$2" ]; then
    cmp -s "$1" "$2" || echo "kept existing: $2"
  else
    mkdir -p "$(dirname "$2")"; cp "$1" "$2"; echo "added: $2"
  fi
}

cd "$SRC"
find skills agents hooks -type f ! -name .DS_Store | while IFS= read -r f; do put "$f" "$T/.claude/$f"; done
put CLAUDE.template.md "$T/.claude/CLAUDE.template.md"
put guardrails.conf.template "$T/.claude/guardrails.conf"
if [ -e "$T/CLAUDE.md" ]; then
  echo "kept existing: $T/CLAUDE.md (/setup will merge the template)"
else
  put CLAUDE.template.md "$T/CLAUDE.md"
fi

S="$T/.claude/settings.json"
if [ ! -e "$S" ]; then
  put settings.template.json "$S"
elif command -v python3 >/dev/null 2>&1; then
  python3 - "$S" settings.template.json <<'PY' || { echo "Could not merge $S; left unchanged. Add the hooks from settings.template.json by hand." >&2; exit 1; }
import json, shutil, sys, time
path, kit = sys.argv[1:]
cur, new = json.load(open(path)), json.load(open(kit))
hooks, changed = cur.setdefault("hooks", {}), False
for event, groups in new["hooks"].items():
    have = {h.get("command") for g in hooks.get(event, []) for h in g.get("hooks", [])}
    for g in groups:
        todo = [h for h in g["hooks"] if h["command"] not in have]
        if todo:
            hooks.setdefault(event, []).append({"matcher": g["matcher"], "hooks": todo})
            changed = True
if changed:
    backup = path + ".bak-" + time.strftime("%Y%m%d%H%M%S")
    shutil.copy2(path, backup)
    text = json.dumps(cur, indent=2) + "\n"
    open(path, "w").write(text)
    print("merged hooks into:", path, "(backup:", backup + ")")
PY
else
  echo "python3 not found: add the hooks from settings.template.json to $S by hand." >&2; exit 1
fi
command -v jq >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1 || echo "WARNING: hooks need jq or python3; without them they allow everything." >&2
sh "$T/.claude/hooks/test_hooks.sh" || { echo "Hook tests failed: do not rely on the guardrails." >&2; exit 1; }
echo "Done. Restart Claude Code in $T and run /setup. You can then delete the copied kit folder."
