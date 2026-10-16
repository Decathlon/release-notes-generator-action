#!/bin/sh
# Exercise the action entrypoint without Docker, a JVM, network access or credentials.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d "${TMPDIR:-/tmp}/release-notes-test.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP/bin" "$TMP/home"
# Only relocate the container's JSON parser; all entrypoint logic is unchanged.
sed "s|/JSON.sh|$ROOT/JSON.sh|g" "$ROOT/entrypoint.sh" > "$TMP/entrypoint.sh"
cat > "$TMP/bin/java" <<'MOCK'
#!/bin/sh
set -eu
printf '%s\n' "$@" > "$ARGS"
# java -jar <jar>, five options, milestone number and output filename.
[ "$#" -eq 9 ] || exit 64
[ "$1" = '-jar' ]
[ "$2" = '/github-release-notes-generator.jar' ]
[ "$3" = '--changelog.repository=fixture-owner/fixture-repo' ]
[ "$4" = '--github.username=fixture-user' ]
[ "$5" = '--github.password=fixture-not-a-token' ]
[ "$6" = '--changelog.milestone-reference=id' ]
printf '# Synthetic release notes\n' > "$9"
MOCK
chmod +x "$TMP/bin/java"
cat > "$TMP/milestone.json" <<'JSON'
{"action":"closed","milestone":{"number":2,"title":"Sprint 10"},"repository":{"name":"fixture-repo","owner":{"login":"fixture-owner"}},"sender":{"login":"fixture-user"}}
JSON
cat > "$TMP/dispatch.json" <<'JSON'
{"inputs":{"milestoneId":"3"},"repository":{"name":"fixture-repo","owner":{"login":"fixture-owner"}},"sender":{"login":"fixture-user"}}
JSON
sed 's/"closed"/"opened"/' "$TMP/milestone.json" > "$TMP/opened.json"
printf '{}\n' > "$TMP/missing.json"
run() {
    name=$1; event=$2; payload=$3; shift 3
    mkdir -p "$TMP/$name"
    (
        cd "$TMP/$name"
        env -i HOME="$TMP/home" PATH="$TMP/bin:/usr/bin:/bin" \
            GITHUB_EVENT_NAME="$event" GITHUB_EVENT_PATH="$TMP/$payload.json" \
            GITHUB_TOKEN=fixture-not-a-token ARGS="$TMP/$name/args" \
            "$@" sh "$TMP/entrypoint.sh"
    ) > "$TMP/$name/log" 2>&1 || {
        result=$?
        printf '%s: exit %s\n' "$name" "$result" >&2
        return "$result"
    }
}
check() {
    name=$1; output=$2; milestone=$3
    test "$(tail -n 2 "$TMP/$name/args" | head -n 1)" = "$milestone"
    test "$(tail -n 1 "$TMP/$name/args")" = "$output"
    test "$(cat "$TMP/$name/$output")" = '# Synthetic release notes'
    grep -q '^# Synthetic release notes$' "$TMP/$name/log"
}
run default milestone milestone
check default ./release_file.md 2
run title milestone milestone USE_MILESTONE_TITLE=true
check title ./Sprint_10.md 2
run prefix milestone milestone FILENAME_PREFIX=MyMilestone
check prefix ./MyMilestone2.md 2
run filename milestone milestone FILENAME='Release notes' USE_MILESTONE_TITLE=true
check filename './Release notes.md' 2
run folder milestone milestone OUTPUT_FOLDER='release notes/nested folder'
check folder 'release notes/nested folder/release_file.md' 2
run combined milestone milestone OUTPUT_FOLDER='release notes' FILENAME='Sprint notes' FILENAME_PREFIX='Team '
check combined 'release notes/Team Sprint notes.md' 2
run dispatch workflow_dispatch dispatch
check dispatch ./release_file.md 3
run override workflow_dispatch dispatch MILESTONE_NUMBER=4
check override ./release_file.md 4
mkdir -p "$TMP/config/.github"
printf 'changelog:\n  sections: []\n' > "$TMP/config/.github/release-notes.yml"
run config milestone milestone
grep -qx -- '--spring.config.location=.github/release-notes.yml' "$TMP/config/args"
check config ./release_file.md 2
status=0
run opened milestone opened || status=$?
test "$status" -eq 78
test ! -e "$TMP/opened/args"
status=0
run missing milestone missing || status=$?
test "$status" -eq 1
test ! -e "$TMP/missing/args"
echo 'PASS: 11 isolated entrypoint cases (mock Java CLI; no network)'
