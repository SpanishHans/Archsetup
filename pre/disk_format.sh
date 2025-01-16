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

source ./pre/ext4_config.sh
source ./pre/btrfs_config.sh

select_disk_prompt() {
    local choice="$1"
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
    local DISK="${disks[$((disk_menu - 1))]}"
    eval "$choice='$DISK'"

    case $disk_menu in
        0)  exit;;
        *)  cgdisk $DISK
            return;;
    esac
}

select_efi_partition() {
    local part="$1"
    local form="$2"
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
    local EFI_PART="${partitions[$((esp_menu - 1))]}"
    local EFI_FORM=$(lsblk -no FSTYPE "$EFI_PART")
    eval "$part='$EFI_PART'"
    eval "$form='$EFI_FORM'"
}

select_root_partition() {
    local part="$1"
    local form="$2"
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

    menu_prompt root_menu root_menu_status "$title" "$description" "${menu_items[@]}"
    local ROOT_PART="${partitions[$((root_menu - 1))]}"
    local ROOT_FORM=$(lsblk -no FSTYPE "$ROOT_PART")
    eval "$part='$ROOT_PART'"
    eval "$form='$ROOT_FORM'"
}

determine_format() {
    local form="$1"
    while true; do
        local options=(\
            "Format as EXT4 (Reliable, fast, and widely supported. Ideal for most users, but lacks some advanced features of newer file systems like BTRFS.)" \
            "Format as BTRFS (Offers advanced features like snapshots and compression, but may have higher overhead and less compatibility compared to EXT4.)"
        )
        local title="ROOT filesystem prompt"
        local description="Please determine the filesystem to use on the ROOT System Partition (/)."

        menu_prompt format_menu_choice format_menu_choice_status "$title" "$description" "${options[@]}"
    
        case $format_menu_choice in
            1)  local ROOT_FSTYPE='ext4';;
            2)  local ROOT_FSTYPE='btrfs';;
            0)  exit;;
            *)  output "Invalid choice, please try again.";;
        esac
        pause_script "" "$ROOT_FSTYPE"
        eval "$form='$ROOT_FSTYPE'"
        break
    done
}

start_format() {
    continue_script 'Inform disk changes' 'Informing the Kernel about the disk changes.'

    local disks=($(lsblk -dpnoNAME | grep -P "/dev/nvme|sd|mmcblk|vd"))
    for di in "${disks[@]}"; do
        continue_script "partprobe on $di" "Running partprobe on $di"
        if ! partprobe "$di"; then
            continue_script '' "Failed to inform the kernel about changes for $di."
        fi
    done

    continue_script 'Format partition ESP: FAT32' "Formatting the /boot/efi partition on $EFI_PART as FAT32."
    if ! mkfs.fat -F 32 "${EFI_PART}"; then
        pause_script '' "Failed to format ${EFI_PART} as FAT32. Aborting."
        return 1
    fi

    if [[ "$ROOT_FSTYPE" == "ext4" ]]; then
        continue_script 'Format partition: EXT4' "Formatting the / partition on $ROOT_FSTYPE as EXT4."
        if ! mkfs.ext4 -F "${ROOT_PART}"; then
            pause_script '' "Failed to format ${ROOT_PART} as EXT4. Aborting."
            return 1
        fi
    elif [[ "$ROOT_FSTYPE" == "btrfs" ]]; then
        continue_script 'Format partition: BTRFS' "Formatting the / partition on $ROOT_FSTYPE as BTRFS."
        if ! mkfs.btrfs -f "${ROOT_PART}"; then
            pause_script '' "Failed to format ${ROOT_PART} as BTRFS. Aborting."
            return 1
        fi
    else
        echo "Unsupported ROOT_FSTYPE: $ROOT_FSTYPE"
        return 1
    fi
    pause_script 'Formatting finished' "Disks have been formatted.

EFI partition currently has the following filesystem: $(lsblk -no FSTYPE "$EFI_PART")
ROOT partition currently has the following filesystem: $(lsblk -no FSTYPE "$ROOT_PART")"

    local disks=($(lsblk -dpnoNAME | grep -P "/dev/nvme|sd|mmcblk|vd"))
    for di in "${disks[@]}"; do
        continue_script "partprobe on $di" "Running partprobe on $di"
        if ! partprobe "$di"; then
            continue_script '' "Failed to inform the kernel about changes for $di."
        fi
    done

    if [[ "$(lsblk -no FSTYPE "$ROOT_PART")" == "ext4" ]]; then
        continue_script 'Configuring on mode: EXT4' 'Executing commands for EXT4 Setup. WAIT.'
        run_ext4_setup
    elif [[ "$(lsblk -no FSTYPE "$ROOT_PART")" == "btrfs" ]]; then
        continue_script 'Configuring on mode: BTRFS' 'Executing commands for BTRFS Setup. WAIT.'
        run_btrfs_setup
    else
        echo "Unsupported filesystem type: $ROOT_FSTYPE"
        exit 1
    fi

}

disk_setup() {
    select_disk_prompt DISK
    select_efi_partition EFI_PART EFI_FORM
    select_root_partition ROOT_PART ROOT_FORM
    determine_format ROOT_FSTYPE

    export DISK
    export EFI_PART
    export EFI_FORM
    export ROOT_PART
    export ROOT_FORM
    export ROOT_FSTYPE
    pause_script "" "DISK:$DISK
EFI_PART:$EFI_PART
EFI_FORM:$EFI_FORM
ROOT_PART:$ROOT_PART
ROOT_FORM:$ROOT_FORM
ROOT_FSTYPE:$ROOT_FSTYPE"
}