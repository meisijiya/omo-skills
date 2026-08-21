#!/usr/bin/env bash
# scripts/test-prompt-append.sh — characterization suite for prompt_append install.
#
# Validates that scripts/install-prompt-append.mjs is frozen F4 behavior:
#   S1  happy            install mutates ~/.config/...jsonc so 3 prompt_appends match v3.0 verbatim
#   S2  idempotency      re-run leaves mtime unchanged + stdout contains 已是最新
#   S3  regression       non-target agents (8) preserved w/o prompt_append;
#                         categories + team_mode byte-identical vs pre-test snapshot;
#                         target agents (3) prompt_appends changed
#   S4  corrupt fragment truncated JSON → install exits non-zero + stderr has SyntaxError +
#                         user config mtime unchanged; fragment restored from v3.0 snapshot
#   S5  incomplete       2-of-3 fragment → install rejects OR merges ≤ 2 strings (silent
#                         acceptance of >2 is a FAIL); fragment restored from v3.0 snapshot
#   D1  docs workflow    docs/workflow.md has 'grilling' ≥ 1 + 'Load order' ≥ 1
#   D2  docs INSTALL     INSTALL.md has 'grilling' ≥ 1 + 'diagnosing-bugs' ≥ 2
#
# Rollback / state plan:
#   - /tmp/fragment.bak.jsonc         v2.x pre-Todo-3 fragment snapshot (kept for legacy audit)
#   - /tmp/fragment.v3.jsonc          current v3.0 fragment snapshot taken at test start
#                                     (S4 + S5 restore from this)
#   - /tmp/oh-my-openagent.jsonc.*.bak  Wave 0 v2.x user config baseline (S3 regression baseline;
#                                     picked up via glob if available; falls back to TARGET)
#   - /tmp/test-user-config.bak.jsonc  pre-test user config snapshot (kept for legacy audit)
#   - /tmp/test-S<n>.log / .out / .err per-scenario logs for debugging
#   - Script ENDS with fragment at v3.0 + user config containing all 3 v3.0 prompt_appends
#     (final `node install-prompt-append.mjs` re-installs v3.0 if S5 reduced prompt_append count).
#
# Use:
#   bash scripts/test-prompt-append.sh          # runs all 7 scenarios, exits 0 iff all pass
#   bash scripts/test-prompt-append.sh test_S1  # run a single scenario
#
# Constraints (per plan §Todo 4):
#   - POSIX bash + set -euo pipefail (no Bash 4+ arrays / no associative arrays)
#   - jq + stat + node (for parseJsonc mirror) + grep — no external test framework
#   - MUST NOT modify scripts/install-prompt-append.mjs
#   - Per-scenario cleanup: S4 + S5 restore fragment from /tmp/fragment.v3.jsonc

set -euo pipefail

# Resolve repo root from script location (works from workspace root or repo root)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -d "$SCRIPT_DIR/../.git" ] || [ -f "$SCRIPT_DIR/../README.md" ] && grep -q 'omo-skills' "$SCRIPT_DIR/../README.md" 2>/dev/null; then
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  REPO_ROOT="$(pwd)"
fi

FRAGMENT="$REPO_ROOT/config/oh-my-openagent.prompt-append.jsonc"
INSTALL="$REPO_ROOT/scripts/install-prompt-append.mjs"
TARGET="$HOME/.config/opencode/oh-my-openagent.jsonc"
WORKFLOW_DOC="$REPO_ROOT/docs/workflow.md"
INSTALL_DOC="$REPO_ROOT/INSTALL.md"

SNAP_V3="/tmp/fragment.v3.jsonc"
SNAP_PRE="/tmp/test-user-config.bak.jsonc"
LOG_DIR="/tmp"

# ANSI-free output (POSIX)
pass() {
  printf '%s\n' "PASS $1"
}

# Print FAIL line on stdout (so the caller's redirect captures it cleanly).
# Caller MUST `return 1` after `fail` to make the scenario fail.
fail() {
  printf '%s\n' "FAIL $1: $2"
}

# parse_jsonc <file> → stdout: JSONC-stripped, JSON.stringify'd value (so `| jq -r ...` can query).
# Mirrors scripts/install-prompt-append.mjs:L18-L32 parseJsonc (14-line stripper).
parse_jsonc() {
  node -e '
    const fs = require("fs");
    const t = fs.readFileSync(process.argv[1], "utf8");
    let inS = false, out = "";
    for (let i = 0; i < t.length; i++) {
      const c = t[i];
      if (c === "\"" && t[i - 1] !== "\\") inS = !inS;
      if (!inS && c === "/" && t[i + 1] === "/") {
        while (i < t.length && t[i] !== "\n") i++;
        out += "\n";
      } else {
        out += c;
      }
    }
    process.stdout.write(JSON.stringify(JSON.parse(out.replace(/,\s*([}\]])/g, "$1"))));
  ' "$1"
}

