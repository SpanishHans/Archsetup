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

nvidia_menu () {

    local title="Nvidia Driver Installation"
    local description="This script simplifies the installation of Nvidia drivers for your system."

    while true; do
        local options=(\
            'nvidia-open-dkms           (Driver with dynamic kernel support, therefore no pacman hook required.)' \
            "Back"
        )
        menu_prompt nvidia_menu_choice "$title" "$description" "${options[@]}"
        case $nvidia_menu_choice in
            0)  dkms_driver;;
            b)  break;;
            *)  continue_script 2 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}

dkms_driver() {
    install_pacman_packages base-devel linux-headers nvidia-open-dkms nvidia-utils nvidia-settings
    local commands_to_run=()
    commands_to_run+=('
    CONFIG_FILE="/etc/mkinitcpio.conf"
    NVIDIA_MODULES=("nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm")
    if grep -q "^MODULES=" "$CONFIG_FILE"; then
        current_modules=$(grep "^MODULES=" "$CONFIG_FILE" | sed -E "s/^MODULES=\\((.*)\\)/\\1/")
        for module in "${NVIDIA_MODULES[@]}"; do
            current_modules=$(echo "$current_modules" | sed -E "s/\\b$module\\b//g")
        done
        current_modules=$(echo "$current_modules" | xargs)
        for module in "${NVIDIA_MODULES[@]}"; do
            if ! grep -qw "$module" <<< "$current_modules"; then
                current_modules+=" $module"
            fi
        done
        sed -i "s|^MODULES=.*|MODULES=($current_modules)|" "$CONFIG_FILE"
        echo "Updated MODULES line: MODULES=($current_modules)"
    else
        echo "MODULES= line not found in $CONFIG_FILE"
    fi
    ')

    commands_to_run+=('
    CONFIG_FILE="/etc/mkinitcpio.conf"
    if grep -qE "^[[:space:]]*HOOKS=" "$CONFIG_FILE"; then
        sed -i "/^[[:space:]]*HOOKS=/ s/\<kms\>//g" "$CONFIG_FILE"
        echo "Removed '\''kms'\'' from the HOOKS array in $CONFIG_FILE."
    else
        echo "No active HOOKS line found in $CONFIG_FILE."
    fi
    ')

    commands_to_run+=('
        kernel_version=$(uname -r | cut -d "." -f 1,2)
        required_kernel="6.11"

        if [[ $(printf "%s\n%s" "$required_kernel" "$kernel_version" | sort -V | head -n1) == "$required_kernel" ]]; then
            nvidia_options="nvidia-drm.modeset=1 nvidia-drm.fbdev=1 vt.global_cursor_default=0"
        else
            nvidia_options="nvidia-drm.modeset=1 vt.global_cursor_default=0"
        fi

        grub_file="/etc/default/grub"

        if grep -q "^GRUB_CMDLINE_LINUX_DEFAULT=" "$grub_file"; then
            existing_line=$(grep "^GRUB_CMDLINE_LINUX_DEFAULT=" "$grub_file")
            for option in $nvidia_options; do
                if ! echo "$existing_line" | grep -q "$option"; then
                    sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\"$/ $option\"/" "$grub_file"
                fi
            done
        else
            echo "GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash $nvidia_options\"" >> "$grub_file"
        fi

        grub-mkconfig -o /boot/grub/grub.cfg
    ')

    live_command_output  "Installing DKMS driver" "${commands_to_run[@]}"
    continue_script 2 "Nvidia DKMS" "Nvidia DKMS Setup complete!"
}
