#!/usr/bin/env bash

PROJECT_DIR="${PROJECT_DIR:-/workspaces/g2ray}"

pkill -x xray 2>/dev/null || true
pkill -f "$PROJECT_DIR/watch.sh" 2>/dev/null || true

nohup /usr/local/bin/xray -c /etc/config.json > /tmp/xray.out 2>&1 &

chmod +x "$PROJECT_DIR/watch.sh"
nohup "$PROJECT_DIR/watch.sh" > /tmp/watchdog.out 2>&1 &

sleep 2
ps aux | grep -E "xray|watch.sh" | grep -v grep || true

# Start traffic monitor agent (workspace-based). It auto-uses CODESPACE_NAME.
if [ -f "$PROJECT_DIR/usage-agent.sh" ]; then
  pkill -f "$PROJECT_DIR/usage-agent.sh" 2>/dev/null || true
  chmod +x "$PROJECT_DIR/usage-agent.sh"
  nohup "$PROJECT_DIR/usage-agent.sh" >/tmp/g2ray-traffic-agent.out 2>&1 &
fi
