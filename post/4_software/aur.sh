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
source ./post/0_users/users.sh
source ./post/4_software/pacman.sh

aur_menu() {

    local title="Install extra software from the AUR"
    local description="Welcome to the AUR software installation menu. Select the software to install."
    local user=USER_WITH_SUDO_USER
    local pass=USER_WITH_SUDO_PASS

    while true; do
        local options=(\
            "Install Paru"\
            "Install Rofi power menu"\
            "Back"
        )
        menu_prompt aur_choice "$title" "$description" "${options[@]}"
        case $aur_choice in
            0)  configure_paru "$user" "$pass";;
            1)  configure_aur_rofi_power_menu "$user" "$pass";;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again.";;
        esac
    done
}

install_aur_package () {
    local user="$1"
    local pass="$2"
    local url="$3"
    install_without_paru \"$user\" \"$pass\" \"$url\"
}

install_with_paru () {
    local bui_user="$1"
    local bui_pass="$2"
    local url="$3"
    local package_name=$(basename "$url" .git)

    commands_to_run=()
    commands_to_run+=("paru -S --noconfirm --needed .")
    live_command_output "$bui_user" "$bui_pass" "Building and installing $package_name" "${commands_to_run[@]}"
    continue_script 2 "$package_name installed" "$package_name install complete!"
}

install_without_paru() {
    local bui_user="$1"
    local bui_pass="$2"
    local url="$3"
    local package_name=$(basename "$url" .git)
    local build_path="/home/$bui_user/builds/$package_name"

    if ! check_folder_exists "$build_path"; then
        commands_to_run=()
        commands_to_run+=("mkdir -p $build_path")
        commands_to_run+=("git clone $url $build_path")
        commands_to_run+=("chown -R $bui_user:$bui_user $build_path")
        live_command_output "" "" "Cloning $package_name" "${commands_to_run[@]}"
    else
        continue_script 2 "repo exists for $package_name" "$package_name repository already exists at $build_path. Skipping clone."
    fi

    if ! ls $build_path/*.pkg.tar.zst &>/dev/null; then
        commands_to_run=()
        scroll_window_output "$build_path/PKGBUILD"
        commands_to_run+=("cd $build_path && makepkg -s -r -c --noconfirm")
        live_command_output "$bui_user" "$bui_pass" "Building and installing $package_name" "${commands_to_run[@]}"
    else
        echo "$package_name package already built. Skipping build."
    fi

    commands_to_run=()
    commands_to_run+=("cd $build_path && pacman --noconfirm -U *.pkg.tar.zst")
    live_command_output "" "" "Installing $package_name" "${commands_to_run[@]}"

    continue_script 2 "$package_name installed" "$package_name install complete!"
}



configure_paru() {
    local user="$1"
    local pass="$2"

    if ! check_command_exists "paru"; then
        install_aur_package "$user" "$pass" "https://aur.archlinux.org/paru.git"
    else
        continue_script 2 "Paru installed" "Paru is already installed."
    fi
}

configure_aur_rofi_power_menu() {
    local user="$1"
    local pass="$2"
    
    if ! check_command_exists "rofi-power-menu"; then
        install_aur_package "$user" "$pass" "https://aur.archlinux.org/rofi-power-menu.git"
    else
        continue_script 2 "Rofi power menu installed" "rofi-power-menu is already installed."
    fi
}
