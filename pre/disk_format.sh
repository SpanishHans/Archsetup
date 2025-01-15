#!/bin/bash

# Copyright (C) 2021-2024 Thien Tran, Tommaso Chiti
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

source ./commons.sh

select_disk_prompt() {
    local devices=($(lsblk -dpnoNAME | grep -P "/dev/nvme|sd|mmcblk|vd"))
    local title="Starting disk picker"
    local description="The following menu shall help you edit and format disks for installing arch. the script requires 2 partitions:\
1. Paritition where /boot/efi shall reside. 
2. Paritition where /shall reside

No swap is required as this script sets up zram automatically.

Please select a disk and format it to your liking. The script shall ask you for what partitions to use for what later."

    if [ ${#devices[@]} -eq 0 ]; then
            dialog --msgbox "No valid storage devices found. Exiting." 10 50
            exit 1
    fi
    
    menu_prompt disk_menu disk_menu_status "$title" "$description" "${devices[@]}"

    case $disk_menu in
        0)  exit;;
        *)  export disk="${devices[$((disk_menu - 1))]}";;
    esac
}

partition_disk_prompt() {
    local partitions=(
        "1" "Partition disk using ext4 (recommended for Linux-based systems, stable and widely supported)"
        "2" "Partition disk using ext3 (older filesystem format, less efficient)"
        "3" "Partition disk using Btrfs (advanced filesystem with support for snapshots and compression)"
    )
    local title="Starting disk picker"
    local description="This script only allows for FULLDISK install, cancel now with option 0 or ctrl+c if this is not what you want.
Select a disk from the disk below with its number."
    
    menu_prompt disk_menu disk_menu_status "$title" "$description" "${devices[@]}"

    case $disk_menu in
        1)  exit;;
        2)  exit;;
        3)  exit;;
        0)  exit;;
        *)  export disk="${devices[$((disk_menu - 1))]}";;
    esac
}

continue_script 'Formatting' "Proceeding to formatting of:    ${disk}."
sgdisk --zap-all "${disk}"
continue_script 'Partition scheme' "Creating new partition scheme on ${disk}."
continue_script 'Partition table' "Creating new gpt table ${disk}."
sgdisk -g "${disk}"
continue_script 'Partition name: ESP' "Creating new partition with name ESP ${disk}."
sgdisk -I -n 1:0:+1G -t 1:ef00 -c 1:'ESP' "${disk}"
continue_script 'Partition name: Arch' "Creating new partition with name Arch ${disk}."
sgdisk -I -n 2:0:0 -c 2:'Arch' "${disk}"

export ESP='/dev/disk/by-partlabel/ESP'
export BTRFS='/dev/disk/by-partlabel/Arch'

continue_script 'Inform disk changes' 'Informing the Kernel about the disk changes.'
partprobe "${disk}"
continue_script 'Format partition ESP: FAT32' 'Formatting the EFI partition as FAT32.'
mkfs.fat -F 32 "${ESP}"
continue_script 'Format partition Arch: BTRFS' 'Formatting the Arch partition as BTRFS.'
mkfs.btrfs -f "${BTRFS}"