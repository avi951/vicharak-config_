#!/bin/bash

SSID="Axon-HP"
PASSWORD="12345678"
HOTSPOT_IP="10.9.8.7/24"
HOTSPOT_NAME="axon_hotspot"

# Check if eth0 has IP
ETH_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Check if wlan0 has IP
WLAN_IP=$(ip -4 addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

if [[ -z "$ETH_IP" && -z "$WLAN_IP" ]]; then
    echo "No network detected on eth0 or wlan0. Creating hotspot..."

    # Delete existing hotspot if exists
    nmcli connection delete "$HOTSPOT_NAME" 2>/dev/null
    # Create new hotspot
    nmcli device set wlan0 managed yes
    nmcli connection add type wifi ifname wlan0 con-name "$HOTSPOT_NAME" autoconnect no ssid "$SSID"
    nmcli connection modify "$HOTSPOT_NAME" 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method manual \
	    ipv4.addresses "$HOTSPOT_IP" wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$PASSWORD"

    # Bring up hotspot
    nmcli connection up "$HOTSPOT_NAME"

    kernel_version=$(uname -r)

    if [[ "$kernel_version" == 5.10* ]]; then
	    cd /sys/class/leds/:power/ || exit 1
    else
	    cd /sys/class/leds/power-led/ || exit 1
    fi

    echo timer | sudo tee trigger
    echo 500 | sudo tee delay_on   # LED on for 500ms
    echo 500 | sudo tee delay_off  # LED off for 500ms
    echo "Hotspot created: SSID=$SSID, IP=$HOTSPOT_IP"
else
	echo "Network already available on eth0 or wlan0."
	echo "eth0 IP: ${ETH_IP:-None}, wlan0 IP: ${WLAN_IP:-None}"
fi
