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

configure_plymouth() {
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S plymouth")
    live_command_output "" "" "Installing Plymouth" "${commands_to_run[@]}"
    pause_script "Plymouth installed" "Plymouth has been installed!"
}

theme_connect() {
    local user="$1"
    if ! command -v plymouth &>/dev/null; then
        continue_script "No Plymouth" "Plymouth is not installed. Proceeding with configuration."
        configure_plymouth
    else
        continue_script "Plymouth exists" "Plymouth is already installed."
    fi
    install_aur_package "$user" "https://aur.archlinux.org/plymouth-themes-adi1090x-pack1-git.git"
    
    commands_to_run=()
    commands_to_run+=("plymouth-set-default-theme -R connect")
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

    commands_to_run+=("grub-mkconfig -o /boot/grub/grub.cfg")

    live_command_output "" "" "Installing selected plymouth theme: $choice""${commands_to_run[@]}"
    pause_script "Plymouth theme $choice installed" "The Plymouth theme $choice has been installed!"
}

theme_deus_ex() {
    local user="$1"
    if ! command -v plymouth &>/dev/null; then
        continue_script "No Plymouth" "Plymouth is not installed. Proceeding with configuration."
        configure_plymouth
    else
        continue_script "Plymouth exists" "Plymouth is already installed."
    fi
    install_aur_package "$user" "https://aur.archlinux.org/plymouth-themes-adi1090x-pack2-git.git"

    commands_to_run=()
    commands_to_run+=("plymouth-set-default-theme -R deus_ex")
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

    commands_to_run+=("grub-mkconfig -o /boot/grub/grub.cfg")

    live_command_output "" "" "Installing selected plymouth theme: $choice""${commands_to_run[@]}"
    pause_script "Plymouth theme $choice installed" "The Plymouth theme $choice has been installed!"
}

theme_lone() {
    local user="$1"
    if ! command -v plymouth &>/dev/null; then
        continue_script "No Plymouth" "Plymouth is not installed. Proceeding with configuration."
        configure_plymouth
    else
        continue_script "Plymouth exists" "Plymouth is already installed."
    fi
    install_aur_package "$user" "https://aur.archlinux.org/plymouth-themes-adi1090x-pack3-git.git"
    
    commands_to_run=()
    commands_to_run+=("plymouth-set-default-theme -R lone")
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

    commands_to_run+=("grub-mkconfig -o /boot/grub/grub.cfg")

    live_command_output "" "" "Installing selected plymouth theme: $choice""${commands_to_run[@]}"
    pause_script "Plymouth theme $choice installed" "The Plymouth theme $choice has been installed!"
}

theme_red_loader() {
    local user="$1"
    if ! command -v plymouth &>/dev/null; then
        continue_script "No Plymouth" "Plymouth is not installed. Proceeding with configuration."
        configure_plymouth
    else
        continue_script "Plymouth exists" "Plymouth is already installed."
    fi
    install_aur_package "$user" "https://aur.archlinux.org/plymouth-themes-adi1090x-pack4-git.git"

    commands_to_run=()
    commands_to_run+=("plymouth-set-default-theme -R red_loader")
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

    commands_to_run+=("grub-mkconfig -o /boot/grub/grub.cfg")

    live_command_output "" "" "Installing selected plymouth theme: $choice""${commands_to_run[@]}"
    pause_script "Plymouth theme $choice installed" "The Plymouth theme $choice has been installed!"
}

plymouth_menu () {
    local title='Plymouth Theme Installation'
    local description="This script helps you install and set up Plymouth themes for a stylish startup animation."

    while true; do
        local options=(\
            'Connect          (Circle matrix connected by lines. Looks like android pattern unlock.)'\
            'Deus Ex          (Triangle that grows. Looks like abstergoish.)'\
            'Lone             (Spinning spehere kind of dots.)'\
            'Red loader       (Red spinning jing jand kind of thing)'\
            "Back"
        )
        menu_prompt plymouth_menu_choice "$title" "$description" "${options[@]}"
        case $plymouth_menu_choice in
            0)  theme_connect "sysadmin";;
            1)  theme_deus_ex "sysadmin";;
            2)  theme_lone "sysadmin";;
            3)  theme_red_loader "sysadmin";;
            b)  break;;
            *)  continue_script "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}