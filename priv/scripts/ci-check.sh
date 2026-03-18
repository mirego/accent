#!/usr/bin/env bash

RED='\033[0;31m'
RED_BOLD='\033[1;31m'
GREEN='\033[0;32m'
GREEN_BOLD='\033[1;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
DIM='\033[2m'
NO_COLOR='\033[0m'

CURSOR_UP='\033[A'
CURSOR_COL1='\033[1G'
ERASE_LINE='\033[2K'

SPIN_FRAMES=('|' '/' '-' '\')

TMPDIR_ROOT=$(mktemp -d)

SHOW_CURSOR='\033[?25h'
RESET_ATTRS='\033[0m'

cleanup() {
  # Kill any background jobs spawned by this script
  jobs -p | xargs -r kill 2>/dev/null
  # Restore cursor and attributes
  printf "${RESET_ATTRS}${SHOW_CURSOR}"
  echo ""
  rm -rf "$TMPDIR_ROOT"
}

trap 'cleanup; exit 130' INT TERM
trap 'cleanup' EXIT

# ── Task definitions ───────────────────────────────────────────────────────────

PHASE1_LABELS=(
  "API tests"
  "Compilation without warnings"
)
PHASE1_COMMANDS=(
  "make test-api"
  "make lint-compile"
)

PHASE2_LABELS=(
  "API code auto-formatting"
  "API code lint"
  "Prettier auto-formatting"
  "Eslint code lint"
  "Handlebar template lint"
  "TypeScript type check"
)
PHASE2_COMMANDS=(
  "make lint-format"
  "make lint-credo"
  "make lint-prettier"
  "make lint-eslint"
  "make lint-template-hbs"
  "make type-check"
)

PHASE1_COUNT=${#PHASE1_LABELS[@]}
PHASE2_COUNT=${#PHASE2_LABELS[@]}
TOTAL=$((PHASE1_COUNT + PHASE2_COUNT))

# ── Labels array (read-only after init) ───────────────────────────────────────

declare -a ALL_LABELS
for i in $(seq 0 $((PHASE1_COUNT - 1))); do
  ALL_LABELS[$i]="${PHASE1_LABELS[$i]}"
done
for i in $(seq 0 $((PHASE2_COUNT - 1))); do
  ALL_LABELS[$((PHASE1_COUNT + i))]="${PHASE2_LABELS[$i]}"
done

# ── File-based shared state ────────────────────────────────────────────────────
# Each task idx has:
#   $TMPDIR_ROOT/status_N   -> pending | running | pass | fail
#   $TMPDIR_ROOT/start_N    -> epoch seconds
#   $TMPDIR_ROOT/end_N      -> epoch seconds
#   $TMPDIR_ROOT/exit_N     -> exit code
#   $TMPDIR_ROOT/out_N      -> captured stdout+stderr

set_state() {
  local idx=$1 key=$2 val=$3
  printf '%s' "$val" > "${TMPDIR_ROOT}/${key}_${idx}"
}

get_state() {
  local idx=$1 key=$2
  local f="${TMPDIR_ROOT}/${key}_${idx}"
  [ -f "$f" ] && cat "$f" || echo ""
}

for i in $(seq 0 $((TOTAL - 1))); do
  set_state "$i" status "pending"
  set_state "$i" start  "0"
  set_state "$i" end    "0"
  set_state "$i" exit   "-1"
done

# ── Render helpers ─────────────────────────────────────────────────────────────

format_duration() {
  local secs=$1
  if [ "$secs" -lt 60 ]; then
    printf "%ds" "$secs"
  else
    printf "%dm%ds" $((secs / 60)) $((secs % 60))
  fi
}

render_row() {
  local idx=$1 now=$2
  local label="${ALL_LABELS[$idx]}"
  local status
  status=$(get_state "$idx" status)
  local start
  start=$(get_state "$idx" start)
  local end
  end=$(get_state "$idx" end)
  local exitcode
  exitcode=$(get_state "$idx" exit)

  printf "${ERASE_LINE}${CURSOR_COL1}"

  case "$status" in
    pending)
      printf "  ${DIM}  %-38s  waiting${NO_COLOR}\n" "$label"
      ;;
    running)
      local elapsed=$(( now - start ))
      local frames='⣾⣽⣻⢿⡿⣟⣯⣷'
      local frame_idx=$(( elapsed % 8 ))
      local frame
      frame=$(printf '%s' "$frames" | cut -c$(( frame_idx + 1 )))
      local dur
      dur=$(format_duration "$elapsed")
      printf "  ${YELLOW}%s %-38s  %s${NO_COLOR}\n" "$frame" "$label" "$dur"
      ;;
    pass)
      local dur
      dur=$(format_duration $(( end - start )))
      printf "  ${GREEN}✓ %-38s  PASS  %s${NO_COLOR}\n" "$label" "$dur"
      ;;
    fail)
      local dur
      dur=$(format_duration $(( end - start )))
      printf "  ${RED}✓ %-38s  FAIL  %s  (exit ${exitcode})${NO_COLOR}\n" "$label" "$dur"
      ;;
  esac
}

