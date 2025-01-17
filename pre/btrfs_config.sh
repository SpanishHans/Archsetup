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

mount_btrfs() {
    local -n given_array="$1"

    pause_script "TESTING" "entered mount_btrfs $EFI_PART $ROOT_PART"
    
    continue_script "Mounting $ROOT_PART on /mnt" "Mounting $ROOT_PART on /mnt in order to create subvolumes."
    mount "${ROOT_PART}" /mnt
    
    btrfs su cr /mnt/@
    btrfs su cr /mnt/@home
    btrfs su cr /mnt/@snapshots
    
    chattr +C /mnt/@home
    chattr +C /mnt/@snapshots
    
    mkdir -p /mnt/efi
    mkdir -p /mnt/.btrfsroot
    mkdir -p /mnt/home
    mkdir -p /mnt/.snapshots
    
    continue_script "Dismounting $ROOT_PART from /mnt" "Dismounting $ROOT_PART from /mnt in order to mount subvolumes created before."
    umount /mnt
    
    mount -o ssd,noatime,compress=zstd,subvol=@ "${ROOT_PART}" /mnt
    mount -o ssd,noatime,compress=zstd,subvolid=5 "${ROOT_PART}" /mnt/.btrfsroot
    mount -o ssd,noatime,compress=zstd,subvol=@home "${ROOT_PART}" /mnt/home
    mount -o ssd,noatime,compress=zstd,subvol=@snapshots "${ROOT_PART}" /mnt/.snapshots
    mount -o nodev,nosuid,noexec "${EFI_PART}" /mnt/efi
    
    local options=()
    for key in "${!given_array[@]}"; do
        IFS=" | " read -r disk flags path desc <<< "${given_array[$key]}"
        btrfs su cr /mnt/"$key"
        chattr +C /mnt/"$key"
        mkdir -p /mnt/"$path"
        mount -o "$flags,subvol=$key" "$disk" "$path"
        options+=("$key $desc")
    done
    pause_script "Created" "$(printf "%s\n" "${options[@]}")"

    pause_script "BTRFS Mounting" "Finished mouting BTRFS"
}



run_btrfs_setup() {

    pause_script "TESTING" "entered run_btrfs_setup EFI:$EFI_PART ROOT:$ROOT_PART"
    
    declare -A subvols
    local subvols=(
        ["@var_cache"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/cache | Cached data for apps and package managers, can be recreated if cleared."
        ["@var_spool"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/spool | Holds queues for tasks like mail, printing, or other pending jobs."
        ["@var_tmp"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/tmp | Temporary files for apps and services, persisting after reboots if needed."
        ["@var_log"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/log | System and application log files for tracking events and troubleshooting."
        ["@var_crash"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/crash | Crash reports and core dumps for analyzing system and application failures."
        ["@var_lib_libvirt_images"]="${ROOT_PART} | ssd,noatime,nodatacow,nodev,nosuid,noexec | /var/lib/libvirt/images | Disk images and metadata for virtual machines managed by libvirt."
        ["@var_lib_machines"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/lib/machines | Container images and metadata for systemd-nspawn containers."
        ["@var_lib_flatpak"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/lib/flatpak | Installed Flatpak apps and their sandboxed data and dependencies."
        ["@var_lib_docker"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/lib/docker | Container images, volumes, and metadata for Docker environments."
        ["@var_lib_distrobox"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/lib/distrobox | Data and images for running and managing Distrobox containers."
        ["@var_lib_gdm"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/lib/gdm | Configuration and session data for GNOME Display Manager (GDM)."
        ["@var_lib_AccountsService"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/lib/AccountsService | User account settings and data managed by AccountsService."
    )

    if [[ "$ROOT_FORM" == "btrfs" ]]; then
        
        multiselect_prompt \
            subvol_menu_choice \
            subvol_menu_choice_status \
            subvols \
            "Starting subvol picker" \
            "The following volumes are required for the system to work and will be create automatically.
            
        1. @
        2. @home
        3. @snapshots
            
        Please choose what extra subvolumes you require."
        
        declare -A filtered_subvols
        for choice in "${subvol_menu_choice[@]}"; do
            if [[ -n "${subvols[$choice]}" ]]; then
                filtered_subvols["$choice"]="${subvols[$choice]}"
            fi
        done
        mount_btrfs filtered_subvols
    fi

}