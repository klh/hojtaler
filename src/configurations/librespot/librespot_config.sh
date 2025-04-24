#!/bin/bash
# Script to configure librespot settings

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Default values
NAME="Cloudspeaker"
BITRATE=320
VOLUME=100

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --name)
        NAME="$2"
        shift
        shift
        ;;
        --bitrate)
        BITRATE="$2"
        shift
        shift
        ;;
        --volume)
        VOLUME="$2"
        shift
        shift
        ;;
        *)
        echo "Unknown option: $1"
        echo "Usage: $0 [--name NAME] [--bitrate BITRATE] [--volume VOLUME]"
        exit 1
        ;;
    esac
done

# Update librespot configuration
sed -i "s/--name \".*\"/--name \"$NAME\"/g" /etc/systemd/system/librespot.service.d/override.conf
sed -i "s/--bitrate [0-9]*/--bitrate $BITRATE/g" /etc/systemd/system/librespot.service.d/override.conf
sed -i "s/--initial-volume [0-9]*/--initial-volume $VOLUME/g" /etc/systemd/system/librespot.service.d/override.conf

# Reload systemd and restart librespot
systemctl daemon-reload
systemctl restart librespot

echo "librespot configured with:"
echo "  Name: $NAME"
echo "  Bitrate: $BITRATE kbps"
echo "  Initial volume: $VOLUME%"
