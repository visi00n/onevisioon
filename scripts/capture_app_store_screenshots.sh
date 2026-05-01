#!/usr/bin/env bash

set -euo pipefail

# Usage:
#   ./scripts/capture_app_store_screenshots.sh ["iPhone 17 Pro Max"] [output_dir]
#
# This script is interactive: it prompts you to position each screen, then captures.

DEVICE_NAME="${1:-iPhone 17 Pro Max}"
OUT_DIR="${2:-$(pwd)/AppStoreAssets/Screenshots/${DEVICE_NAME// /_}}"

shots=(
  "01_onboarding_intro"
  "02_onboarding_username"
  "03_subscription_trial"
  "04_learn_dashboard_streak"
  "05_wisdom_folder_roadmap"
  "06_lesson_slide_verse_depth"
  "07_lesson_notes_template"
  "08_quest_challenge"
  "09_prayer_feed"
  "10_profile_leaderboard"
)

mkdir -p "$OUT_DIR"

echo "Locating simulator: $DEVICE_NAME"
UDID="$(xcrun simctl list devices available | awk -v d="$DEVICE_NAME" '
  $0 ~ d {
    if (match($0, /\(([0-9A-F-]+)\)/)) {
      print substr($0, RSTART + 1, RLENGTH - 2)
      exit
    }
  }
')"

if [[ -z "${UDID:-}" ]]; then
  echo "Could not find an available simulator named: $DEVICE_NAME"
  echo "Run: xcrun simctl list devices available"
  exit 1
fi

echo "Using device UDID: $UDID"

echo "Booting simulator..."
xcrun simctl boot "$UDID" >/dev/null 2>&1 || true

echo "Applying clean status bar..."
xcrun simctl status_bar "$UDID" override \
  --time 9:41 \
  --dataNetwork wifi \
  --wifiMode active \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4 \
  --batteryState charged \
  --batteryLevel 100

echo
echo "Interactive capture started."
echo "For each shot, navigate in the simulator first, then press Enter."
echo

for shot in "${shots[@]}"; do
  read -r -p "Ready to capture ${shot}. Press Enter..."
  target="${OUT_DIR}/${shot}.png"
  xcrun simctl io "$UDID" screenshot "$target" >/dev/null
  echo "Saved: $target"
done

echo
echo "Done. Screenshot set saved to:"
echo "$OUT_DIR"
echo
echo "Clearing status bar override..."
xcrun simctl status_bar "$UDID" clear || true
echo "Finished."

