# DietPi Audio System

This is a complete audio system for Raspberry Pi Zero 2 W with HiFiBerry AMP4 HAT.

## Features
- Multiple audio sources with automatic switching:
  - Spotify Connect (librespot)
  - AirPlay (Shairport-Sync)
  - Bluetooth A2DP
  - Snapcast client
- Audio equalization (bass, treble, mids)
- ALSA dmix for hardware sharing

## Configuration Scripts

### Check System Status
```
sudo /path/to/config/check_status.sh
```

### Adjust Equalizer
```
sudo /path/to/config/adjust_eq.sh <preset>
```
Available presets: flat, bass, treble, mid, vshape

### Pair Bluetooth Device
```
sudo /path/to/config/pair_bluetooth.sh
```

### Configure Snapclient
```
sudo /path/to/config/snapclient_config.sh <snapserver_ip>
```

### Configure librespot (Spotify)
```
sudo /path/to/config/librespot_config.sh [options]
```
Example: `sudo /path/to/config/librespot_config.sh --name "Living Room" --bitrate 320 --volume 80`

### Configure Shairport-Sync (AirPlay)
```
sudo /path/to/config/shairport_config.sh [options]
```
Example: `sudo /path/to/config/shairport_config.sh --name "Living Room" --volume-range 70`

## Troubleshooting

If audio isn't working:
1. Check service status: `sudo /path/to/config/check_status.sh`
2. Test ALSA output: `aplay -D default /usr/share/sounds/alsa/Front_Center.wav`
3. Check logs: `journalctl -u librespot` or `journalctl -u shairport-sync`
