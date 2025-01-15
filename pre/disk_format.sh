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
    local disks=($(lsblk -dpnoNAME | grep -P "/dev/nvme|sd|mmcblk|vd"))
    local title="Starting disk picker"
    local description="The following menu shall help you edit and format disks for installing arch. the script requires 2 partitions:
    
1. Paritition where /boot/efi shall reside.
2. Paritition where /shall reside.

No swap is required as this script sets up zram automatically.

Please select a disk and format it to your liking. The script shall ask you for what partitions to use for what later."

    if [ ${#disks[@]} -eq 0 ]; then
            dialog --msgbox "No valid storage devices found. Exiting." 10 50
            exit 1
    fi
    
    menu_prompt disk_menu disk_menu_status "$title" "$description" "${disks[@]}"
    export disk="${disks[$((disk_menu - 1))]}"

    case $disk_menu in
        0)  exit;;
        *)  cgdisk $disk
            return;;
    esac
}

select_efi_partition() {
    local partitions=($(lsblk -ppnoNAME,SIZE,TYPE | grep -P "/dev/nvme|sd|mmcblk|vd" | grep -w "part" | sed 's/└─//g' | sed 's/├─//g' | awk '{print $1}'))
    local title="Select EFI Partition"
    local description="Please select a partition to use as the EFI System Partition (/boot/efi). ALL DATA SHALL BE WIPED"

    local menu_items=()
    local formatted_menu=()

    local max_no_len=2
    local max_partition_len=0
    local max_label_len=0
    local max_size_len=0
    local max_fstype_len=0
    
    for i in "${!partitions[@]}"; do
        local partition="${partitions[$i]}"
        local label=$(lsblk -no LABEL "$partition")
        local size=$(lsblk -no SIZE "$partition")
        local fstype=$(lsblk -no FSTYPE "$partition")

        max_partition_len=$((${#partition} > max_partition_len ? ${#partition} : max_partition_len))
        max_label_len=$((${#label} > max_label_len ? ${#label} : max_label_len))
        max_size_len=$((${#size} > max_size_len ? ${#size} : max_size_len))
        max_fstype_len=$((${#fstype} > max_fstype_len ? ${#fstype} : max_fstype_len))
    done

    for i in "${!partitions[@]}"; do
        local partition="${partitions[$i]}"
        local label=$(lsblk -no LABEL "$partition")
        local size=$(lsblk -no SIZE "$partition")
        local fstype=$(lsblk -no FSTYPE "$partition")

        menu_items+=("$(printf "%-${max_partition_len}s" "$partition") $(printf "%-${max_fstype_len}s" "$fstype") $(printf "%-${max_size_len}s" "$size") $(printf "%-${max_label_len}s" "$label")")
    done

    menu_prompt esp_menu esp_menu_status "$title" "$description" "${menu_items[@]}"
    EFI_PART="${partitions[$((esp_menu - 1))]}"
    export EFI_PART
}

select_root_partition() {
    local partitions=($(lsblk -ppnoNAME,SIZE,TYPE | grep -P "/dev/nvme|sd|mmcblk|vd" | grep -w "part" | sed 's/└─//g' | sed 's/├─//g' | awk '{print $1}'))
    local title="Select ROOT Partition"
    local description="Please select a partition to use as the ROOT System Partition (/). ALL DATA SHALL BE WIPED"

    local menu_items=()
    local formatted_menu=()

    local max_no_len=2
    local max_partition_len=0
    local max_label_len=0
    local max_size_len=0
    local max_fstype_len=0
    
    for i in "${!partitions[@]}"; do
        local partition="${partitions[$i]}"
        local label=$(lsblk -no LABEL "$partition")
        local size=$(lsblk -no SIZE "$partition")
        local fstype=$(lsblk -no FSTYPE "$partition")

        max_partition_len=$((${#partition} > max_partition_len ? ${#partition} : max_partition_len))
        max_label_len=$((${#label} > max_label_len ? ${#label} : max_label_len))
        max_size_len=$((${#size} > max_size_len ? ${#size} : max_size_len))
        max_fstype_len=$((${#fstype} > max_fstype_len ? ${#fstype} : max_fstype_len))
    done

    for i in "${!partitions[@]}"; do
        local partition="${partitions[$i]}"
        local label=$(lsblk -no LABEL "$partition")
        local size=$(lsblk -no SIZE "$partition")
        local fstype=$(lsblk -no FSTYPE "$partition")

        menu_items+=("$(printf "%-${max_partition_len}s" "$partition") $(printf "%-${max_fstype_len}s" "$fstype") $(printf "%-${max_size_len}s" "$size") $(printf "%-${max_label_len}s" "$label")")
    done

    menu_prompt esp_menu esp_menu_status "$title" "$description" "${menu_items[@]}"
    ROOT_PART="${partitions[$((esp_menu - 1))]}"
    ROOT_FSTYPE="$(lsblk -no FSTYPE "$ROOT_PART")"
    export ROOT_PART
    export ROOT_FSTYPE
}

start_format() {
    continue_script 'Inform disk changes' 'Informing the Kernel about the disk changes.'
    partprobe "${disk}"
    
    continue_script 'Format partition ESP: FAT32' 'Formatting the /boot/efi partition as FAT32.'
    mkfs.fat -F 32 "${EFI_PART}"

    if [[ "$ROOT_FSTYPE" == "ext4" ]]; then
        continue_script 'Format partition: EXT4' 'Formatting the / partition as EXT4.'
        mkfs.ext4 -F "${ROOT_PART}"
    elif [[ "$ROOT_FSTYPE" == "btrfs" ]]; then
        continue_script 'Format partition: BTRFS' 'Formatting the / partition as BTRFS.'
        mkfs.btrfs -f "${ROOT_PART}"
    else
        echo "Unsupported ROOT_FSTYPE: $ROOT_FSTYPE"
        return 1
    fi
}
