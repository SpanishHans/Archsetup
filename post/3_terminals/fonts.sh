#!/bin/sh

# Copyright (C) 2021-2024 Thien Tran
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
source ./post/0_users/users.sh
source ./post/4_software/pacman.sh

################################################################################
# Fonts
################################################################################

fonts_menu() {

    declare -A fonts
    local fonts=(
        ["terminus"]="terminus-font | A clean, monospaced font optimized for terminal use in text-only environments (init 3). Perfect for coding and system monitoring."
        ["dejavu"]="ttf-dejavu-nerd | A versatile font family with wide character support, balancing clarity and elegance for interfaces and documents."
        ["proto"]="ttf-0xproto-nerd | A bold, futuristic font with sharp, geometric shapes, ideal for sci-fi and tech-inspired designs."
        ["fira"]="ttf-firacode-nerd | A monospaced font with ligatures for coding, offering a clean and expressive environment for developers."
        ["fa"]="ttf-font-awesome | A scalable icon font with thousands of customizable icons, perfect for modern UI/UX design."
    )

    local options=()
    for key in "${!fonts[@]}"; do
        IFS=" | " read -r pac_name desc <<< "${fonts[$key]}"
        local options+=("$key" "$desc" "off")
        pause_script "" "$options"
    done

    multiselect_prompt\
        font_menu_choice\
        options\
        "Starting font picker"\
        "The following are fonts considered nerd beucase they are for the tty or for the terminal.
    
Please choose what fonts you require."

    declare -A filtered_fonts
    for choice in "${font_menu_choice[@]}"; do
        if [[ -n "${fonts[$choice]}" ]]; then
            filtered_fonts["$choice"]="${fonts[$choice]}"
        fi
    done
    #install_fonts filtered_fonts
}

install_fonts() {
    local -n given_array="$1"
    local commands_to_run=()

    local options=()
    for key in "${!given_array[@]}"; do
        IFS=" | " read -r pac_name desc <<< "${given_array[$key]}"

        pac_name=$(echo "$pac_name" | xargs)
        desc=$(echo "$desc" | xargs)
        install_pacman_packages "$pac_name"
        local options+=("$pac_name")
    done

    live_command_output  "Configuring selected fonts" "${commands_to_run[@]}"
    continue_script 2 "Installed fonts" "Finished installing all selected fonts.

Installed:    
$(printf "%s\n" "${options[@]}")"
}

run_btrfs_setup() {
    declare -A subvols
    local subvols=(
        ["@var_cache"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/cache | Cached data for apps and package managers, can be recreated if cleared."
        ["@var_spool"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/spool | Holds queues for tasks like mail, printing, or other pending jobs."
        ["@var_tmp"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/tmp | Temporary files for apps and services, persisting after reboots if needed."
        ["@var_log"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/log | System and application log files for tracking events and troubleshooting."
        ["@var_crash"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/crash | Crash reports and core dumps for analyzing system and application failures."
        ["@var_lib_libvirt_images"]="${ROOT_PART} | ssd,noatime,nodatacow,nodev,nosuid,noexec | /var/lib/libvirt/images | Disk images and metadata for virtual machines managed by libvirt."
        ["@var_lib_machines"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/lib/machines | Container images and metadata for systemd-nspawn containers."
        ["@var_lib_containers"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/lib/containers | Container images and volumes for containers and or Podman."
        ["@var_lib_flatpak"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid | /var/lib/flatpak | Installed Flatpak apps and their sandboxed data and dependencies."
        ["@var_lib_docker"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/lib/docker | Container images, volumes, and metadata for Docker environments."
        ["@var_lib_distrobox"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/lib/distrobox | Data and images for running and managing Distrobox containers."
        ["@var_lib_gdm"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/lib/gdm | Configuration and session data for GNOME Display Manager (GDM)."
        ["@var_lib_accounts"]="${ROOT_PART} | ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec | /var/lib/AccountsService | User account settings and data managed by AccountsService."
    )

    local menu_options=()
    for key in "${!subvols[@]}"; do
        IFS=" | " read -r disk flags path desc <<< "${subvols[$key]}"
        menu_options+=("$key" "$desc" "on")
    done
    
    if [[ "$ROOT_FORM" == "btrfs" ]]; then
    
        multiselect_prompt\
            subvol_menu_choice\
            menu_options\
            "Starting subvol picker"\
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