# shellcheck shell=bash
# shellcheck source=src/usr/lib/vicharak-config/tui/comm/hotspot/hotspot.sh
source "/usr/lib/vicharak-config/tui/comm/hotspot/hotspot.sh"

__comm_network() {
	nmtui
}

__comm_bluetooth() {
	msgbox "Configure Bluetooth"
}

__comm() {
	menu_init
	menu_add __comm_network "Network"
	menu_add __comm_hotspot "Set up hotspot"

	if $DEBUG; then
		menu_add __comm_bluetooth "Bluetooth"
	fi
	menu_show "Manage Connectivity"
}
