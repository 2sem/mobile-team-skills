#!/usr/bin/env bash
set -euo pipefail

SESSION_FILE="${GH_IDB_SESSION_FILE:-/tmp/gh-idb-session.env}"
UDID="${1:-}"

if [ "$UDID" = "" ]; then
  if session_udid="$(GH_IDB_SESSION_FILE="$SESSION_FILE" bash scripts/idb-session.sh udid 2>/dev/null)"; then
    UDID="$session_udid"
  elif [ -f "$SESSION_FILE" ]; then
    echo "❌ Cached IDB warm session is stale or unreachable." >&2
    echo "   Re-bootstrap with: bash scripts/idb-session.sh bootstrap [SIMULATOR_UDID]" >&2
    exit 1
  fi
fi

if [ "$UDID" = "" ]; then
  echo "Usage: bash scripts/idb-open-work-alarm.sh <SIMULATOR_UDID>"
  echo "   or: bootstrap once via bash scripts/idb-session.sh bootstrap"
  exit 1
fi

BUNDLE_ID="${BUNDLE_ID:-com.y2k.gersanghelper}"
IDB_BIN="${IDB_BIN:-idb}"
OUT_PATH="${OUT_PATH:-/tmp/gh-work-alarm-fast-path.png}"
FALLBACK_TAP_X="${FALLBACK_TAP_X:-355}"
FALLBACK_TAP_Y="${FALLBACK_TAP_Y:-100}"

describe_all() {
  "$IDB_BIN" ui describe-all --udid "$UDID" 2>/dev/null || true
}

create_describe_dump_file() {
  local dump_file
  dump_file="$(mktemp /tmp/gh-idb-describe-all.XXXXXX.json)"
  describe_all >"$dump_file"
  if [ ! -s "$dump_file" ]; then
    rm -f "$dump_file"
    return 1
  fi
  printf '%s\n' "$dump_file"
}

discover_work_entry_point() {
  local dump_file
  dump_file="$(create_describe_dump_file)" || return 1

  local result
  if ! result="$(python3 - "$dump_file" <<'PY'
import json
import sys

dump_file = sys.argv[1]
try:
    with open(dump_file, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    sys.exit(1)

def frame_center(node):
    frame = node.get("frame")
    if not isinstance(frame, dict):
        return None
    x = frame.get("x")
    y = frame.get("y")
    w = frame.get("width")
    h = frame.get("height")
    if any(v is None for v in (x, y, w, h)):
        return None
    try:
        x = float(x); y = float(y); w = float(w); h = float(h)
    except Exception:
        return None
    if w <= 1 or h <= 1:
        return None
    cx = int(x + w / 2)
    cy = int(y + h / 2)
    return cx, cy

def text_blob(node):
    keys = ["AXLabel", "AXValue", "title", "label", "value", "AXUniqueId", "identifier"]
    values = []
    for k in keys:
        v = node.get(k)
        if isinstance(v, str):
            values.append(v)
    return " ".join(values)

matches = []

def walk(node):
    if isinstance(node, dict):
        blob = text_blob(node)
        if "작업" in blob or "gh.alarm.openWorkList" in blob:
            center = frame_center(node)
            if center is not None:
                cx, cy = center
                # Prefer top-half candidates for alarm-root entries.
                penalty = 0 if cy < 420 else 10000
                score = penalty + cy
                matches.append((score, cx, cy, blob))
        for value in node.values():
            walk(value)
    elif isinstance(node, list):
        for item in node:
            walk(item)

walk(data)

if not matches:
    sys.exit(1)

matches.sort(key=lambda x: x[0])
_, cx, cy, _ = matches[0]
print(f"{cx} {cy}")
PY
)"; then
    rm -f "$dump_file"
    return 1
  fi

  rm -f "$dump_file"
  printf '%s\n' "$result"
}

