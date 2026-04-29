#!/usr/bin/env bash

pkill -x xray 2>/dev/null || true
pkill -f "/workspaces/g2ray/watch.sh" 2>/dev/null || true

nohup /usr/local/bin/xray -c /etc/config.json > /tmp/xray.out 2>&1 &

chmod +x /workspaces/g2ray/watch.sh

nohup /workspaces/g2ray/watch.sh > /tmp/watchdog.out 2>&1 &

sleep 2

ps aux | grep -E "xray|watch.sh" | grep -v grep || true
