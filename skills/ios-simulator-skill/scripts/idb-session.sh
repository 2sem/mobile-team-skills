#!/usr/bin/env bash
set -euo pipefail

IDB_BIN="${IDB_BIN:-idb}"
SESSION_FILE="${GH_IDB_SESSION_FILE:-/tmp/gh-idb-session.env}"

now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

usage() {
  cat <<'EOF'
Usage:
  bash scripts/idb-session.sh bootstrap [SIMULATOR_UDID]
  bash scripts/idb-session.sh status
  bash scripts/idb-session.sh udid
  bash scripts/idb-session.sh run <idb-subcommand...>
  bash scripts/idb-session.sh context-cache <context-name> [source]
  bash scripts/idb-session.sh context-status
  bash scripts/idb-session.sh context-needs-refresh
  bash scripts/idb-session.sh context-mark-safe [action]
  bash scripts/idb-session.sh context-mark-refresh [action]
  bash scripts/idb-session.sh context-invalidate [reason]
  bash scripts/idb-session.sh clear

Examples:
  bash scripts/idb-session.sh bootstrap
  bash scripts/idb-session.sh run ui describe-all
  bash scripts/idb-session.sh run screenshot /tmp/gh-idb.png
  bash scripts/idb-session.sh context-cache alarm-root "describe-all"
  bash scripts/idb-session.sh context-mark-refresh "ui tap 120 200"
EOF
}

ensure_idb() {
  if ! command -v "$IDB_BIN" >/dev/null 2>&1; then
    echo "❌ idb binary not found: $IDB_BIN" >&2
    exit 1
  fi
}

validate_udid() {
  "$IDB_BIN" describe --udid "$1" >/dev/null 2>&1
}

load_session_state() {
  GH_IDB_SESSION_UDID=""
  GH_IDB_SESSION_LAST_WARMED_AT=""
  GH_IDB_CONTEXT_NAME=""
  GH_IDB_CONTEXT_SOURCE=""
  GH_IDB_CONTEXT_UDID=""
  GH_IDB_CONTEXT_LAST_UPDATED_AT=""
  GH_IDB_CONTEXT_REFRESH_REQUIRED="yes"
  GH_IDB_CONTEXT_LAST_ACTION=""
  GH_IDB_CONTEXT_LAST_ACTION_AT=""

  if [ -f "$SESSION_FILE" ]; then
    # shellcheck disable=SC1090
    . "$SESSION_FILE"
  fi
}

emit_session_var() {
  local key="$1"
  local value="$2"
  printf '%s=%q\n' "$key" "$value"
}

persist_session_state() {
  mkdir -p "$(dirname "$SESSION_FILE")"

  local temp_file
  temp_file="$(mktemp "${SESSION_FILE}.XXXXXX")"

  {
    emit_session_var "GH_IDB_SESSION_UDID" "${GH_IDB_SESSION_UDID:-}"
    emit_session_var "GH_IDB_SESSION_LAST_WARMED_AT" "${GH_IDB_SESSION_LAST_WARMED_AT:-}"
    emit_session_var "GH_IDB_CONTEXT_NAME" "${GH_IDB_CONTEXT_NAME:-}"
    emit_session_var "GH_IDB_CONTEXT_SOURCE" "${GH_IDB_CONTEXT_SOURCE:-}"
    emit_session_var "GH_IDB_CONTEXT_UDID" "${GH_IDB_CONTEXT_UDID:-}"
    emit_session_var "GH_IDB_CONTEXT_LAST_UPDATED_AT" "${GH_IDB_CONTEXT_LAST_UPDATED_AT:-}"
    emit_session_var "GH_IDB_CONTEXT_REFRESH_REQUIRED" "${GH_IDB_CONTEXT_REFRESH_REQUIRED:-yes}"
    emit_session_var "GH_IDB_CONTEXT_LAST_ACTION" "${GH_IDB_CONTEXT_LAST_ACTION:-}"
    emit_session_var "GH_IDB_CONTEXT_LAST_ACTION_AT" "${GH_IDB_CONTEXT_LAST_ACTION_AT:-}"
  } >"$temp_file"

  mv "$temp_file" "$SESSION_FILE"
}

session_udid_from_file() {
  if [ -f "$SESSION_FILE" ]; then
    # shellcheck disable=SC1090
    . "$SESSION_FILE"
    if [ "${GH_IDB_SESSION_UDID:-}" != "" ]; then
      printf '%s\n' "$GH_IDB_SESSION_UDID"
      return 0
    fi
  fi
  return 1
}

pick_booted_simulator_udid() {
  "$IDB_BIN" list-targets --json | python3 -c '
import json, sys
rows=[json.loads(l) for l in sys.stdin if l.strip()]
booted=[r for r in rows if r.get("type")=="simulator" and r.get("state")=="Booted" and r.get("udid")]
if not booted:
    sys.exit(1)
booted.sort(key=lambda r: (0 if r.get("companion") else 1, r.get("name") or ""))
print(booted[0]["udid"])
'
}

