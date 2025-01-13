### Introduction

This is my installer for Arch Linux. It sets up a BTRFS system and full snapper support (both snapshotting and rollback work!).

The script is a fork of [Arch-Setup-Script](https://github.com/TommyTran732/Arch-Setup-Script/tree/main), which itself is based on [easy-arch](https://github.com/classy-giraffe/easy-arch). However, some changes are made to remove disk encryption and the hardenind done in [Arch-Setup-Script](https://github.com/TommyTran732/Arch-Setup-Script/tree/main). Some inspiration and changes are taken from the following [Youtube video](https://www.youtube.com/watch?v=maIu1d2lAiI) and from [This guide](https://sysguides.com/install-fedora-41-with-snapshot-and-rollback-support).

### How to use it?
1. Download an Arch Linux ISO from [here](https://archlinux.org/download/)
2. Flash the ISO onto an [USB Flash Drive](https://wiki.archlinux.org/index.php/USB_flash_installation_medium).
3. Boot the live environment.
4. Connect to the internet. iwcli for wifi. auto for ethernet.
5. `git clone https://github.com/SpanishHans/ArchSetup/`
6. `cd ArchSetup`
7. `chmod u+x ./install.sh`
8. `./install.sh`

### All commands

`git clone https://github.com/SpanishHans/ArchSetup/ && cd ArchSetup && chmod u+x ./install.sh && ./install.sh`

### Snapper behavior
The partition layout I use allows us to replicate the behavior found in openSUSE 🦎
1. Snapper-rollback <number> works! You will no longer need to manually rollback from a live USB like you would with the @ and @home layout suggested in the Arch Wiki.
3. Automatic snapshots on pacman install/update/remove operations
4. Directories such as `/var/log`, `/var/crash`, `/var/tmp`, `/var/spool`, `/var/lib/libvirt/images` are excluded from the snapshots as they either should be persistent or are just temporary files.# ArchSetup
# ArchSetup
