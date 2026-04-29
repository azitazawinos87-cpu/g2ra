#!/bin/bash

CONFIG="/etc/config.json"
XRAY="/usr/local/bin/xray"
LOG="/tmp/xray-watch.log"

start_xray() {
  echo "[$(date)] Restarting Xray..." | tee -a "$LOG"
  pkill -f "$XRAY" 2>/dev/null
  sleep 2
  nohup sudo "$XRAY" -c "$CONFIG" >> "$LOG" 2>&1 &
  sleep 3
}

make_public() {
  if command -v gh >/dev/null 2>&1 && [ -n "$CODESPACE_NAME" ]; then
    gh codespace ports visibility 443:public -c "$CODESPACE_NAME" >/dev/null 2>&1
  fi
}

while true; do
  make_public

  if ! ss -tulnp 2>/dev/null | grep -q ':443'; then
    echo "[$(date)] Port 443 not listening" | tee -a "$LOG"
    start_xray
    make_public
  fi

  if ! pgrep -f "$XRAY" >/dev/null; then
    echo "[$(date)] Xray process not found" | tee -a "$LOG"
    start_xray
    make_public
  fi

  echo "[$(date)] OK - Xray running on 443" >> "$LOG"
  sleep 30
done