render_all() {
  local now=$1
  for _ in $(seq 1 $TOTAL); do printf "${CURSOR_UP}"; done
  for i in $(seq 0 $((TOTAL - 1))); do
    render_row "$i" "$now"
  done
}

# ── Header + initial blank rows ────────────────────────────────────────────────

echo ""
printf "${BOLD}  CI Checks${NO_COLOR}   ${DIM}${PHASE1_COUNT} sequential then ${PHASE2_COUNT} parallel${NO_COLOR}\n"
echo ""
for i in $(seq 0 $((TOTAL - 1))); do
  render_row "$i" 0
done

# ── Spinner (background subshell reads state from files) ──────────────────────

SPINNER_STOP="${TMPDIR_ROOT}/spinner_stop"

(
  while [ ! -f "$SPINNER_STOP" ]; do
    render_all "$(date +%s)"
    sleep 0.02
  done
) &
SPINNER_PID=$!

# ── Task runner helpers ────────────────────────────────────────────────────────

run_task() {
  local idx=$1 cmd=$2
  set_state "$idx" status "running"
  set_state "$idx" start  "$(date +%s)"

  eval "$cmd" > "${TMPDIR_ROOT}/out_${idx}" 2>&1
  local code=$?

  set_state "$idx" end    "$(date +%s)"
  set_state "$idx" exit   "$code"
  if [ "$code" -eq 0 ]; then
    set_state "$idx" status "pass"
  else
    set_state "$idx" status "fail"
  fi
}

# ── Phase 1: sequential ────────────────────────────────────────────────────────

for i in $(seq 0 $((PHASE1_COUNT - 1))); do
  run_task "$i" "${PHASE1_COMMANDS[$i]}"
done

# ── Phase 2: parallel ──────────────────────────────────────────────────────────

declare -a PHASE2_BGPIDS
for i in $(seq 0 $((PHASE2_COUNT - 1))); do
  idx=$((PHASE1_COUNT + i))
  run_task "$idx" "${PHASE2_COMMANDS[$i]}" &
  PHASE2_BGPIDS[$i]=$!
done

for i in $(seq 0 $((PHASE2_COUNT - 1))); do
  wait "${PHASE2_BGPIDS[$i]}"
done

# ── Stop spinner + final render ────────────────────────────────────────────────

touch "$SPINNER_STOP"
wait "$SPINNER_PID" 2>/dev/null
render_all "$(date +%s)"

# ── Tally ──────────────────────────────────────────────────────────────────────

FAILED=0
PASSED=0
for i in $(seq 0 $((TOTAL - 1))); do
  status=$(get_state "$i" status)
  if [ "$status" = "pass" ]; then
    PASSED=$((PASSED + 1))
  else
    FAILED=$((FAILED + 1))
  fi
done

# ── Failure details ────────────────────────────────────────────────────────────

if [ "$FAILED" -gt 0 ]; then
  echo ""
  printf "${BOLD}  Failure Details${NO_COLOR}\n"

  for i in $(seq 0 $((TOTAL - 1))); do
    if [ "$(get_state "$i" status)" = "fail" ]; then
      echo ""
      printf "  ${RED_BOLD}%-38s${NO_COLOR}\n" "${ALL_LABELS[$i]}"
      printf "${DIM}%s${NO_COLOR}\n" "$(printf '%.0s-' {1..72})"
      sed 's/^/  /' "${TMPDIR_ROOT}/out_${i}"
      printf "${DIM}%s${NO_COLOR}\n" "$(printf '%.0s-' {1..72})"
    fi
  done
fi

# ── Summary ────────────────────────────────────────────────────────────────────

echo ""
printf "${DIM}%s${NO_COLOR}\n" "$(printf '%.0s-' {1..72})"

if [ "$FAILED" -gt 0 ]; then
  printf "  ${YELLOW}%-20s${NO_COLOR}  ${GREEN_BOLD}%d passed${NO_COLOR}   ${RED_BOLD}%d failed${NO_COLOR}\n" \
    "Summary" "$PASSED" "$FAILED"
  printf "${DIM}%s${NO_COLOR}\n" "$(printf '%.0s-' {1..72})"
  echo ""
  printf "  ${RED_BOLD}%d check(s) failed.${NO_COLOR} Please fix before committing.\n" "$FAILED"
  echo ""
  exit 1
else
  printf "  ${YELLOW}%-20s${NO_COLOR}  ${GREEN_BOLD}%d passed${NO_COLOR}   all checks clean\n" \
    "Summary" "$PASSED"
  printf "${DIM}%s${NO_COLOR}\n" "$(printf '%.0s-' {1..72})"
  echo ""
  printf "  ${GREEN_BOLD}All checks passed.${NO_COLOR}\n"
  echo ""
  exit 0
fi
