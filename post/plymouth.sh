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

plymouth_setup()
{
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S plymouth")
    commands_to_run+=('
        if grep -q "^HOOKS=" "/etc/mkinitcpio.conf"; then
            # Remove any existing "plymouth" from the HOOKS array if it exists
            sed -i "/^HOOKS=/ s/\(udev\)\(.*\)\bplymouth\b/\1\2/" "/etc/mkinitcpio.conf"
            sed -i "/^HOOKS=/ s/\(udev\)/\1 plymouth/" "/etc/mkinitcpio.conf"
            echo "Added 'plymouth' after 'udev' in the HOOKS array."
        else
            echo "No HOOKS line found in /etc/mkinitcpio.conf."
        fi
    ')

    while true; do
        clear
        output 'What theme to install?'
        output '0) Connect'
        output '1) Deus Ex'
        output '2) Lone'
        output '3) Red loader'
        output 'b) Nothing'
        read -p 'Insert the number of your selection: ' -r theme_choice
        case $theme_choice in
            0)
                commands_to_run+=("sudo -u sysadmin bash -i -c 'paru -S plymouth-theme-connect-git'")
                commands_to_run+=("plymouth-set-default-theme -R connect")
                break
                ;;
            1)
                commands_to_run+=("sudo -u sysadmin bash -i -c 'paru -S plymouth-theme-deus-ex-git'")
                commands_to_run+=("plymouth-set-default-theme -R deus_ex")
                break
                ;;
            2)
                commands_to_run+=("sudo -u sysadmin bash -i -c 'paru -S plymouth-theme-lone-git'")
                commands_to_run+=("plymouth-set-default-theme -R lone")
                break
                ;;
            3)
                commands_to_run+=("sudo -u sysadmin bash -i -c 'paru -S plymouth-theme-red-loader-git'")
                commands_to_run+=("plymouth-set-default-theme -R red_loader")
                break
                ;;
            b)  break
                ;;
            *)  output 'You did not enter a valid selection.'
                ;;
        esac
    done

    commands_to_run+=("grub-mkconfig -o /boot/grub/grub.cfg")

    live_command_output "${commands_to_run[@]}"

    output "Plymouth Setup complete!"
    pause_script
}


plymouth_setup