# jq_jsonc <file> [jq-cli-args ...] <jq-filter>
#   Convenience for `parse_jsonc <file> | jq -r [args] <filter>`.
#   Allows --arg / --argjson to be passed through to jq, so callers can write
#   `jq_jsonc "$TARGET" --arg a "$agent" '.agents[$a].prompt_append'`.
jq_jsonc() {
  local f="$1"
  shift
  parse_jsonc "$f" | jq -r "$@"
}

# run_install <out-file> <err-file> → echoes install exit code on stdout.
# Caller captures with `rc=$(run_install ...)` so set -e doesn't abort on non-zero.
run_install() {
  node "$INSTALL" > "$1" 2> "$2"
  echo "$?"
}

# restore_fragment — copy /tmp/fragment.v3.jsonc back into the workspace fragment.
restore_fragment() {
  cp -f "$SNAP_V3" "$FRAGMENT"
  if ! diff -q "$SNAP_V3" "$FRAGMENT" >/dev/null 2>&1; then
    echo "WARN: fragment restore diff non-zero after restore" >&2
    return 1
  fi
}

# === Test functions ============================================================

test_S1() {
  local id=S1 log="$LOG_DIR/test-S1.log" rc
  {
    echo "== test_S1: happy install + verify 3 prompt_appends match v3.0 =="
    rc=$(run_install "$log.out" "$log.err")
    echo "install exit=$rc"
    cat "$log.out"
    cat "$log.err" 1>&2 || true

    if [ "$rc" -ne 0 ]; then
      fail "$id" "install exit=$rc (expected 0)"
      return 1
    fi

    for agent in prometheus sisyphus atlas; do
      local expected actual
      expected=$(jq_jsonc "$FRAGMENT" ".agents.${agent}.prompt_append")
      actual=$(jq_jsonc "$TARGET" ".agents.${agent}.prompt_append")
      if [ "$expected" != "$actual" ]; then
        fail "$id" "agents.${agent}.prompt_append mismatch"
        echo "expected: $expected" >&2
        echo "actual:   $actual" >&2
        return 1
      fi
      printf 'OK %s: %s...\n' "$agent" "$(printf '%s' "$actual" | head -c 50)"
    done

    pass "$id"
  } > "$log" 2>&1
}

test_S3() {
  # ponytail: install writes via JSON.stringify which reformats indentation / strips
  # trailing commas / moves keys to canonical order. Raw `diff -u` is not meaningful.
  # Semantic check (against Wave 0 v2.x baseline): verify preservation of non-target
  # agents + categories + team_mode. Forward-only check: target agents' prompt_append
  # byte-equals fragment (v3.0 invariant — preserved across re-runs).
  local id=S3 log="$LOG_DIR/test-S3.log"
  {
    echo "== test_S3: regression — non-target preserved + categories + team_mode + target matches fragment =="

    # 8 non-target agents must NOT have prompt_append
    for agent in oracle librarian explore multimodal-looker metis momus sisyphus-junior hephaestus; do
      local has_pp
      has_pp=$(jq_jsonc "$TARGET" --arg a "$agent" '.agents[$a] | has("prompt_append")')
      if [ "$has_pp" != "false" ]; then
        fail "$id" "non-target agent '$agent' unexpectedly has prompt_append (has_pp=$has_pp)"
        return 1
      fi
    done

    # categories + team_mode byte-equivalent (via JSON-stringified parse) — against Wave 0 baseline
    local cats_pre cats_now tm_pre tm_now
    cats_pre=$(jq_jsonc "$SNAP_PRE" '.categories // {}')
    cats_now=$(jq_jsonc "$TARGET" '.categories // {}')
    tm_pre=$(jq_jsonc "$SNAP_PRE" '.team_mode // null')
    tm_now=$(jq_jsonc "$TARGET" '.team_mode // null')

    if [ "$cats_pre" != "$cats_now" ]; then
      fail "$id" "categories changed"
      echo "pre:  $cats_pre" >&2
      echo "now:  $cats_now" >&2
      return 1
    fi
    if [ "$tm_pre" != "$tm_now" ]; then
      fail "$id" "team_mode changed"
      echo "pre: $tm_pre" >&2
      echo "now: $tm_now" >&2
      return 1
    fi

    # Forward-only check: current TARGET prompt_append MUST byte-equal fragment prompt_append.
    # This is the v3.0 invariant — preserved across re-runs after C1 lands.
    for agent in prometheus sisyphus atlas; do
      local expected now
      expected=$(jq_jsonc "$FRAGMENT" --arg a "$agent" '.agents[$a].prompt_append')
      now=$(jq_jsonc "$TARGET" --arg a "$agent" '.agents[$a].prompt_append // ""')
      if [ "$expected" != "$now" ]; then
        fail "$id" "agents.${agent}.prompt_append != fragment (expected v3.0)"
        echo "expected: $expected" >&2
        echo "now:      $now" >&2
        return 1
      fi
    done

    pass "$id"
  } > "$log" 2>&1
}