write_session_file() {
  local udid="$1"
  local now
  now="$(now_utc)"

  load_session_state
  GH_IDB_SESSION_UDID="$udid"
  GH_IDB_SESSION_LAST_WARMED_AT="$now"

  # Context is intentionally invalidated on bootstrap: app lifecycle may have changed.
  GH_IDB_CONTEXT_NAME=""
  GH_IDB_CONTEXT_SOURCE=""
  GH_IDB_CONTEXT_UDID=""
  GH_IDB_CONTEXT_LAST_UPDATED_AT=""
  GH_IDB_CONTEXT_REFRESH_REQUIRED="yes"
  GH_IDB_CONTEXT_LAST_ACTION="bootstrap"
  GH_IDB_CONTEXT_LAST_ACTION_AT="$now"

  persist_session_state
}

bootstrap() {
  local udid="${1:-}"

  if [ "$udid" = "" ]; then
    if udid="$(session_udid_from_file)" && validate_udid "$udid"; then
      :
    else
      udid="$(pick_booted_simulator_udid)" || {
        echo "❌ No booted simulator found. Boot one first or pass UDID." >&2
        exit 1
      }
    fi
  fi

  if ! validate_udid "$udid"; then
    echo "❌ Failed to connect to target UDID: $udid" >&2
    exit 1
  fi

  # Warm companion once for this session.
  "$IDB_BIN" ui describe-all --udid "$udid" >/dev/null 2>&1 || true

  write_session_file "$udid"

  cat <<EOF
✅ IDB warm session ready
- session file: $SESSION_FILE
- udid: $udid
EOF
}

status() {
  ensure_idb
  if [ ! -f "$SESSION_FILE" ]; then
    echo "ℹ️ No session file found at $SESSION_FILE"
    exit 1
  fi

  # shellcheck disable=SC1090
  . "$SESSION_FILE"
  local valid="no"
  if [ "${GH_IDB_SESSION_UDID:-}" != "" ] && validate_udid "$GH_IDB_SESSION_UDID"; then
    valid="yes"
  fi

  cat <<EOF
IDB warm session status
- session file: $SESSION_FILE
- valid: $valid
- udid: ${GH_IDB_SESSION_UDID:-}
- last warmed: ${GH_IDB_SESSION_LAST_WARMED_AT:-}
EOF
}

session_udid_or_fail() {
  local udid
  udid="$(session_udid_from_file 2>/dev/null || true)"
  if [ "$udid" = "" ]; then
    echo "❌ No warm session metadata found. Run bootstrap first." >&2
    exit 1
  fi
  if ! validate_udid "$udid"; then
    echo "❌ Session UDID is not currently reachable: $udid" >&2
    echo "   Run bootstrap again to refresh session metadata." >&2
    exit 1
  fi
  printf '%s\n' "$udid"
}

session_udid_for_context_or_fail() {
  ensure_idb
  session_udid_or_fail
}

context_reuse_check() {
  load_session_state

  local current_udid="${GH_IDB_SESSION_UDID:-}"
  if [ "$current_udid" = "" ]; then
    return 0
  fi

  if ! validate_udid "$current_udid"; then
    return 0
  fi

  if [ "${GH_IDB_CONTEXT_NAME:-}" = "" ]; then
    return 0
  fi

  if [ "${GH_IDB_CONTEXT_REFRESH_REQUIRED:-yes}" != "no" ]; then
    return 0
  fi

  if [ "${GH_IDB_CONTEXT_UDID:-}" != "$current_udid" ]; then
    return 0
  fi

  return 1
}

context_cache() {
  local context_name="${1:-}"
  local source="${2:-manual}"

  if [ "$context_name" = "" ]; then
    echo "❌ Missing context name. Example: context-cache alarm-root describe-all" >&2
    exit 1
  fi

  local udid
  udid="$(session_udid_for_context_or_fail)"
  local now
  now="$(now_utc)"

  load_session_state
  GH_IDB_SESSION_UDID="$udid"
  GH_IDB_CONTEXT_NAME="$context_name"
  GH_IDB_CONTEXT_SOURCE="$source"
  GH_IDB_CONTEXT_UDID="$udid"
  GH_IDB_CONTEXT_LAST_UPDATED_AT="$now"
  GH_IDB_CONTEXT_REFRESH_REQUIRED="no"
  GH_IDB_CONTEXT_LAST_ACTION="cache:$context_name"
  GH_IDB_CONTEXT_LAST_ACTION_AT="$now"
  persist_session_state

  cat <<EOF
✅ Cached context
- context: $GH_IDB_CONTEXT_NAME
- source: $GH_IDB_CONTEXT_SOURCE
- reusable: yes
- session file: $SESSION_FILE
EOF
}

