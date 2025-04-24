#!/bin/bash
# Script to configure Shairport-Sync settings

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Default values
NAME="Cloudspeaker"
VOLUME_RANGE=60

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --name)
        NAME="$2"
        shift
        shift
        ;;
        --volume-range)
        VOLUME_RANGE="$2"
        shift
        shift
        ;;
        *)
        echo "Unknown option: $1"
        echo "Usage: $0 [--name NAME] [--volume-range RANGE_DB]"
        exit 1
        ;;
    esac
done

# Update Shairport-Sync configuration
sed -i "s/name = \".*\";/name = \"$NAME\";/g" /etc/shairport-sync.conf
sed -i "s/airplay_device_id = \".*\";/airplay_device_id = \"$NAME\";/g" /etc/shairport-sync.conf
sed -i "s/volume_range_db = [0-9]*;/volume_range_db = $VOLUME_RANGE;/g" /etc/shairport-sync.conf

# Restart Shairport-Sync
systemctl restart shairport-sync
