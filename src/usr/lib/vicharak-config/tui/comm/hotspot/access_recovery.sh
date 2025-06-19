# shellcheck shell=bash

VOLTAGE_PATH="/sys/bus/iio/devices/iio:device0/in_voltage1_raw"
THRESHOLD=512
TRIGGERED_FLAG="/tmp/voltage_triggered.flag"
RND=$((1 + RANDOM % 1000))
SSID_NAME="Axon-$RND"
CON_NAME="Axon-$RND"

set_default_hotspot(){
	while true; do
		if [ -f "$VOLTAGE_PATH" ]; then

			voltage=$(cat "$VOLTAGE_PATH")

			if [ "$voltage" -lt "$THRESHOLD" ]; then
				if [ ! -f "$TRIGGERED_FLAG" ]; then
					echo "Voltage is below $THRESHOLD. Triggering command..."
					kernel_version=$(uname -r)

					if [[ "$kernel_version" == 5.10* ]]; then
						cd /sys/class/leds/:power/ || exit 1
					else
						cd /sys/class/leds/power-led/ || exit 1
					fi
					echo timer | sudo tee trigger
					echo 500 | sudo tee delay_on   # LED on for 500ms
					echo 500 | sudo tee delay_off  #
					touch "$TRIGGERED_FLAG"
					nmcli device wifi hotspot ifname wlan0 con-name "$CON_NAME" ssid "$SSID_NAME" password 12345678
					nmcli connection modify "$CON_NAME" 802-11-wireless-security.key-mgmt wpa-psk
					nmcli connection modify "$CON_NAME" ipv4.addresses 10.9.8.7/24
					nmcli connection up "$CON_NAME"
					ip_addr=$(ip -4 addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

					if [ -n "$ip_addr" ]; then
						echo "wlan0 has IP: $ip_addr"
					else
						echo "wlan0 has no IP address assigned."
					fi
				else
					echo ""
				fi
			fi
		else
			echo "Recovery Key cannot be accessible. $VOLTAGE_PATH"
		fi
		sleep 2
	done
}


__configure_iptables() {
	local usb_network="10.9.8.7/24"

	# Assuming Ethernet has "eth" or "en" prefix (e.g., eth0, enp3s0, end1)
	local iface
	iface=$(ip link show | awk -F: '/^[0-9]+: (eth|en)/ {print $2; exit}' | tr -d ' ')

	if [ -n "$iface" ]; then
		echo "Configuring NAT for usb0 (network ${usb_network}) via $iface..."
		iptables -t nat -A POSTROUTING -o "$iface" -s "$usb_network" -j MASQUERADE
		sysctl -w net.ipv4.ip_forward=1
	else
		echo "Error: No Ethernet interface found!"	
	fi
}

__configure_hotspot_recovery_key_enable(){
	echo "Configure Hotspot using Recovery Key Service is enabled."
	set_default_hotspot
	__configure_iptables

}

__configure_hotspot_recovery_key_disable(){
	echo "Configure Hotspot using Recovery Key Service is disabled."
}
