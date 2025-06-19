# shellcheck shell=bash
# shellcheck source=src/usr/lib/vicharak-config/cli/hotspot.sh

# shellcheck source=src/usr/lib/vicharak-config/cli/hotspot-method.sh
source "/usr/lib/vicharak-config/tui/comm/hotspot/hotspot-method.sh"

status=""
check_status=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev | awk -F: '$1=="wlan0" && $3=="connected" {print $4}')
if [ -z "$check_status" ]; then
    status="ON"
else
    status="OFF"
fi

__create_hotspot() {
    local ssid pass ip
    msgbox "Hotspot will be using wlan0 Interface."
    
    # Prompt for SSID
    if ! ssid=$(inputbox "Enter SSID for the hotspot:" "Axon_0.0.1"); then
        msgbox "SSID input cancelled."
        return 0
    fi

    # Prompt for Password
    if ! pass=$(inputbox "Enter password (min 8 chars):" "12345678"); then
        msgbox "Password input cancelled."
        return
    fi

    # Password is too short
    if [ "${#pass}" -lt 8 ]; then
        msgbox "Password too short. Must be at least 8 characters."
        return
    fi

    # Prompt for IP Address
    if ! ip=$(inputbox "Enter static IP address for hotspot (CIDR /24):" "10.9.8.7"); then
        msgbox "IP address input cancelled."
        return
    fi

    # Validate IPv4
    is_valid_ipv4() {
        local ip="$1"
        if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
            IFS='.' read -r -a octets <<< "$ip"
            for octet in "${octets[@]}"; do
                if ((octet < 0 || octet > 255)); then
                    msgbox "Invalid IP: $ip (octet out of range)"
                    return 1
                fi
            done
            return 0
        else
            msgbox "Invalid IP format: $ip"
            return 1
        fi
    }
    
    if ! is_valid_ipv4 "$ip"; then
        return
    fi

    # Run the hotspot creation commands in a subshell to capture the exit status
    if (
        progress=0
        echo "$progress"
        sleep 0.5

        if sudo nmcli device wifi hotspot ifname wlan0 con-name "$ssid" ssid "$ssid" password "$pass"; then
            progress=25
            echo "$progress"
            sleep 0.5
        fi

        if sudo nmcli connection modify "$ssid" 802-11-wireless-security.key-mgmt wpa-psk; then
            progress=50
            echo "$progress"
            sleep 0.5
        fi

        if sudo nmcli connection modify "$ssid" ipv4.addresses "$ip/24"; then
            progress=75
            echo "$progress"
            sleep 0.5
        fi

        if sudo nmcli connection modify "$ssid" ipv4.method shared \
            && sudo nmcli connection modify "$ssid" connection.autoconnect yes \
            && sudo nmcli connection up "$ssid"; then
            progress=100
            echo "$progress"
            sleep 0.5
        fi
    ) | __dialog --gauge "Creating $ssid..." 10 60 0; then
        clear
        msgbox "Manually '$ssid' created with IP $ip"
        status="OFF"
    else
        clear
        msgbox "Failed to create hotspot."
    fi
}

__change_ssid() {
    local cur_ssid new_ssid
    wifi_iface="wlan0"
    cur_ssid=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev | awk -F: '$1=="wlan0" && $3=="connected" {print $4}')

    if [ -n "$cur_ssid" ]; then
        if ! new_ssid=$(whiptail --inputbox "Current SSID $(iwgetid -r) Enter new SSID name:" 8 50 --title "Change SSID" 3>&1 1>&2 2>&3) \
           || [ -z "$new_ssid" ] || [ "$new_ssid" == "$cur_ssid" ]; then
            whiptail --msgbox "SSID is not changed for $wifi_iface Interface." 8 50 --title "Error"
            return
        fi

        {
            progress=0; echo "$progress"; sleep 0.5

            if nmcli connection modify "$cur_ssid" 802-11-wireless.ssid "$new_ssid"; then
                progress=30; echo "$progress"; sleep 0.5
            fi

            if nmcli connection down "$cur_ssid"; then
                progress=60; echo "$progress"; sleep 0.5
            fi

            if nmcli connection up "$cur_ssid"; then
                progress=100; echo "$progress"; sleep 0.5
            fi
        } | __dialog --gauge "Changing $cur_ssid to $new_ssid ..." 10 60 0
        clear
    else
        whiptail --msgbox "Failed to change SSID for $wifi_iface Interface." 8 50 --title "Error"
    fi
}

