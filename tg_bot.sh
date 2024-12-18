#!/bin/sh

BOT_TOKEN="123:***"
CHAT_ID="***"
OFFSET=0

# Function to Send a Message
send_message() {
  local chat_id=$1
  local text=$2
  curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
       -d "chat_id=${chat_id}" \
       -d "text=${text}"
}

# Function to Fetch Updates
fetch_updates() {
  local response=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?offset=${OFFSET}")
  echo "${response}" | jq -c '.result[]'
}
       
# Main Loop to Handle Commands
while true; do
  updates=$(fetch_updates)
  if [ -n "${updates}" ]; then
    for update in ${updates}; do
      MESSAGE=$(echo "${update}" | jq -r '.message.text')
      UPDATE_ID=$(echo "${update}" | jq '.update_id')

      # Respond to Commands
      if [ "${MESSAGE}" = "/status" ]; then
        STATUS=$(uptime)
        send_message "${CHAT_ID}" "🟢OpenWRT Status: ${STATUS}"
      elif [ "${MESSAGE}" = "/ip" ]; then
        IP=$(curl -s -4 ifconfig.me)
        send_message "${CHAT_ID}" "✅Router Public IP: ${IP}"
      elif [ "${MESSAGE}" = "/ml_server_run" ]; then
        $(etherwake -i br-lan 00:F1:F3:D6:00:7D)
        send_message "${CHAT_ID}" "✅send magic packadge to ml_server"
      elif [ "${MESSAGE}" = "/ml_server_stop" ]; then
        $(sshpass -p "iamfriend" ssh -y sp@192.168.31.181 "shutdown.exe /s")
        send_message "${CHAT_ID}" "❌shutdown ml_server"
      elif [ "${MESSAGE}" = "/ml_server_cancel" ]; then
        $(sshpass -p "iamfriend" ssh -y sp@192.168.31.181 "shutdown.exe /a")
        send_message "${CHAT_ID}" "✅cancel shutdown ml_server"
      elif [ "${MESSAGE}" = "/web_open" ]; then
        $(uci set firewall.@redirect[0].enabled='1')
        $(uci commit firewall)
        $(/etc/init.d/firewall restart)
        send_message "${CHAT_ID}" "✅web interface opened through internet"
      elif [ "${MESSAGE}" = "/web_close" ]; then
        $(uci set firewall.@redirect[0].enabled='0')
        $(uci commit firewall)
        $(/etc/init.d/firewall restart)
        send_message "${CHAT_ID}" "❌web interface closed"
      elif [ "${MESSAGE}" = "/wireguard_on" ]; then
        $(ifup openwrt_WG)
        $(uci set firewall.@forwarding[0].dest='wireguard')
        $(uci commit firewall)
        $(/etc/init.d/firewall restart)
        send_message "${CHAT_ID}" "✅wireguard connected"
      elif [ "${MESSAGE}" = "/wireguard_off" ]; then
        send_message "${CHAT_ID}" "❌wireguard disconnected"
        $(ifdown openwrt_WG)
        $(ifdown dom)
        $(sleep 1)
        $(ifup dom)
        $(uci set firewall.@forwarding[0].dest='wan')
        $(uci commit firewall)
        $(/etc/init.d/firewall restart)
      else
        send_message "${CHAT_ID}" "Unknown Command. Try /status or /ip."
      fi

      OFFSET=$((UPDATE_ID + 1))
    done
  fi
  sleep 4
done
