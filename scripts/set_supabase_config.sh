#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/set_supabase_config.sh https://<project-ref>.supabase.co <anon-key>
#
# Writes onevisioon/Resources/SupabaseConfig.plist with supplied values.

if [[ "${1:-}" == "" || "${2:-}" == "" ]]; then
  echo "Usage: $0 <supabase-url> <supabase-anon-key>" >&2
  exit 2
fi

SUPABASE_URL="$1"
SUPABASE_ANON_KEY="$2"
PLIST_PATH="$(cd "$(dirname "$0")/.." && pwd)/onevisioon/Resources/SupabaseConfig.plist"

if [[ ! "$SUPABASE_URL" =~ ^https://[a-zA-Z0-9-]+\.supabase\.co$ ]]; then
  echo "Error: URL must look like https://<project-ref>.supabase.co" >&2
  exit 1
fi

cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>projectURL</key>
	<string>${SUPABASE_URL}</string>
	<key>anonKey</key>
	<string>${SUPABASE_ANON_KEY}</string>
</dict>
</plist>
EOF

plutil -lint "$PLIST_PATH" >/dev/null
echo "Updated $PLIST_PATH"
echo "projectURL=$SUPABASE_URL"