validate_work_alarm_screen() {
  local dump_file
  dump_file="$(create_describe_dump_file)" || return 1

  if ! python3 - "$dump_file" <<'PY'
import json
import sys

dump_file = sys.argv[1]
try:
    with open(dump_file, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    sys.exit(1)

TARGETS = ["작업 알림", "gh.workAlarm.row", "work-alarm", "UITest Benchmark"]

def walk(node):
    if isinstance(node, dict):
        for value in node.values():
            if isinstance(value, str):
                for target in TARGETS:
                    if target in value:
                        return True
            elif isinstance(value, (dict, list)) and walk(value):
                return True
    elif isinstance(node, list):
        for item in node:
            if walk(item):
                return True
    return False

sys.exit(0 if walk(data) else 1)
PY
  then
    rm -f "$dump_file"
    return 1
  fi

  rm -f "$dump_file"
  return 0
}

validate_work_alarm_screen_ocr() {
  local image_path="$1"
  if [ ! -f "$image_path" ]; then
    return 1
  fi

  swift - "$image_path" <<'SWIFT' >/dev/null 2>&1
import Foundation
import Vision
import CoreGraphics
import ImageIO

let imagePath = CommandLine.arguments[1]
let url = URL(fileURLWithPath: imagePath)

guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    exit(1)
}

let request = VNRecognizeTextRequest()
request.recognitionLevel = .accurate
request.usesLanguageCorrection = true
request.recognitionLanguages = ["ko-KR", "en-US"]

do {
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try handler.perform([request])
} catch {
    exit(1)
}

let recognized = (request.results ?? [])
    .compactMap { $0.topCandidates(1).first?.string }
    .joined(separator: "\n")

let targets = ["작업 알림", "XCUITest Benchmark", "작업완료"]
let ok = targets.contains { recognized.contains($0) }
exit(ok ? 0 : 1)
SWIFT
}

"$IDB_BIN" terminate "$BUNDLE_ID" --udid "$UDID" >/dev/null 2>&1 || true
"$IDB_BIN" launch "$BUNDLE_ID" --udid "$UDID" >/dev/null
sleep 1.2

# Repo-local fast path from alarm tab root to work alarm list.
tap_coords=""
if tap_coords="$(discover_work_entry_point)"; then
  TAP_X="${tap_coords%% *}"
  TAP_Y="${tap_coords##* }"
  echo "ℹ️ Discovered 작업 entry from describe-all: ${TAP_X},${TAP_Y}"
else
  TAP_X="$FALLBACK_TAP_X"
TAP_Y="$FALLBACK_TAP_Y"
  echo "⚠️ Could not discover 작업 entry from describe-all; using fallback: ${TAP_X},${TAP_Y}"
fi

"$IDB_BIN" ui tap "$TAP_X" "$TAP_Y" --udid "$UDID" >/dev/null
sleep 0.8

"$IDB_BIN" screenshot "$OUT_PATH" --udid "$UDID" >/dev/null

if ! validate_work_alarm_screen && ! validate_work_alarm_screen_ocr "$OUT_PATH"; then
  RETRY_TAP_X="${RETRY_TAP_X:-700}"
  RETRY_TAP_Y="${RETRY_TAP_Y:-100}"
  RETRY_OUT_PATH="${OUT_PATH%.png}-retry.png"

  if [ "$TAP_X" != "$RETRY_TAP_X" ] || [ "$TAP_Y" != "$RETRY_TAP_Y" ]; then
    echo "⚠️ Verification failed after first tap; retrying once with ${RETRY_TAP_X},${RETRY_TAP_Y}"
    "$IDB_BIN" ui tap "$RETRY_TAP_X" "$RETRY_TAP_Y" --udid "$UDID" >/dev/null
    sleep 0.8
    "$IDB_BIN" screenshot "$RETRY_OUT_PATH" --udid "$UDID" >/dev/null
    if validate_work_alarm_screen || validate_work_alarm_screen_ocr "$RETRY_OUT_PATH"; then
      TAP_X="$RETRY_TAP_X"
      TAP_Y="$RETRY_TAP_Y"
      OUT_PATH="$RETRY_OUT_PATH"
    else
      echo "❌ Failed to verify arrival at work alarm screen via describe-all."
      echo "   Saved screenshots for manual check: $OUT_PATH, $RETRY_OUT_PATH"
      exit 2
    fi
  else
    echo "❌ Failed to verify arrival at work alarm screen via describe-all."
    echo "   Saved screenshot for manual check: $OUT_PATH"
    exit 2
  fi
fi

cat <<EOF
✅ Work alarm fast path complete
- UDID: $UDID
- Bundle: $BUNDLE_ID
- Tap: ${TAP_X},${TAP_Y}
- Screenshot: $OUT_PATH
EOF
