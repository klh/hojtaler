#!/usr/bin/env bash

echo ' killing active ALSA apps'
sudo pkill -9 -f 'aplay|speaker-test|snapclient' || true

echo 'restoring per-card mixer state'
sudo alsactl nrestore || true

echo ' setting test volume to 10%'
amixer -c0 -q sset SoftMaster 10%

echo 'test tone (Front_Center)'
aplay -q /usr/share/sounds/alsa/Front_Center.wav </dev/null &

echo 'ALSA config reloaded'