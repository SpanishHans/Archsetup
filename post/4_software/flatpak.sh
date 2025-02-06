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
source ./post/pacman.sh

flatpak_menu() {
    install_pacman_packages flatpak

    local title="Install extra software from Flatpak."
    local description="Welcome to the flatpak software installation menu. Select the software to install."
    local user=USER_WITH_SUDO_USER
    local pass=USER_WITH_SUDO_PASS

    while true; do
        local options=(\
            "Zen Browser                   (A firefox based, pretty and FAST browser.)"\
            "Zed Code Editor               (A fast code editor.)"\
            "Visual Studio Code            (classic code editor)"\
            "Spotify                       (Spotify client)"\
            "Discord                       (Discord client)"\
            "All apps                      (Install all the above)"\
            "Back"
        )
        menu_prompt flt_choice "$title" "$description" "${options[@]}"
        case $flt_choice in
            0)  install_flatpak_zen "$user" "$pass";;
            1)  install_flatpak_zed "$user" "$pass";;
            2)  install_flatpak_vscode "$user" "$pass";;
            3)  install_flatpak_spotify "$user" "$pass";;
            4)  install_flatpak_discord "$user" "$pass";;
            5)  install_all_flatpaks "$user" "$pass";;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again.";;
        esac
    done
}

check_flatpak_installed() {
    local app_id="$1"

    if flatpak list --app | grep -q "$app_id"; then
        return 0
    else
        return 1
    fi
}

install_flatpak_zen() {
    local user="$1"
    local pass="$2"
    local app_id="app.zen_browser.zen"
    if check_flatpak_installed "$app_id"; then
        continue_script 2 "Zen Browser already installed" "Zen Browser is already installed."
    else
        commands_to_run=()
        commands_to_run+=("flatpak install --assumeyes --noninteractive $app_id")
        live_command_output "$user" "$pass" "Installing Zen Browser" "${commands_to_run[@]}"
    fi
}

install_flatpak_zed () {
    local user="$1"
    local pass="$2"
    local app_id="dev.zed.Zed"
    if check_flatpak_installed "$app_id"; then
        continue_script 2 "Zed editor already installed" "Zed editor is already installed."
    else
        commands_to_run=()
        commands_to_run+=("flatpak install --assumeyes --noninteractive $app_id")
        live_command_output "$user" "$pass" "Installing Zed editor" "${commands_to_run[@]}"
    fi
}

install_flatpak_vscode () {
    local user="$1"
    local pass="$2"
    local app_id="com.visualstudio.code"
    if check_flatpak_installed "$app_id"; then
        continue_script 2 "Visual Studio Code already installed" "Visual Studio Code is already installed."
    else
        commands_to_run=()
        commands_to_run+=("flatpak install --assumeyes --noninteractive $app_id")
        live_command_output "$user" "$pass" "Installing Visual Studio Code" "${commands_to_run[@]}"
    fi
}

install_flatpak_spotify () {
    local user="$1"
    local pass="$2"
    local app_id="com.spotify.Client"
    if check_flatpak_installed "$app_id"; then
        continue_script 2 "Spotify already installed" "Spotify is already installed."
    else
        commands_to_run=()
        commands_to_run+=("flatpak install --assumeyes --noninteractive $app_id")
        live_command_output "$user" "$pass" "Installing Spotify" "${commands_to_run[@]}"
    fi
}

install_flatpak_discord () {
    local user="$1"
    local pass="$2"
    local app_id="com.discordapp.Discord"
    if check_flatpak_installed "$app_id"; then
        continue_script 2 "Discord already installed" "Discord is already installed."
    else
        commands_to_run=()
        commands_to_run+=("flatpak install --assumeyes --noninteractive $app_id")
        live_command_output "$user" "$pass" "Installing Discord" "${commands_to_run[@]}"
    fi
}

install_all_flatpaks () {
    local user="$1"
    local pass="$2"
    install_flatpak_zen "$user" "$pass"
    install_flatpak_zed "$user" "$pass"
    install_flatpak_vscode "$user" "$pass"
    install_flatpak_spotify "$user" "$pass"
    install_flatpak_discord "$user" "$pass"
}