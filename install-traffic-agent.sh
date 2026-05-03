#!/usr/bin/env bash
set -euo pipefail

# Run inside Codespace once, or let start_services.sh use it automatically if the files exist.
# Required envs:
#   TRAFFIC_API_URL=http://141.11.18.186:3010/api/traffic/push
#   TRAFFIC_TOKEN=your_secret_token

PROJECT_DIR="${PROJECT_DIR:-/workspaces/g2ray}"
TRAFFIC_API_URL="${TRAFFIC_API_URL:-http://141.11.18.186:3010/api/traffic/push}"
TRAFFIC_TOKEN="${TRAFFIC_TOKEN:-change_me_traffic_token}"
TRAFFIC_INTERVAL="${TRAFFIC_INTERVAL:-10}"
XRAY_INBOUND_TAG="${XRAY_INBOUND_TAG:-vless-in}"

if [ "$TRAFFIC_API_URL" = "http://141.11.18.186:3010/api/traffic/push" ] || [ "$TRAFFIC_TOKEN" = "change_me_traffic_token" ]; then
  echo "ERROR: Set TRAFFIC_API_URL and TRAFFIC_TOKEN before running this script."
  echo "Example:"
  echo "  export TRAFFIC_API_URL=http://141.11.18.186:3010/api/traffic/push"
  echo "  export TRAFFIC_TOKEN=your_secret_token"
  exit 1
fi

cd "$PROJECT_DIR"
chmod +x "$PROJECT_DIR/usage-agent.sh"

cat > "$PROJECT_DIR/.traffic.env" <<ENV
TRAFFIC_API_URL="$TRAFFIC_API_URL"
TRAFFIC_TOKEN="$TRAFFIC_TOKEN"
TRAFFIC_INTERVAL="$TRAFFIC_INTERVAL"
XRAY_INBOUND_TAG="$XRAY_INBOUND_TAG"
ENV

pkill -f "$PROJECT_DIR/usage-agent.sh" 2>/dev/null || true
nohup "$PROJECT_DIR/usage-agent.sh" >/tmp/g2ray-traffic-agent.out 2>&1 &
echo $! > /tmp/g2ray-traffic-agent.pid

echo "Traffic agent installed for workspace: ${CODESPACE_NAME:-unknown}"
echo "Log: /tmp/g2ray-traffic-agent.log"