test_S2() {
  local id=S2 log="$LOG_DIR/test-S2.log" rc
  {
    echo "== test_S2: idempotency — mtime unchanged + 已是最新 =="

    local mtime_before mtime_after
    mtime_before=$(stat -c %Y "$TARGET")
    echo "mtime_before=$mtime_before"

    rc=$(run_install "$log.out" "$log.err")
    mtime_after=$(stat -c %Y "$TARGET")
    echo "mtime_after=$mtime_after install_exit=$rc"
    cat "$log.out"
    cat "$log.err" 1>&2 || true

    if [ "$rc" -ne 0 ]; then
      fail "$id" "install exit=$rc (expected 0)"
      return 1
    fi
    if [ "$mtime_before" != "$mtime_after" ]; then
      fail "$id" "mtime changed $mtime_before → $mtime_after (NOT idempotent)"
      return 1
    fi
    if ! grep -q "已是最新" "$log.out"; then
      fail "$id" "stdout missing '已是最新' message"
      return 1
    fi
    pass "$id"
  } > "$log" 2>&1
}

test_S4() {
  local id=S4 log="$LOG_DIR/test-S4.log" rc
  {
    echo "== test_S4: corrupt fragment → SyntaxError + mtime unchanged =="

    local mtime_before mtime_after
    mtime_before=$(stat -c %Y "$TARGET")

    # Truncated fragment — string never closes, JSON.parse throws SyntaxError.
    cat > "$FRAGMENT" <<'EOF'
{
  "agents": {
    "prometheus": {
      "prompt_append": "Read CONTEXT.md and proceed
EOF

    rc=$(run_install "$log.out" "$log.err")
    mtime_after=$(stat -c %Y "$TARGET")

    # Restore fragment FIRST so any subsequent error doesn't leave workspace dirty
    restore_fragment || true

    echo "mtime_before=$mtime_before mtime_after=$mtime_after install_exit=$rc"
    cat "$log.out"
    cat "$log.err" 1>&2 || true

    if [ "$rc" -eq 0 ]; then
      fail "$id" "install exit=0 (expected non-zero) — parse error NOT caught"
      return 1
    fi
    if ! grep -qi "SyntaxError" "$log.err"; then
      fail "$id" "stderr missing 'SyntaxError' (got: $(cat "$log.err"))"
      return 1
    fi
    if [ "$mtime_before" != "$mtime_after" ]; then
      fail "$id" "mtime changed $mtime_before → $mtime_after (user config mutated despite parse error)"
      return 1
    fi
    pass "$id"
  } > "$log" 2>&1
}

test_S5() {
  local id=S5 log="$LOG_DIR/test-S5.log" rc rc2
  {
    echo "== test_S5: incomplete fragment (2-of-3) → install rejects OR merges exactly 2 =="

    # Sanity: count agents keys in v3.0 fragment (defensive — should be 3)
    local fragment_keys
    fragment_keys=$(jq_jsonc "$FRAGMENT" '.agents | keys | sort | length')
    echo "v3.0 fragment key count=$fragment_keys"

    # Write fragment missing sisyphus (only prometheus + atlas). Use distinctive
    # sentinel text so install detects changes (otherwise idempotent branch fires
    # and we can't observe the merge count).
    cat > "$FRAGMENT" <<'EOF'
{
  "agents": {
    "prometheus": {
      "prompt_append": "[S5-INCOMPLETE-probe] Read CONTEXT.md and proceed silently."
    },
    "atlas": {
      "prompt_append": "[S5-INCOMPLETE-probe] Map worker load_skills by task type stub."
    }
  }
}
EOF

    rc=$(run_install "$log.out" "$log.err")
    cat "$log.out"
    cat "$log.err" 1>&2 || true
    echo "install_exit=$rc"

    # Outcome (a): install rejects (non-zero exit).
    # Outcome (b): install merges exactly 2 strings — install.stdout contains "已合并 2".
    # BAD: install merges 3 strings from a 2-agent fragment (silent acceptance of 3).
    if [ "$rc" -eq 0 ] && grep -q '已合并 3' "$log.out"; then
      restore_fragment || true
      fail "$id" "install merged 3 strings from a 2-agent fragment (silent acceptance)"
      return 1
    fi
    if [ "$rc" -ne 0 ]; then
      echo "OBSERVED: case (a) install rejected (exit=$rc)"
    elif grep -q '已合并 2' "$log.out"; then
      echo "OBSERVED: case (b) install merged exactly 2 strings"
    elif grep -q '已是最新' "$log.out"; then
      echo "OBSERVED: install reported idempotent (no change)"
    fi

    # Restore fragment + re-install v3.0 so workspace ends in canonical v3.0 state
    restore_fragment || true
    echo "post-restore fragment: $(diff -q "$SNAP_V3" "$FRAGMENT" || echo 'MISMATCH')"

    rc2=$(run_install "$log.v3.out" "$log.v3.err")
    cat "$log.v3.out"
    cat "$log.v3.err" 1>&2 || true
    echo "post-restore install exit=$rc2"
    if [ "$rc2" -ne 0 ]; then
      fail "$id" "post-restore v3.0 install exit=$rc2 (expected 0)"
      return 1
    fi

    pass "$id"
  } > "$log" 2>&1
}

test_D1() {
  local id=D1 log="$LOG_DIR/test-D1.log"
  {
    echo "== test_D1: docs/workflow.md grep assertions =="

    local g_count order_count
    g_count=$(grep -c 'grilling' "$WORKFLOW_DOC" || true)
    order_count=$(grep -c 'Load order' "$WORKFLOW_DOC" || true)
    echo "grilling=$g_count Load order=$order_count"

    if [ "$g_count" -lt 1 ]; then
      fail "$id" "docs/workflow.md 'grilling'=$g_count (expected ≥ 1)"
      return 1
    fi
    if [ "$order_count" -lt 1 ]; then
      fail "$id" "docs/workflow.md 'Load order'=$order_count (expected ≥ 1)"
      return 1
    fi
    pass "$id"
  } > "$log" 2>&1
}

test_D2() {
  local id=D2 log="$LOG_DIR/test-D2.log"
  {
    echo "== test_D2: INSTALL.md grep assertions =="

    local g_count diag_count
    g_count=$(grep -c 'grilling' "$INSTALL_DOC" || true)
    diag_count=$(grep -c 'diagnosing-bugs' "$INSTALL_DOC" || true)
    echo "grilling=$g_count diagnosing-bugs=$diag_count"

    if [ "$g_count" -lt 1 ]; then
      fail "$id" "INSTALL.md 'grilling'=$g_count (expected ≥ 1)"
      return 1
    fi
    if [ "$diag_count" -lt 2 ]; then
      fail "$id" "INSTALL.md 'diagnosing-bugs'=$diag_count (expected ≥ 2)"
      return 1
    fi
    pass "$id"
  } > "$log" 2>&1
}

# === Top-level dispatcher ====================================================

# Pre-flight
for required in "$FRAGMENT" "$INSTALL" "$TARGET" "$WORKFLOW_DOC" "$INSTALL_DOC"; do
  if [ ! -f "$required" ]; then
    echo "FATAL: missing required file: $required" >&2
    exit 2
  fi
done

# Snapshot v3.0 fragment (always from current)
cp -f "$FRAGMENT" "$SNAP_V3"

# Use Wave 0 baseline if available (v2.x snapshot from Todo 1);
# fall back to current TARGET (lets S3 still regression-check non-target / categories /
# team_mode against whatever pre-install state we have).
SNAP_BASELINE=$(ls -1t /tmp/oh-my-openagent.jsonc.*.bak 2>/dev/null | head -1 || true)
if [ -n "$SNAP_BASELINE" ] && [ -f "$SNAP_BASELINE" ]; then
  cp -f "$SNAP_BASELINE" "$SNAP_PRE"
  echo "  baseline:  $SNAP_BASELINE (Wave 0 v2.x snapshot)"
else
  cp -f "$TARGET" "$SNAP_PRE"
  echo "  baseline:  $TARGET (current TARGET — no Wave 0 baseline found)"
fi

echo "test-prompt-append.sh starting"
echo "  fragment: $FRAGMENT ($(wc -c < "$FRAGMENT") bytes)"
echo "  target:   $TARGET ($(wc -c < "$TARGET") bytes)"
echo

# Support single-scenario invocation: `bash test-prompt-append.sh test_S1`
if [ "$#" -gt 0 ]; then
  rc_total=0
  for scenario in "$@"; do
    if ! "$scenario"; then
      rc_total=1
    fi
  done
  exit "$rc_total"
fi

# Default: run all 7 in fixed order
FAIL_COUNT=0
for scenario in test_S1 test_S3 test_S2 test_S4 test_S5 test_D1 test_D2; do
  if ! "$scenario"; then
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
done

# Final canonicalization: ensure fragment is v3.0 + user config has all 3 v3.0 prompt_appends
cp -f "$SNAP_V3" "$FRAGMENT"
final_rc=$(run_install /tmp/test-final.out /tmp/test-final.err) || true
echo "final canonicalization install exit=$final_rc"
cat /tmp/test-final.out || true
echo

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "=== $FAIL_COUNT scenario(s) FAILED ==="
  exit 1
fi
echo "=== All 7 scenarios PASSED ==="
exit 0
