#!/bin/bash
# Script to manage Snapclient configuration

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Parse command line options
if [ $# -eq 0 ]; then
    # No arguments - use mDNS/Avahi for automatic discovery
    echo "Configuring Snapclient to use mDNS/Avahi for automatic server discovery..."
    
    # Remove any host specification if present
    sed -i 's/--host [^ ]*//' /etc/default/snapclient
    
    # Restart Snapclient service
    systemctl restart snapclient
    
    echo "Snapclient configured to automatically discover servers via mDNS/Avahi"
    exit 0
fi

# If a host is specified, configure to use that specific host
if [ "$1" = "--host" ] && [ $# -eq 2 ]; then
    SNAPSERVER_IP=$2
    
    echo "Configuring Snapclient to connect to specific server..."
    
    # Update Snapclient configuration to use specific host
    sed -i 's/SNAPCLIENT_OPTS="\(.*\)"/SNAPCLIENT_OPTS="--host '$SNAPSERVER_IP' \1"/' /etc/default/snapclient
    
    # Restart Snapclient service
    systemctl restart snapclient
    
    echo "Snapclient configured to connect to server at $SNAPSERVER_IP"
    exit 0
fi

echo "Usage: $0 [--host <snapserver_ip>]"
echo "  No arguments: Use mDNS/Avahi for automatic server discovery"
echo "  --host: Specify a server IP address to connect to"
