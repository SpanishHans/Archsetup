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
source ./post/4_software/aur.sh

plymouth_menu () {
    install_pacman_packages plymouth
    local title='Plymouth Theme Installation'
    local description="This script helps you install and set up Plymouth themes for a stylish startup animation."

    while true; do
        local options=(\
            'Connect          (Circle matrix connected by lines. Looks like android pattern unlock.)' \
            'Deus Ex          (Triangle that grows. Looks like abstergoish.)' \
            'Lone             (Spinning spehere kind of dots.)' \
            'Red loader       (Red spinning jing jand kind of thing)' \
            'Regen CPIO       (Regenerate CPIO and GRUB)' \
            "Back"
        )
        menu_prompt plymouth_menu_choice "$title" "$description" "${options[@]}"
        case $plymouth_menu_choice in
            0)  theme_connect;;
            1)  theme_deus_ex;;
            2)  theme_lone;;
            3)  theme_red_loader;;
            4)  regen_cpio;;
            b)  break;;
            *)  continue_script 2 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
    cp -f plymouth-wait-for-animation.service /etc/systemd/system
    systemctl enable plymouth-wait-for-animation.service
}

regen_cpio() {
    local commands_to_run=()
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
    live_command_output "" "" "Regenerating cpio" "${commands_to_run[@]}"
}

theme_connect() {
    install_aur_package "https://aur.archlinux.org/plymouth-themes-adi1090x-pack1-git.git"
    commands_to_run=("plymouth-set-default-theme -R connect")

    live_command_output "" "" "Installing selected plymouth theme: connect" "${commands_to_run[@]}"
    continue_script 2 "Plymouth theme connect installed" "The Plymouth theme connect has been installed!"
}

theme_deus_ex() {
    install_aur_package "https://aur.archlinux.org/plymouth-themes-adi1090x-pack2-git.git"
    commands_to_run+=("plymouth-set-default-theme -R deus_ex")

    live_command_output "" "" "Installing selected plymouth theme: deus ex" "${commands_to_run[@]}"
    continue_script 2 "Plymouth theme deus ex installed" "The Plymouth theme deus ex has been installed!"
}

theme_lone() {
    install_aur_package  "https://aur.archlinux.org/plymouth-themes-adi1090x-pack3-git.git"
    commands_to_run+=("plymouth-set-default-theme -R lone")

    live_command_output "" "" "Installing selected plymouth theme: lone" "${commands_to_run[@]}"
    continue_script 2 "Plymouth theme lone installed" "The Plymouth theme lone has been installed!"
}

theme_red_loader() {
    install_aur_package "https://aur.archlinux.org/plymouth-themes-adi1090x-pack4-git.git"
    commands_to_run+=("plymouth-set-default-theme -R red_loader")

    live_command_output "" "" "Installing selected plymouth theme: red loader" "${commands_to_run[@]}"
    continue_script 2 "Plymouth theme red loader installed" "The Plymouth theme red loader has been installed!"
}