__change_password() {
    wifi_iface="wlan0"

    ssid=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev | awk -F: -v iface="$wifi_iface" '$1==iface && $3=="connected" {print $4}')
    #ssid=$(iwgetid -r)
    if [ -z "$ssid" ]; then
        whiptail --msgbox "No active Wi-Fi connection on $wifi_iface." 8 50 --title "Error"
        return
    fi

    if ! password=$(whiptail --passwordbox "Enter new password for $(iwgetid -r)  (min 8 characters):" 8 50 --title "Change Password" 3>&1 1>&2 2>&3) \
       || [ -z "$password" ]; then
        whiptail --msgbox "Password is not changed." 8 40 --title "Error"
        return
    fi

    if [ "${#password}" -lt 8 ]; then
        whiptail --msgbox "Password must be at least 8 characters." 8 40 --title "Error"
        return
    fi

    {
        progress=0; echo "$progress"; sleep 0.5

        if nmcli connection modify "$ssid" wifi-sec.key-mgmt wpa-psk; then
            progress=40; echo "$progress"; sleep 0.5
        fi

        if nmcli connection modify "$ssid" wifi-sec.psk "$password"; then
            progress=70; echo "$progress"; sleep 0.5
        fi

        if nmcli connection down "$ssid" && nmcli connection up "$ssid"; then
            progress=100; echo "$progress"; sleep 0.5
        fi
    } | __dialog --gauge "Changing password for '$(iwgetid -r)'..." 10 60 0

    clear
}

__show_hotspot() {
    wifi_iface="wlan0"
    CONN_NAME=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev | awk -F: '$1=="wlan0" && $3=="connected" {print $4}')

    if [ -z "$CONN_NAME" ]; then
        whiptail --msgbox "No active Wi-Fi connection on $wifi_iface." 8 50 --title "Error"
        return
    fi

    PASSWORD=$(sudo nmcli -s -g 802-11-wireless-security.psk connection show "$CONN_NAME")
    IPv4=$(nmcli -g IP4.ADDRESS device show wlan0)
    SSID=$(iwgetid -r)

    if [ -n "$SSID" ]; then
        whiptail --msgbox " * SSID : $SSID \n * PASSWORD: $PASSWORD \n * IPv4: $IPv4\n " 10 40 --title "Show hotspot details:"
    else
        whiptail --msgbox "No active Wi-Fi connection on $wifi_iface." 8 50 --title "Error"
    fi
}

__change_status(){
    CONN_NAME=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev | awk -F: '$1=="wlan0" && $3=="connected" {print $4}')

    if [ -n "$CONN_NAME" ]; then
        nmcli device disconnect wlan0
        whiptail --msgbox "$CONN_NAME is turned off successfully." 8 50 --title "Status"
        status="ON"
    else
        msgbox "Click on Create Hotspot"
    fi
}

__comm_hotspot() {
    menu_init
    menu_add __create_hotspot "Create Hotspot/Turn On"
    menu_add __change_ssid "Change SSID"
    menu_add __change_password "Change Password"
    menu_add __show_hotspot "Show hotspot Details"
    menu_add __change_method_hotspot "Change Method to Access Hotspot"
    if [ "$status" = "OFF" ]; then
        menu_add __change_status "Turn Hotspot $status"
    fi
    menu_show "Please select an option below:"
}
