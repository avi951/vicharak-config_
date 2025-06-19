#!/bin/bash

set -x
#!/bin/bash

SSID="Axon-HP"
PASSWORD="12345678"
HOTSPOT_NAME="axon_hotspot"
HOTSPOT_IP="10.9.8.4/24"
LOG_FILE="/var/log/hotspot_setup.log"
VOLTAGE_PATH="/sys/bus/iio/devices/iio:device0/in_voltage1_raw"

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Clean up old connections with same name
cleanup_old_connections() {
	local old_conns
	old_conns=$(nmcli -t -f NAME connection show | grep -Fx "$HOTSPOT_NAME")
	for conn in $old_conns; do
		nmcli connection delete "$conn"
		log "Deleted old connection: $conn"
	done
}

# Create hotspot fresh
create_hotspot() {
	log "Creating new hotspot connection"
	nmcli connection add type wifi ifname wlan0 con-name "$HOTSPOT_NAME" autoconnect no ssid "$SSID"

	if [ -f "$VOLTAGE_PATH" ]; then

		kernel_version=$(uname -r)

		if [[ "$kernel_version" == 5.10* ]]; then
			cd /sys/class/leds/:power/ || exit 1
		else
			cd /sys/class/leds/power-led/ || exit 1
		fi
		echo timer | sudo tee trigger
		echo 500 | sudo tee delay_on   # LED on for 500ms
		echo 500 | sudo tee delay_off  #


		nmcli connection modify "$HOTSPOT_NAME" \
			802-11-wireless.mode ap \
			802-11-wireless.band bg \
			ipv4.method manual \
			ipv4.addresses "$HOTSPOT_IP" \
			wifi-sec.key-mgmt wpa-psk \
			wifi-sec.psk "$PASSWORD"

		if nmcli connection up "$HOTSPOT_NAME"; then
			log "SUCCESS: Hotspot '$HOTSPOT_NAME' is up"
		else
			log "ERROR: Failed to activate hotspot"
		fi
	fi
}

__configure_hotspot_on_boot_enable(){
    echo "Configure Hotspot using on boot Service is enabled." > /var/log/hotspot_status.log
	nmcli device set wlan0 managed yes
	cleanup_old_connections
	create_hotspot
	log "Script execution completed."
}

__configure_hotspot_on_boot_disable(){
    echo "Configure Hotspot using on boot Service is disabled." > /var/log/hotspot_status.log
}
#SSID="Axon-HP"
#PASSWORD="12345678"
#HOTSPOT_NAME="axon_hotspot"
#HOTSPOT_IP="10.9.8.4/24"
#LOG_FILE="/var/log/hotspot_setup.log"
##VOLTAGE_PATH="/sys/bus/iio/devices/iio:device0/in_voltage1_raw"
##
#log() {
#    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
#}
##
### Clean up old connections with same name
##cleanup_old_connections() {
##    local old_conns
##    old_conns=$(nmcli -t -f NAME connection show | grep -Fx "$HOTSPOT_NAME")
##    for conn in $old_conns; do
##        nmcli connection delete "$conn"
##        log "Deleted old connection: $conn"
##    done
##}
##
### Create hotspot fresh
##create_hotspot() {
##    log "Creating new hotspot connection"
##    nmcli connection add type wifi ifname wlan0 con-name "$HOTSPOT_NAME" autoconnect no ssid "$SSID"
##
##    if [ -f "$VOLTAGE_PATH" ]; then
##
##        kernel_version=$(uname -r)
##
##        if [[ "$kernel_version" == 5.10* ]]; then
##            cd /sys/class/leds/:power/ || exit 1
##        else
##            cd /sys/class/leds/power-led/ || exit 1
##        fi
##        echo timer | sudo tee trigger
##        echo 500 | sudo tee delay_on   # LED on for 500ms
##        echo 500 | sudo tee delay_off  #
##
##
##        nmcli connection modify "$HOTSPOT_NAME" \
##            802-11-wireless.mode ap \
##            802-11-wireless.band bg \
##            ipv4.method manual \
##            ipv4.addresses "$HOTSPOT_IP" \
##            wifi-sec.key-mgmt wpa-psk \
##            wifi-sec.psk "$PASSWORD"
##
##        if nmcli connection up "$HOTSPOT_NAME"; then
##            log "SUCCESS: Hotspot '$HOTSPOT_NAME' is up"
##        else
##            log "ERROR: Failed to activate hotspot"
##        fi
##    fi
##}
#
#main() {
#    log "Starting hotspot script"
#
##    nmcli device set wlan0 managed yes
##    cleanup_old_connections
##    create_hotspot
#
#    # Define the interfaces to check
##    interfaces=("wlan0" "p2p0" "end0" "eth0")
##    
##    # Check for internet connectivity on listed interfaces
##    for iface in "${interfaces[@]}"; do
##        if ip link show "$iface" | grep -q "state UP"; then
##            if ping -I "$iface" -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
##                echo "Internet available via $iface. No need to start hotspot."
##                exit 0
##            fi
##        fi
##    done
##    
#    echo "No internet available. Starting hotspot..."
#    
#    # Your fixed hotspot setup commands
#    nmcli device wifi hotspot ifname wlan0 ssid MyHotspot password MyPassword
#    nmcli connection modify Hotspot ipv4.addresses 10.9.8.1/24
#    nmcli connection modify Hotspot ipv4.method shared
#    nmcli connection up Hotspot
#
#    log "Script execution completed."
#}
#
#__configure_hotspot_on_boot_enable(){
#    echo "Configure Hotspot using on boot Service is enabled." > /var/log/hotspot_status.log
#    main
#}
#
#__configure_hotspot_on_boot_disable(){
#    echo "Configure Hotspot using on boot Service is disabled." > /var/log/hotspot_status.log
#}
