#!/bin/sh
# Tests the hooks in a throwaway project: sh .claude/hooks/test_hooks.sh
H=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
export CLAUDE_PROJECT_DIR="$T/my project"
P=$CLAUDE_PROJECT_DIR
mkdir -p "$P/.claude"
git init -q "$P"; git -C "$P" symbolic-ref HEAD refs/heads/feat/x
cat > "$P/.claude/guardrails.conf" <<'C'
PROTECTED_BRANCHES="main staging"
PROMOTION_ONLY_BRANCHES="main"
PROMOTION_HEADS="staging"
PROD_HOSTS="203.0.113.10"
BLOCKED_COMMANDS="
firebase deploy
"
DEAD_PATHS="dist/* *.gen.ts"
REMINDERS="
src/auth/*|Sensitive: run \"self-review\"
"
C
pass=0 fail=0
ok() { if [ "$1" = "$2" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL ($3): expected $1, got $2"; fi; }
run() {  # run <expected> <hook> <key> <value>
  v=$(printf '%s' "$4" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | awk 'NR>1{printf "\\n"}{printf "%s",$0}')
  printf '{"tool_input":{"%s":"%s"}}' "$3" "$v" | sh "$H/$2.sh" >/dev/null 2>&1
  ok "$1" $? "$4"
}
b() { run "$1" block-protected-branches command "$2"; }
p() { run "$1" block-prod-access command "$2"; }
d() { run "$1" block-dead-paths file_path "$2"; }
b 2 'git push origin main'
b 2 'git push origin "main"'
b 2 'git push -f origin HEAD:main'
b 2 'git push origin +main'
b 2 'git push origin refs/heads/main'
b 2 'git push origin :main'
b 2 'git -C . push origin staging'
b 2 'cd x && git push origin main 2>&1'
b 2 'git push --all origin'
b 2 'git add a
git push origin main'
b 0 'git push -u origin HEAD'
b 0 'git push'
b 0 'git push origin feat/main'
b 0 'git push origin main-fix'
b 0 'git commit -m "git push origin main"'
b 0 'git push origin feat/x && git checkout main'
b 0 'git status'
b 2 'gh pr create --base main --fill'
b 2 'gh pr create -B main'
b 0 'gh pr create --base staging --fill'
b 0 'gh pr create --base main --head staging --fill'
b 0 'gh pr merge 3 --merge'
git -C "$P" symbolic-ref HEAD refs/heads/main
b 2 'git push'
b 2 'git push -u origin HEAD'
b 0 'git switch -c feat/y && git push -u origin HEAD'
p 2 'ssh root@203.0.113.10'
p 2 'ssh "root@203.0.113.10" "uptime"'
p 2 'rsync -a . root@203.0.113.10:/srv'
p 2 'DOCKER_HOST=ssh://203.0.113.10 docker ps'
p 2 'docker -H tcp://203.0.113.10 ps'
p 2 'npx firebase deploy --only hosting'
p 0 'curl https://203.0.113.10/health'
p 0 'ssh other.example.com'
p 0 'firebase serve'
p 0 'git commit -m "document firebase deploy"'
d 2 "$P/dist/app.js"
d 2 "$P/src/api.gen.ts"
d 0 "$P/src/app.ts"
d 0 "/elsewhere/dist/app.js"
run 2 block-dead-paths notebook_path "$P/dist/n.ipynb"
out=$(printf '{"tool_input":{"file_path":"%s"}}' "$P/src/auth/a.ts" | sh "$H/remind-on-edit.sh")
case "$out" in *'run \"self-review\"'*) r=0 ;; *) r=1 ;; esac
ok 0 $r "reminder shown"
out=$(printf '{"tool_input":{"file_path":"%s"}}' "$P/src/b.ts" | sh "$H/remind-on-edit.sh")
ok "" "$out" "no reminder elsewhere"
printf 'not json' | sh "$H/block-prod-access.sh" >/dev/null 2>&1; ok 0 $? "bad input allows"
echo 'X="unclosed' > "$P/.claude/guardrails.conf"; b 0 'git push origin main'
rm "$P/.claude/guardrails.conf"; b 0 'git push origin main'
echo "hooks: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
