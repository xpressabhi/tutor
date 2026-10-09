#!/usr/bin/env bash
# Run a code snippet and report stdout, stderr, and exit code.
#
# Usage: run.sh <interpreter> [timeout-seconds]
#   Reads the snippet on stdin. Temp file is discarded after the run.
#
# Examples:
#   echo 'print(sum([1,2,3]))' | run.sh python3
#   run.sh node 5 < snippet.js
#
# Rules this enforces, so they hold the same way every session:
#   - timeout, so an infinite loop fails instead of hanging the session
#   - temp file discarded after; the learner's workspace is never polluted
#   - stdout, stderr, exit code all captured (a traceback is often the best output)
#   - no install, no network
#
# Exit codes: 0 ran fine (inspect output for the real status)
#             2 bad usage
#             3 interpreter not found
#             124 timed out

set -uo pipefail

interpreter="${1:-}"
timeout_secs="${2:-10}"

if [[ -z "$interpreter" ]]; then
  echo "usage: run.sh <interpreter> [timeout-seconds]   (snippet on stdin)" >&2
  exit 2
fi

if ! command -v "$interpreter" >/dev/null 2>&1; then
  echo "interpreter not found: $interpreter" >&2
  exit 3
fi

if ! [[ "$timeout_secs" =~ ^[0-9]+$ ]] || (( timeout_secs < 1 || timeout_secs > 120 )); then
  timeout_secs=10
fi

snippet="$(mktemp -t tutor_snippet.XXXXXX)"
out="$(mktemp -t tutor_out.XXXXXX)"
err="$(mktemp -t tutor_err.XXXXXX)"
trap 'rm -f "$snippet" "$out" "$err"' EXIT

# Some interpreters pick behaviour from the filename extension. Move rather than
# repoint the variable — the original mktemp file has to go with it, or the EXIT
# trap below only ever sees the renamed path and the original leaks.
case "$interpreter" in
  *python*) mv "$snippet" "$snippet.py"; snippet="$snippet.py" ;;
  *node*)   mv "$snippet" "$snippet.js"; snippet="$snippet.js" ;;
esac
cat >"$snippet" 2>/dev/null || true

# macOS ships no `timeout` (that is GNU coreutils). Prefer it when present,
# otherwise use a shell watchdog so the guard holds on any platform.
run_with_timeout() {
  if command -v timeout >/dev/null 2>&1; then
    timeout "$timeout_secs" "$interpreter" "$snippet"
    return $?
  fi

  "$interpreter" "$snippet" &
  local pid=$! i
  for (( i = 0; i < timeout_secs * 10; i++ )); do
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.1
  done
  if kill -0 "$pid" 2>/dev/null; then
    kill -9 "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
    return 124
  fi
  wait "$pid"
}

run_with_timeout >"$out" 2>"$err"
status=$?

echo "=== stdout ==="
cat "$out"
echo "=== stderr ==="
cat "$err"
echo "=== exit: $status ==="

if (( status == 124 )); then
  echo "(timed out after ${timeout_secs}s — likely an infinite loop)" >&2
fi

exit "$status"
