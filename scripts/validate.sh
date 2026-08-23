#!/usr/bin/env bash
# Full pre-publish check for this plugin.
#
# Why this exists rather than a bare `claude plugin validate .`:
# given a *directory* that holds both .claude-plugin/marketplace.json and
# .claude-plugin/plugin.json, validate takes the marketplace branch. That
# branch checks the marketplace manifest and cascades into each entry's
# plugin.json, but never walks the plugin's skills/, agents/ or commands/, so a
# skill missing its frontmatter description passes with exit 0 and fails only
# once a user installs it.
#
# Passing `.claude-plugin/plugin.json` *explicitly* does walk those component
# directories — that target is the one doing the real work here, not redundant
# with the directory form. The `skills` target is defence in depth.
#
# validate also never reads .mcp.json at all, and only warns (rather than
# erroring) on a description key that is present but blank. Both gaps are
# covered below in Python, along with the one value in the repo that has to be
# exactly right: the server URL.

set -uo pipefail
cd "$(dirname "$0")/.." || {
	echo "could not enter the repo root" >&2
	exit 2
}

fail=0
step() { printf '\n\033[1m%s\033[0m\n' "$1"; }
ok() { printf '  ok — %s\n' "$1"; }
bad() {
	printf '  FAIL — %s\n' "$1"
	fail=1
}

# grep has three exit codes and collapsing them fails open: 0 match, 1 no
# match, 2+ error. An unreadable path must not read as "clean".
scan() {
	local label="$1" out rc
	shift
	out=$("$@" 2>&1)
	rc=$?
	case "$rc" in
		0)
			printf '%s\n' "$out"
			bad "$label"
			;;
		1) ;;
		*) bad "$label — scan errored (grep exit $rc)" ;;
	esac
}

step 'Manifests and components'
# Targets come from the marketplace so this stays correct if a second plugin is
# added; the explicit plugin.json path is what walks skills/agents/commands.
mapfile -t plugin_manifests < <(python3 -c '
import json, pathlib
mk = json.load(open(".claude-plugin/marketplace.json"))
for entry in mk.get("plugins", []):
    src = entry.get("source")
    if isinstance(src, str):
        print(pathlib.PurePosixPath(src, ".claude-plugin/plugin.json"))
' 2>/dev/null)
if [ "${#plugin_manifests[@]}" -eq 0 ]; then
	bad 'marketplace.json listed no local plugin sources'
	plugin_manifests=(.claude-plugin/plugin.json)
fi
for target in "${plugin_manifests[@]}" .claude-plugin/marketplace.json skills; do
	if claude plugin validate "$target" --strict; then
		ok "$target"
	else
		bad "$target"
	fi
done

step 'Things claude plugin validate does not check'
if python3 - <<'PY'; then
import json, pathlib, sys
from urllib.parse import urlparse

EXPECTED_HOST = "parliamentconnect.com"
LOADABLE_TRANSPORTS = {"http", "streamable-http", "sse"}
problems = []

try:
    servers = json.load(open(".mcp.json"))["mcpServers"]
except Exception as exc:
    print(f"    .mcp.json did not parse: {exc}")
    sys.exit(1)

for name, cfg in servers.items():
    if cfg.get("type") not in LOADABLE_TRANSPORTS:
        problems.append(f"{name}: `type` missing or not a transport Claude Code loads — the server is skipped")
    url = urlparse(cfg.get("url") or "")
    if url.scheme != "https" or url.netloc != EXPECTED_HOST:
        problems.append(f"{name}: url must be https://{EXPECTED_HOST}/... — got {cfg.get('url')!r}")
    for banned in ("headers", "env"):
        if banned in cfg:
            problems.append(f"{name}: `{banned}` present — this breaks the OAuth fallback")

# validate only warns on a description key that exists but is blank, and says
# nothing at all about a plugin that ships no skills.
skills = sorted(pathlib.Path("skills").glob("*/SKILL.md"))
if not skills:
    problems.append("skills/: no SKILL.md found — the plugin ships no skills")
for skill in skills:
    text = skill.read_text(encoding="utf-8")
    if not text.startswith("---"):
        problems.append(f"{skill}: no frontmatter block")
        continue
    front = text.split("---", 2)[1]
    described = any(
        line.split(":", 1)[1].strip().strip("\"'").strip()
        for line in front.splitlines()
        if line.startswith("description:")
    )
    if not described:
        problems.append(f"{skill}: description missing or blank — it is what routes the skill")

for problem in problems:
    print(f"    {problem}")
sys.exit(1 if problems else 0)
PY
	ok 'MCP pointer, server URL, and skill descriptions'
else
	bad 'MCP pointer, server URL, or skill descriptions'
fi

# Prose the directories screen. The manifests' description fields are rendered
# in the directory listing, so they are scanned alongside the markdown.
targets=(.claude-plugin skills README.md)
step 'Steering language the directories reject'
banned_phrases=(
	'prefer it over' 'do not default to' 'never ask' 'primary source'
	'hansard' 'parliamentlive' 'web search' 'members-api.parliament.uk'
)
before=$fail
for phrase in "${banned_phrases[@]}"; do
	scan "banned phrase: $phrase" grep -rniF --include='*.md' --include='*.json' -- "$phrase" "${targets[@]}"
done
[ "$fail" -eq "$before" ] && ok 'none of the eight banned phrases present'

step 'Identifiers and limits the server owns'
# Naming these couples our prose to a server that deploys separately, with
# nothing to catch the drift. Ordinary English "search"/"fetch" are fine.
before=$fail
for id in 'parliament_connect_search_clips' 'public_url' 'private_url' 'search_type' '`search`' '`fetch`'; do
	scan "server-owned identifier: $id" grep -rnF --include='*.md' --include='*.json' -- "$id" "${targets[@]}"
done
scan 'server-owned limit' grep -rnE --include='*.md' --include='*.json' \
	-- '(20 (per page|clips)|100 (matches|results|per query)|15,?000 char|top 10)' "${targets[@]}"
[ "$fail" -eq "$before" ] && ok 'no server-owned identifiers or limits'

printf '\n'
if [ "$fail" -eq 0 ]; then
	cat <<'TXT'
All static checks passed.

This is not the whole pre-publish contract. Still to run by hand: install and
sign in on each harness, the skill behaviour probes, and a read-through for
steering language a phrase list cannot catch.
TXT
else
	printf '\033[31mChecks failed.\033[0m\n'
fi
exit "$fail"
