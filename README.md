# DietPi Audio System

A complete setup for Raspberry Pi Zero 2 W with HiFiBerry AMP4 HAT running multiple audio sources:
- Spotify (librespot)
- AirPlay (shairport-sync)
- Bluetooth A2DP
- Snapcast client

## Features
- Automatic source switching based on active audio
- Audio equalization (bass, treble, mids)
- ALSA dmix for hardware sharing
- Unattended setup via scripts

## Setup Steps
1. Flash DietPi & initial system prep
2. Install runtime dependencies
3. Configure ALSA for dmix + EQ
4. Enable BlueALSA for Bluetooth A2DP
5. Configure Snapclient
6. Configure librespot (Spotify)
7. Configure Shairport-Sync (AirPlay2)
8. Final reboot & verification

## Usage
Run the main setup script:
```
./src/scripts/setup.sh
```

See individual configuration files in the `config` directory for customization options.
