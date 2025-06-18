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
source ./post/4_software/pacman_installer.sh
source ./post/4_software/mise.sh
source ./post/5_tools/chezmoi.sh
source ./post/5_tools/git.sh


configure_clipboard() {
    install_pacman_packages wl-clipboard cliphist grim slurp
    continue_script 2 "Clipboard" "Clipboard Setup complete!"
}

configure_waybar() {
    install_pacman_packages waybar
    continue_script 2 "Waybar" "Waybar Setup complete!"
}

configure_eww() {
    pick_user \
        eww_username \
        "Chezmoi User to setup" \
        "Please enter the user whose eww shall be configured: "
    commands_to_run=()
    install_pacman_packages mise
    
    commands_to_run+=("mise use -g rust")
    commands_to_run+=(". \"/home/$eww_username/eww/.cargo/env\"")
    if [[ -d "/home/$eww_username/eww" ]]; then
        commands_to_run+=("rm -rf /home/$eww_username/eww")
    fi
    commands_to_run+=("git clone https://github.com/elkowar/eww /home/$eww_username/eww && cd /home/$eww_username/eww && cargo build --release --no-default-features --features=wayland")
    live_command_output "sysuser" "$eww_username" "Installing eww" "${commands_to_run[@]}"
    
    continue_script 2 "Eww" "Eww Setup complete!"
}

configure_rofi() {
    rofi-wayland
    rofi-calc
    continue_script 2 "Rofi" "Rofi Setup complete!"
}

configure_swww() {
    install_pacman_packages swww
    continue_script 2 "Swww" "Swww Setup complete!"
}

tools_menu () {
    local title="Basic Tools Installer"
    local description="This script provides an easy way to install essential tools for your system. Select an option to install the tool of your choice."


    while true; do
        local options=(\
            "Git                (Version control)" \
            "Chezmoi            (dotfile manager)" \
            "Clipboard          (History)" \
            "Eww                (Widget system)" \
            "Rofi               (App launcher)" \
            "Swww               (Wallpaper manager)" \
            "Back" \
        )
        menu_prompt tools_menu_choice "$title" "$description" "${options[@]}"
        case $tools_menu_choice in
            0)  git_menu;;
            1)  chezmoi_menu;;
            2)  configure_clipboard;;
            3)  configure_eww;;
            4)  configure_rofi;;
            5)  configure_swww;;
            b)  break;;
            *)  continue_script 2 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}