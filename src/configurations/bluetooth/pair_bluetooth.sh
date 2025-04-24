#!/bin/bash
# Script to pair a Bluetooth device

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "Enabling Bluetooth discovery mode..."
bluetoothctl -- power on
bluetoothctl -- discoverable on
bluetoothctl -- pairable on

echo "Scanning for devices for 30 seconds..."
bluetoothctl -- scan on &
SCAN_PID=$!
sleep 30
kill $SCAN_PID

echo "Available devices:"
bluetoothctl -- devices

echo ""
echo "To pair with a device, run:"
echo "bluetoothctl -- pair <MAC_ADDRESS>"
echo "bluetoothctl -- trust <MAC_ADDRESS>"
echo "bluetoothctl -- connect <MAC_ADDRESS>"
