#!/usr/bin/env bash
# Smoke test for scripts/run.sh — the only executable in the skill, and the one
# thing a learner's session silently depends on. Run it after touching run.sh,
# or on a new machine before the first session:
#
#   bash scripts/test-run.sh
#
# Checks the contract SKILL.md promises: interpretation happens, output comes
# back, timeouts fire, bad input fails loudly, and no scratch files leak.

set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runner="$here/run.sh"

pass=0
fail=0

check() {
  local label="$1" want="$2" got="$3"
  if [[ "$want" == "$got" ]]; then
    pass=$((pass + 1))
    printf 'ok    %s\n' "$label"
  else
    fail=$((fail + 1))
    printf 'FAIL  %s (want %q, got %q)\n' "$label" "$want" "$got"
  fi
}

leaked() {
  # Scratch files are named tutor_snippet.*, tutor_out.*, tutor_err.*
  find "${TMPDIR:-/tmp}" -maxdepth 1 -name 'tutor_*' 2>/dev/null | sort
}

# stdout of a run, with run.sh's own === markers stripped
only_stdout() {
  sed -n '/^=== stdout ===$/,/^=== stderr ===$/p' | sed '1d;$d'
}

if [[ ! -x "$runner" ]]; then
  echo "no runner at $runner" >&2
  exit 1
fi

before_leaks="$(leaked)"

# 1. usage error, no interpreter given
bash "$runner" >/dev/null 2>&1
check "no interpreter → exit 2" 2 $?

# 2. unknown interpreter
echo 'x' | bash "$runner" definitelynotaninterpreter >/dev/null 2>&1
check "unknown interpreter → exit 3" 3 $?

# 3. stdout comes back
if command -v python3 >/dev/null 2>&1; then
  out="$(echo 'print(6)' | bash "$runner" python3 2>/dev/null | only_stdout)"
  check "python3 stdout captured" "6" "$out"
fi

if command -v node >/dev/null 2>&1; then
  out="$(printf 'console.log(6)\n' | bash "$runner" node 2>/dev/null | only_stdout)"
  check "node stdout captured" "6" "$out"
fi

# 4. stderr is reported, not swallowed — a traceback is often the lesson
if command -v python3 >/dev/null 2>&1; then
  out="$(echo 'raise SystemExit("boom")' | bash "$runner" python3 2>&1)"
  case "$out" in
    *boom*) check "python3 stderr captured" ok ok ;;
    *) check "python3 stderr captured" "boom" "missing" ;;
  esac
fi

# 5. an infinite loop fails instead of hanging
if command -v python3 >/dev/null 2>&1; then
  printf 'while True: pass\n' | bash "$runner" python3 2 >/dev/null 2>&1
  check "timeout → exit 124" 124 $?
fi

# 6. no scratch files left behind. Compared by name, not count, so orphans
#    abandoned by an older run.sh don't read as failures.
new_leaks="$(comm -13 <(echo "$before_leaks") <(leaked) | wc -l | tr -d ' ')"
check "no leaked scratch files" 0 "$new_leaks"

printf '\n%s passed, %s failed\n' "$pass" "$fail"
(( fail == 0 ))
