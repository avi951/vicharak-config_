# shellcheck shell=bash

__comm_hotspot() {
	menu_init
	menu_add __enable_hotspot_boot "Enable Hotspot on boot"
	menu_add __enable_hotspot_recovery_button "Enable Hotspot while pressing Recovery Button"
	menu_show "Please select an option below:"
}

__enable_hotspot_boot() {
	 __set_credential_boot
}

__enable_hotspot_recovery_button() {
	__set_credential_recovery_button
}	


__set_credential_boot() {
	msgbox "a"
}


__set_credential_recovery_button(){
	msgbox "b"
}
