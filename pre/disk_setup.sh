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

choose_custom_or_default_layout() {
    local title="Entered disk setup!" 
    local description='The following section will help you configure anything disk related: Formatting, partitioning and mounting. Keep in mind those operations are DESTRUCTIVE and will result in data loss for the disks or partitions involved. 
    
BACKUP DATA BEFORE PROCEEDING, you have been warned!
    
Linux allows you to do whatever the fuck you want. If you so wish, parts of the system could be mounted to USB devices for all we care. We assume that your computer is modern enough to have UEFI support and that root is going to be on an SSD. If those conditions are not met, this script is not for you.
We transfer the responsability of a reasonable setup to you, the final user. Yet, we provide some sane defaults if you prefer a "batteries included" experience.

The default setup aims to give you full rollback support by using Copy on Write (CoW) from the new kid in the block: BTRFS. This makes it possible to go to a previous system state if an update breaks something...Useful on Archlinux.

Default btrfs layout is as follows:
    1. Paritition for /boot/efi. (Therefore no BIOS support, only UEFI.)
    2. Paritition for /. (Ergo /home is on the same partition as /)
    3. Subvolumes for things that should not be snappshotted and that should stay intact after a rollback like logs or temps or cache.

No swap is required in any mode as this script sets up zram automatically.

With this in mind, lets pick between sane defaults or full custom mode.'
    local options=(\
        "Go the default route" \
        "Go the fully custom route" \
        "Exit"
    )
    while true; do
        menu_prompt install_mode_menu install_mode_menu_status "$title" "$description" "${options[@]}"
        case $install_mode_menu in
            0)  default_route;;
            1)  full_custom_route;;
            e)  exit;;
            *)  pause_script "Option not valid" "That is not an option, returning to start menu.";exit;;
        esac
    done
}

default_route() {
    # continue_script "Default route" "You chose to use the default route"
    format_and_partition_disks
    set_filesystem_for_partitions
    exit
}

full_custom_route() {
    continue_script "Custom route" "You chose to use the custom route"
    pause_script "" "continue"
}

format_and_partition_disks() {
    local disks=($(lsblk -dpnoNAME | grep -P "/dev/nvme|sd|mmcblk|vd"))
    local disks+=("Continue")
    local disks+=("Exit")
    local title="Starting disk partitioner"
    local description="The following menu shall help you format and partition disks in order to make space for installing arch. 
    
Simply select a disk, format and come back here. When done, select option 1 to continue script execution."

    if [ ${#disks[@]} -eq 0 ]; then
            pause_script "No disks found" "No valid storage devices found. Exiting."
            exit
    fi

    while true; do
        menu_prompt format_disk_menu_choice format_disk_menu_status "$title" "$description" "${disks[@]}"
        local DISK="${disks[$((format_disk_menu_choice))]}"
        case $format_disk_menu_choice in
            c)  break;;
            e)  exit;;
            *)  if ! cgdisk "$DISK"; then
                    continue_script "Exited cgdisk for $DISK" "cgdisk exited for disk $DISK. Returning to menu."
                fi
                ;;
        esac
    done
}

set_filesystem_for_partitions() {
    local partitions=($(lsblk -ppnoNAME,SIZE,TYPE | grep -P "/dev/nvme|sd|mmcblk|vd" | grep -w "part" | sed 's/└─//g' | sed 's/├─//g' | awk '{print $1}'))
    local partitions+=("Continue")
    local partitions+=("Exit")
    local title="Starting partition formatter"
    local description="The following menu shall help you assing a filesystem to a selected partition. 
    
Simply select a partition, format it on the menu that opens up and then come back here. When done, select option 1 to continue script execution."

    if [ ${#partitions[@]} -eq 0 ]; then
            pause_script "No partitions found" "No valid partitions found. Exiting."
            exit
    fi

    while true; do
        menu_prompt format_partition_menu format_partition_menu_status "$title" "$description" "${partitions[@]}"
        local partition="${partitions[$((format_partition_menu))]}"
        case $format_partition_menu in
            c)  break;;
            e)  exit;;
            *)  format_a_partition "$partition"
                ;;
        esac
    done
}

format_a_partition() {
    local partition="$1"
    
    local title="Pick a filesystem for $partition"
    local description="You are now setting a filesystem for partition $partition. 
    
Please select a filesystem for it from the following:"
    local options=(\
        "Format as EXT4" \
        "Format as BTRFS" \
        "Back" \
        "Exit"
    )
    menu_prompt partition_menu partition_menu_status "$title" "$description" "${options[@]}"
    local partition="${partitions[$((partition_menu))]}"
    case $partition_menu in
        0)  format_as_ext4 "$partition";;
        1)  format_as_btrfs "$partition";;
        b)  break;;
        e)  exit;;
        *)  continue_script "Option not valid" "That is not an option, retry.";;
    esac
}

format_as_ext4() {
    local partition="$1"
    continue_script "Formatting $partition as EXT4" "You have decided to partition $partition as EXT4. FORMATTING..."
    mkfs.ext4 -F "${partition}"
    pause_script "$partition formatted" "the partition $partition has been formatted to EXT4,"
}

format_as_btrfs() {
    local partition="$1"
    continue_script "Formatting $partition as BTRFS" "You have decided to partition $partition as BTRFS. FORMATTING..."
    mkfs.btrfs -f "${partition}"
    pause_script "$partition formatted" "the partition $partition has been formatted to BTRFS,"
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

    menu_prompt root_menu root_menu_status "$title" "$description" "${menu_items[@]}"
    local EFI_PART="${partitions[$((root_menu - 1))]}"
    local EFI_FORM=$(lsblk -no FSTYPE "$EFI_PART")
    eval "$part='$EFI_PART'"
    eval "$form='$EFI_FORM'"
    pause_script "efi test" "$EFI_PART $(lsblk -f | grep "$EFI_PART")"
    pause_script "efi test" "$part $form"
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
    pause_script "root test" "$ROOT_PART $ROOT_FORM"
    pause_script "root test" "$part $form"
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

start_disk_setup() {
    clear
    choose_custom_or_default_layout
}

    # format_and_partition_disks
    # set_filesystem_for_partitions


#     determine_format ROOT_FSTYPE
#     select_efi_partition EFI_PART EFI_FORM
#     select_root_partition ROOT_PART ROOT_FORM
    

#     export DISK
#     export EFI_PART
#     export EFI_FORM
#     export ROOT_PART
#     export ROOT_FORM
#     export ROOT_FSTYPE
#     pause_script 'Preview format' "You are about to format the partitions in the following way:

# EFI partition will be on: $EFI_PART
# ROOT partition will be on: $ROOT_PART

# EFI partition currently has the following filesystem: $EFI_FORM
# ROOT partition currently has the following filesystem: $ROOT_FORM

# EFI partition will have the following filesystem: $EFI_FORM
# ROOT partition will have the following filesystem: $ROOT_FSTYPE

# press ok to format or CANCEL NOW with ctrl+c or by selecting 0. Exit on the menu."
    # start_format