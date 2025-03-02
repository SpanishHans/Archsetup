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
    local selected_choices=()
    
    declare -A fonts=(
        ["Terminus"]="terminus-font|A clean, monospaced font optimized for terminal use in text-only environments (init 3). Perfect for coding and system monitoring."
        ["Dejavu"]="ttf-dejavu-nerd|A versatile font family with wide character support, balancing clarity and elegance for interfaces and documents."
        ["0xProto"]="ttf-0xproto-nerd|A bold, futuristic font with sharp, geometric shapes, ideal for sci-fi and tech-inspired designs."
        ["FiraCode"]="ttf-firacode-nerd|A monospaced font with ligatures for coding, offering a clean and expressive environment for developers."
        ["FontAwesome"]="ttf-font-awesome|A scalable icon font with thousands of customizable icons, perfect for modern UI/UX design."
    )

    local options=()
    for key in "${!fonts[@]}"; do
        IFS="|" read -r pac_name desc <<< "${fonts[$key]}"
        options+=("$key" "$desc" "off")
    done

    selected_choices=($(multiselect_prompt "Choose Fonts" "Select multiple fonts" "${options[@]}"))

    local package_names=()
    for choice in "${selected_choices[@]}"; do
        IFS="|" read -r pac_name _ <<< "${fonts[$choice]}"
        package_names+=("$pac_name")
    done
    install_fonts "${package_names[@]}"
}

install_fonts() {
    local -a given_array=("$@")  # Correctly handle passed array elements
    local options=()
    local packages=()

    for entry in "${given_array[@]}"; do
        IFS='|' read -r pac_name desc <<< "$entry"
        pac_name=$(echo "$pac_name" | xargs)
        desc=$(echo "$desc" | xargs)
        packages+=("$pac_name")
        options+=("$pac_name")
    done

    if [[ ${#packages[@]} -gt 0 ]]; then
        install_pacman_packages "${packages[@]}"
    fi

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

    local options=()
    for key in "${!subvols[@]}"; do
        IFS=" | " read -r disk flags path desc <<< "${subvols[$key]}"
        options+=("$key" "$desc" "on")
    done
    
    if [[ "$ROOT_FORM" == "btrfs" ]]; then

        subvol_menu_choice=($(multiselect_prompt "Starting subvol picker" "The following volumes are required for the system to work and will be create automatically\n\n.1. @\n2. @home\n\n3. @snapshots\n\nPlease choose what extra subvolumes you require." "${options[@]}"))

        dialog --title "Debug Selected Choices" --msgbox "Selected: ${subvol_menu_choice[*]}" 10 50

        declare -A filtered_subvols
        for choice in "${subvol_menu_choice[@]}"; do
            if [[ -n "${subvols[$choice]}" ]]; then
                filtered_subvols["$choice"]="${subvols[$choice]}"
            fi
        done

        dialog --title "Debug Selected Choices" --msgbox "Selected: ${filtered_subvols[*]}" 10 50

        mount_btrfs filtered_subvols
    fi
}