#!/usr/bin/env bash
# Test connectivity to GitHub.
#
# Usage: bash test.sh [owner/repo]
#   owner/repo  optional repository used for the `gh api` check
#               (default: JohnGoo/dsh-superagent-test)
#
# Exits 0 when every check succeeds, 1 otherwise.
set -uo pipefail

REPO="${1:-JohnGoo/dsh-superagent-test}"
TIMEOUT="${GITHUB_CHECK_TIMEOUT:-10}"
failed=0

check() {
  local name=$1
  shift
  if out=$("$@" 2>&1); then
    echo "OK   ${name}"
    [ -n "${out}" ] && echo "     $(printf '%s' "${out}" | head -n 1)"
  else
    echo "FAIL ${name}"
    [ -n "${out}" ] && echo "     $(printf '%s' "${out}" | head -n 1)"
    failed=$((failed + 1))
  fi
}

echo "Testing GitHub connectivity..."

check "DNS lookup (github.com)" \
  timeout "${TIMEOUT}" getent hosts github.com

check "HTTPS to github.com (git ls-remote)" \
  timeout "${TIMEOUT}" git ls-remote --exit-code https://github.com/JohnGoo/dsh-superagent-test HEAD

check "GitHub API (gh api repos/${REPO})" \
  timeout "${TIMEOUT}" gh api "repos/${REPO}" --jq '.full_name'

echo
if [ "${failed}" -eq 0 ]; then
  echo "All GitHub connectivity checks passed."
else
  echo "${failed} GitHub connectivity check(s) failed."
  exit 1
fi
