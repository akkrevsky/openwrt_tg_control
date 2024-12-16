# openwrt_tg_control

The script allows you to control switching on and off and shows general information about computers and the router in the network.
Сontrol is carried out by means of tg bot

Steps:
1. Change firmware yours router to OpenWrt
2. Connect from ssh to router
3. Install curl, jq
   ```bash
   opkg update
   opkg install curl, jq
   ```
5. Install wake-up packedge (etherwake)
   ```bash
   opkg update
   opkg install etherwake
   ```
6. Clone tg_bot.sh to /root/ 
7. Change mode executable file
   ```bash
   chmod +x /root/tg_bot.sh
   ```
8. Change <bot_token> <chat_id> in tg_bot.sh
9. Add script to autorun /etc/rc.local
   ```
   #!/bin/sh
   echo "tg_bot" > /tmp/startup.log
   /root/tg_bot.sh > /tmp/startup.log 2>&1 &

   exit 0
   ```
10. Сlear log (reboot or auto-script)

TODO: 
   - get all information about all nodes in network
   - add command to switch http luci-interface to external network
