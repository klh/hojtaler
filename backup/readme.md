Find disk:
diskutil list

Unmount:
diskutil unmountDisk /dev/disk2

Create Image:
sudo dd if=/dev/rdisk4 of=/Users/$(whoami)/raspberry_backup.img bs=1m status=progress conv=sync

Restore image:
sudo dd if=backup/raspberry_backup.img of=/dev/rdisk4 bs=1m status=progress conv=sync