context_mark() {
  local refresh_required="$1"
  local action="${2:-manual}"

  local udid
  udid="$(session_udid_for_context_or_fail)"
  local now
  now="$(now_utc)"

  load_session_state
  GH_IDB_SESSION_UDID="$udid"
  GH_IDB_CONTEXT_REFRESH_REQUIRED="$refresh_required"
  GH_IDB_CONTEXT_LAST_ACTION="$action"
  GH_IDB_CONTEXT_LAST_ACTION_AT="$now"

  if [ "$refresh_required" = "yes" ]; then
    if [ "${GH_IDB_CONTEXT_NAME:-}" = "" ]; then
      GH_IDB_CONTEXT_NAME="unknown"
    fi
  else
    if [ "${GH_IDB_CONTEXT_NAME:-}" = "" ]; then
      GH_IDB_CONTEXT_NAME="unknown"
    fi
    GH_IDB_CONTEXT_UDID="$udid"
    GH_IDB_CONTEXT_LAST_UPDATED_AT="$now"
  fi

  persist_session_state

  cat <<EOF
✅ Context action marked
- action: $action
- refresh required: $refresh_required
- session file: $SESSION_FILE
EOF
}

context_invalidate() {
  local reason="${1:-manual-invalidate}"
  local now
  now="$(now_utc)"

  load_session_state
  GH_IDB_CONTEXT_NAME=""
  GH_IDB_CONTEXT_SOURCE=""
  GH_IDB_CONTEXT_UDID=""
  GH_IDB_CONTEXT_LAST_UPDATED_AT=""
  GH_IDB_CONTEXT_REFRESH_REQUIRED="yes"
  GH_IDB_CONTEXT_LAST_ACTION="invalidate:$reason"
  GH_IDB_CONTEXT_LAST_ACTION_AT="$now"
  persist_session_state

  cat <<EOF
🧹 Context invalidated
- reason: $reason
- session file: $SESSION_FILE
EOF
}

context_status() {
  ensure_idb
  if [ ! -f "$SESSION_FILE" ]; then
    echo "ℹ️ No session file found at $SESSION_FILE"
    exit 1
  fi

  load_session_state

  local valid="no"
  if [ "${GH_IDB_SESSION_UDID:-}" != "" ] && validate_udid "$GH_IDB_SESSION_UDID"; then
    valid="yes"
  fi

  local reusable="no"
  if context_reuse_check; then
    reusable="no"
  else
    reusable="yes"
  fi

  cat <<EOF
IDB cached context status
- session file: $SESSION_FILE
- session valid: $valid
- udid: ${GH_IDB_SESSION_UDID:-}
- context: ${GH_IDB_CONTEXT_NAME:-}
- source: ${GH_IDB_CONTEXT_SOURCE:-}
- context udid: ${GH_IDB_CONTEXT_UDID:-}
- last updated: ${GH_IDB_CONTEXT_LAST_UPDATED_AT:-}
- refresh required: ${GH_IDB_CONTEXT_REFRESH_REQUIRED:-yes}
- last action: ${GH_IDB_CONTEXT_LAST_ACTION:-}
- last action at: ${GH_IDB_CONTEXT_LAST_ACTION_AT:-}
- reusable now: $reusable
EOF
}

context_needs_refresh() {
  ensure_idb
  if context_reuse_check; then
    echo "yes"
    return 0
  fi
  echo "no"
  return 0
}

run_with_session() {
  ensure_idb
  if [ "$#" -eq 0 ]; then
    echo "❌ Missing idb subcommand. Example: run ui describe-all" >&2
    exit 1
  fi

  local udid
  udid="$(session_udid_or_fail)"

  local has_udid="no"
  local arg
  for arg in "$@"; do
    if [ "$arg" = "--udid" ]; then
      has_udid="yes"
      break
    fi
  done

  if [ "$has_udid" = "yes" ]; then
    "$IDB_BIN" "$@"
  else
    "$IDB_BIN" "$@" --udid "$udid"
  fi
}

clear_session() {
  rm -f "$SESSION_FILE"
  echo "🧹 Cleared session file: $SESSION_FILE"
}

case "${1:-}" in
  bootstrap)
    shift
    bootstrap "${1:-}"
    ;;
  status)
    status
    ;;
  udid)
    session_udid_or_fail
    ;;
  run)
    shift
    run_with_session "$@"
    ;;
  context-cache)
    shift
    context_cache "${1:-}" "${2:-manual}"
    ;;
  context-status)
    context_status
    ;;
  context-needs-refresh)
    context_needs_refresh
    ;;
  context-mark-safe)
    shift
    context_mark "no" "${1:-manual-safe-action}"
    ;;
  context-mark-refresh)
    shift
    context_mark "yes" "${1:-manual-refresh-action}"
    ;;
  context-invalidate)
    shift
    context_invalidate "${1:-manual-invalidate}"
    ;;
  clear)
    clear_session
    ;;
  *)
    usage
    exit 1
    ;;
esac
