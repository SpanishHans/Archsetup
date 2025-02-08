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
            'nvidia-open-dkms           (Driver with dynamic kernel support, therefore no pacman hook required.)'\
            "Back"
        )
        menu_prompt nvidia_menu_choice "$title" "$description" "${options[@]}"
        case $nvidia_menu_choice in
            0)  scroll_window_output "System Logs" "/root/Archsetup/.dialogrc";;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done    
}

# dkms_driver () {
#     install_pacman_packages base-devel linux-headers nvidia-open-dkms nvidia-utils nvidia-settings
#     local commands_to_run=()

#     commands_to_run+=('
#         mkinitcpio_conf="/etc/mkinitcpio.conf"
#         nvidia_modules="nvidia nvidia_modeset nvidia_uvm nvidia_drm"

#         if grep -q "^MODULES=" "$mkinitcpio_conf"; then
#             # Remove any existing NVIDIA modules to avoid duplicates
#             sed -i "/^MODULES=/ s/ nvidia[[:alnum:]_]*//g" "$mkinitcpio_conf"

#             # Add the appropriate NVIDIA modules to the MODULES line
#             sed -i "/^MODULES=/ s/\)/ $nvidia_modules)/" "$mkinitcpio_conf"
#             echo "Added NVIDIA modules: $nvidia_modules"
#         else
#             # If MODULES line doesn't exist, create one with the NVIDIA modules
#             echo "MODULES=($nvidia_modules)" >> "$mkinitcpio_conf"
#             echo "Created MODULES line with NVIDIA modules: $nvidia_modules"
#         fi
#     ')

#     commands_to_run+=('
#         if grep -q "^HOOKS=" /etc/mkinitcpio.conf; then
#             sed -i "/^HOOKS=/ s/\<kms\>//g" /etc/mkinitcpio.conf
#             echo "Removed 'kms' from the HOOKS array in /etc/mkinitcpio.conf."
#         else
#             echo "No HOOKS line found in /etc/mkinitcpio.conf."
#         fi
#     ')

#     commands_to_run+=('mkinitcpio -P')

#     commands_to_run+=('
#         kernel_version=$(uname -r | cut -d "." -f 1,2)
#         required_kernel="6.11"

#         if [[ $(echo "$kernel_version >= $required_kernel" | bc -l) -eq 1 ]]; then
#             nvidia_options="nvidia-drm.modeset=1 nvidia-drm.fbdev=1 vt.global_cursor_default=0"
#         else
#             nvidia_options="nvidia-drm.modeset=1 vt.global_cursor_default=0"
#         fi

#         grub_file="/etc/default/grub"
#         existing_line=$(grep "^GRUB_CMDLINE_LINUX_DEFAULT=" "$grub_file")

#         for option in $nvidia_options; do
#             if ! echo "$existing_line" | grep -q "$option"; then
#                 sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\"$/ $option\"/" "$grub_file"
#             fi
#         done

#         grub-mkconfig -o /boot/grub/grub.cfg
#     ')

#     live_command_output "" "" "yes" "Installing DKMS driver" "${commands_to_run[@]}"
#     continue_script 2 "Nvidia DKMS" "Nvidia DKMS Setup complete!"
# }
