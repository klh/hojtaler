#!/bin/bash
# Script to adjust equalizer settings

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Function to apply EQ preset
apply_preset() {
    local preset=$1
    local controls=""
    
    case $preset in
        flat)
            controls="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
            ;;
        bass)
            controls="7 6 5 3 1 0 0 0 0 0 0 0 0 0 0"
            ;;
        treble)
            controls="0 0 0 0 0 0 0 0 1 2 3 4 5 6 7"
            ;;
        mid)
            controls="0 0 0 1 2 3 4 3 2 1 0 0 0 0 0"
            ;;
        vshape)
            controls="6 5 4 2 0 -2 -3 -2 0 2 4 5 6 7 7"
            ;;
        custom)
            controls="4 3 2 0 -1 -2 -1 0 1 2 1 0 -2 -4 -5"
            ;;
        *)
            echo "Unknown preset: $preset"
            echo "Available presets: flat, bass, treble, mid, vshape, custom"
            exit 1
            ;;
    esac
    
    # Update asound.conf with the new controls
    sed -i "s/controls \[ .* \]/controls [ $controls ]/" /etc/asound.conf
    
    echo "Applied $preset EQ preset"
    echo "You may need to restart audio services for changes to take effect"
}

# Main script
if [ $# -eq 0 ]; then
    echo "Usage: $0 <preset>"
    echo "Available presets: flat, bass, treble, mid, vshape, custom"
    exit 1
fi

apply_preset "$1"
