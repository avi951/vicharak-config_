# shellcheck shell=bash

# This script is executed by a systemd service

LOG_FILE="/tmp/hotspot.log"
exec >> "$LOG_FILE" 2>&1
echo "=============================="
echo "[DEBUG] Script started at: $(date)"
echo "[DEBUG] Running as: $(whoami)"
echo "[DEBUG] Current dir: $(pwd)"

# shellcheck source=/dev/null
source "/usr/lib/vicharak-config/tui/comm/hotspot/access_recovery.sh"
source "/usr/lib/vicharak-config/tui/comm/hotspot/on_boot_hotspot.sh"


#case "$1" in
#	on-boot-hotspot)
#		if [[ "$2" == "start" ]]; then
#			echo "[DEBUG] Starting on-boot hotspot"
#			sudo systemctl start configure-on-boot-hotspot.service
#		elif [[ "$2" == "stop" ]]; then
#			echo "[DEBUG] Stopping on-boot hotspot"
#			sudo systemctl stop configure-on-boot-hotspot.service
#		else
#			echo "[ERROR] Invalid command for on_boot_hotspot: $2"
#			exit 1
#		fi
#		;;
#	access_recovery)
#		if [[ "$2" == "start" ]]; then
#			echo "[DEBUG] Starting access recovery hotspot"
#			__configure_hotspot_recovery_key_enable
#		elif [[ "$2" == "stop" ]]; then
#			echo "[DEBUG] Stopping access recovery hotspot"
#			__configure_hotspot_recovery_key_disable
#		else
#			echo "[ERROR] Invalid command for access_recovery: $2"
#			exit 1
#		fi
#		;;
#
#	*)
#		echo "[ERROR] Unknown profile: $1"
#		exit 1
#		;;
#esac

echo "[DEBUG] Script finished at: $(date)"
#source "/usr/lib/vicharak-config/tui/comm/hotspot/access_recovery.sh"
#
#source "/usr/lib/vicharak-config/tui/comm/hotspot/on_boot_hotspot.sh"
#
#case "$1" in
#    access_recovery)
#        if [[ "$2" == "start" ]]; then
#            echo "start configure-hotspot"
#            __configure_hotspot_recovery_key_enable
#        elif [[ "$2" == "stop" ]]; then
#            echo "stop configure-hotspot"
#            __configure_hotspot_recovery_key_disable
#        else
#            echo "Invalid command: $2"
#            exit 1
#        fi
#        ;;
#    on_boot_hotspot)
#        if [[ "$2" == "start" ]]; then
#            echo "start configure-on-boot-hotspot"
#            __configure_hotspot_on_boot_enable
#        elif [[ "$2" == "stop" ]]; then
#            echo "stop configure-on-boot-hotspot"
#            __configure_hotspot_on_boot_disable
#        else
#            echo "Invalid command: $2"
#            exit 1
#        fi
#        ;;
#    *)
#        echo "Unknown profile: $1"
#        exit 1
#        ;;
#esac
