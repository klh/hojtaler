Find disk:
diskutil list

Unmount:
diskutil unmountDisk /dev/disk2

Create Image:
sudo dd if=/dev/rdisk2 of=/Users/$(whoami)/raspberry_backup.img bs=1m

Restore image:
sudo dd if=~/Users/$(whoami)/raspberry_backup.img of=/dev/rdisk2 bs=1m