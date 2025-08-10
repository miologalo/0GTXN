#!/bin/bash

# === CONFIG ===
LOCAL_RPC="http://localhost:5678"
EXPLORER_API="https://chainscan-galileo.0g.ai/stat/gasprice/tracker"
TG_BOT_TOKEN="YOUR_BOT_TOKEN"
TG_CHAT_ID="YOUR_CHAT_ID"

prevHeight=0
prevTime=0

send_tg() {
  local message="$1"
  curl -s -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
       -d chat_id="${TG_CHAT_ID}" \
       -d parse_mode="Markdown" \
       -d text="$message" >/dev/null
}

while true; do
  response=$(curl -s -X POST "$LOCAL_RPC" \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"zgs_getStatus","params":[],"id":1}')
  
  localHeight=$(echo "$response" | jq '.result.logSyncHeight // 0')
  peers=$(echo "$response" | jq '.result.connectedPeers // 0')
  now=$(date +"%s")
  
  if (( prevHeight > 0 )); then
    diffHeight=$((localHeight - prevHeight))
    diffTime=$((now - prevTime))
    if (( diffTime > 0 )); then
      speed=$((diffHeight / diffTime))
    else
      speed=0
    fi
  else
    speed=0
  fi

  prevTime=$now

  explorerResp=$(curl -s "$EXPLORER_API")
  explorerHeight=$(echo "$explorerResp" | jq '.result.blockHeight // 0')

  diff=$((explorerHeight - localHeight))

  if (( diff > 50 )); then
    status="🔴 BEHIND: $diff"
  else
    status="🟢 SYNCED"
  fi

  # Print to terminal
  printf "🧱 Logs Block:%7d | 🌍 Live Block:%7d | 🤝 Peers:%3d | 🚀 Speed:%3d blk/s | %s\n" \
    "$localHeight" "$explorerHeight" "$peers" "$speed" "$status"

  # Send Telegram notification every block update
  if (( localHeight != prevHeight )); then
    send_tg "🧱 *Logs:* $localHeight | 🌍 *Live:* $explorerHeight | 🤝 *Peers:* $peers | 🚀 *Speed:* ${speed}blk/s | $status"
  fi

  prevHeight=$localHeight
  sleep 5
done
