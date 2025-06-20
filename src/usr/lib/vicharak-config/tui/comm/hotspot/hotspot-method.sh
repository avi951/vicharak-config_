# shellcheck shell=bash

__configure_hotspot_recovery_key() {
	# Check if USB tethering service is active

	msgbox "Recovery key will be used to turn on and off hotspot."
	if systemctl is-active --quiet configure-hotspot@access_recovery.service; then
		if yesno "Configure hotspot using recovery key is currently enabled. Do you want to disable it?"; then
			if systemctl disable --now configure-hotspot@access_recovery.service; then
				msgbox "Configure Hotspot using Recovery Key successfully disabled!"
			else
				msgbox "Failed to disable hotspot functionality."
			fi
		fi
	else
		if yesno "Configure Hotspot using recovery key is currently disabled. Do you want to enable it?"; then
			if systemctl enable --now configure-hotspot@access_recovery.service; then
				msgbox "Configure WiFi Hotspot using Recovery Key successfully enabled!"
			else
				msgbox "Failed to Configure WiFi Hotspot using Recovery Key."
			fi
		fi
	fi
}


__configure_hotspot_on_boot() {
	# Check if USB tethering service is active

	msgbox "This Feature allows Board to turn on hotspot automatically as it does not get any network provider thorugh WiFi or Ethernet. Default Configuration on first time boot hostpot is : \nSSID : Axon-HP\nPASSWORD : 12345678\nIPv4: 10.9.8.7\n"
	if systemctl is-active --quiet auto-hotspot.service; then
		if yesno "Hotspot will turn on with default SSID Axon-HP and Password 12345678 on boot. Do you want to disable it?"; then
			if systemctl disable --now auto-hotspot.service; then
				msgbox "Turn on Hotspot on each boot successfully disabled!"
			else
				msgbox "Failed to disable hotspot on each boot functionality."
			fi
		fi
	else
		if yesno "Hotspot will not be used on each boot is currently disabled. Do you want to enable it?"; then
			if systemctl enable --now auto-hotspot.service; then
				msgbox "Turn on Hotspot on each boot successfully enabled!"
			else
				msgbox "Failed to Configure Hotspot on boot functionality"
			fi
		fi
	fi
}

__change_method_hotspot(){
	menu_init
	menu_add __configure_hotspot_recovery_key "Access through Recovery Key"
	menu_add __configure_hotspot_on_boot "Access through on Boot"
	menu_show "Method To Access hotspot :"
}
