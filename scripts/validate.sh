#!/usr/bin/env bash
# Full pre-publish check for this plugin.
#
# Why this exists rather than a bare `claude plugin validate .`:
# when a directory holds both .claude-plugin/marketplace.json and
# .claude-plugin/plugin.json, validate takes the marketplace branch. That
# branch checks the marketplace manifest and cascades into each entry's
# plugin.json, but it never walks the plugin's skills/ (or agents/, commands/).
# Our layout is exactly that shape, so a skill missing its frontmatter
# description passes `validate .` with exit 0 and fails only once a user
# installs it. `skills/` is therefore validated as its own path below.
#
# It also never reads .mcp.json at all — malformed JSON, a missing `type`, and
# a dangling mcpServers path all pass — so that file, which is the actual
# product, is checked here directly.

set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
step() { printf '\n\033[1m%s\033[0m\n' "$1"; }
ok() { printf '  ok — %s\n' "$1"; }
bad() {
	printf '  FAIL — %s\n' "$1"
	fail=1
}

step 'Manifests and components'
for target in .claude-plugin/plugin.json .claude-plugin/marketplace.json skills; do
	if claude plugin validate "$target" --strict; then
		ok "$target"
	else
		bad "$target"
	fi
done

step 'MCP pointer (claude plugin validate never reads this file)'
if python3 - <<'PY'; then
import json, sys

try:
    servers = json.load(open(".mcp.json"))["mcpServers"]
except Exception as exc:
    print(f"    .mcp.json did not parse: {exc}")
    sys.exit(1)

problems = []
for name, cfg in servers.items():
    if cfg.get("type") not in {"http", "streamable-http", "sse", "ws"}:
        problems.append(f"{name}: missing or unknown `type` — the server is skipped at load")
    if not cfg.get("url"):
        problems.append(f"{name}: missing `url`")
    for banned in ("headers", "env"):
        if banned in cfg:
            problems.append(f"{name}: `{banned}` present — this breaks the OAuth fallback")

for problem in problems:
    print(f"    {problem}")
sys.exit(1 if problems else 0)
PY
	ok '.mcp.json'
else
	bad '.mcp.json'
fi

step 'Prose the directories screen'
# Steering language the MCP server's own tests reject. The server guards its
# descriptions; nothing guards ours, and both are screened by the same review.
banned_phrases=(
	'prefer it over' 'do not default to' 'never ask' 'primary source'
	'hansard' 'parliamentlive' 'web search' 'members-api.parliament.uk'
)
hits=0
for phrase in "${banned_phrases[@]}"; do
	if grep -rniF --include='*.md' -- "$phrase" . >/dev/null 2>&1; then
		grep -rniF --include='*.md' -- "$phrase" .
		hits=1
	fi
done
[ "$hits" -eq 0 ] && ok 'no banned steering phrases' || bad 'banned steering phrase present'

step 'Identifiers and limits the server owns'
# Naming these couples our prose to a server that deploys separately, with
# nothing to catch the drift. Ordinary English "search"/"fetch" are fine.
hits=0
for id in 'parliament_connect_search_clips' 'public_url' 'private_url' 'search_type' '`search`' '`fetch`'; do
	if grep -rnF --include='*.md' -- "$id" . >/dev/null 2>&1; then
		grep -rnF --include='*.md' -- "$id" .
		hits=1
	fi
done
if grep -rnE --include='*.md' '\b(20 (per page|clips)|100 (matches|results|per query)|15,?000 char|top 10)\b' . >/dev/null 2>&1; then
	grep -rnE --include='*.md' '\b(20 (per page|clips)|100 (matches|results|per query)|15,?000 char|top 10)\b' .
	hits=1
fi
[ "$hits" -eq 0 ] && ok 'no server-owned identifiers or limits' || bad 'server-owned identifier or limit named'

printf '\n'
if [ "$fail" -eq 0 ]; then
	printf '\033[32mAll checks passed.\033[0m Still needs a human: sign in on each harness and read\n'
	printf 'every file for steering language a phrase list cannot catch.\n'
else
	printf '\033[31mChecks failed.\033[0m\n'
fi
exit "$fail"
