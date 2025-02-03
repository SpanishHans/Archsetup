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
source ./post/aur.sh

install_chezmoi() {
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S chezmoi")

    live_command_output "" "" "Installing Chezmoi" "${commands_to_run[@]}"
    continue_script "Chezmoi" "Chezmoi Setup complete!"
}

configure_chezmoi_default() {
    input_text chezmoi_username "Chezmoi User to setup" "Please enter the user whose chezmoi shall be configured" 'What user to configure chezmoi for?: '

    if ! check_command_exists "chezmoi"; then
        install_chezmoi
    else
        continue_script "Chezmoi already installed" "Chezmoi is already installed."
    fi

    # commands_to_run+=("sudo -u \"$chezmoi_username\" bash -c \"chezmoi init https://github.com/SpanishHans/Archsetup\"")
    live_command_output "" "" "Configuring chezmoi" "${commands_to_run[@]}"

    commands_to_run=()
    commands_to_run+=("chezmoi init https://github.com/SpanishHans/Archsetup")
    commands_to_run+=("mv /home/$chezmoi_username/.local/share/chezmoi/* /home/$chezmoi_username/.config/")
    live_command_output "$chezmoi_username" "" "Configuring chezmoi" "${commands_to_run[@]}"

    pause_script "Chezmoi" "Chezmoi Setup complete for user $chezmoi_username!"
}

configure_chezmoi_no_default() {
    input_text chezmoi_username "Chezmoi User to setup" "Please enter the user whose chezmoi shall be configured" 'What user to configure chezmoi for?: '
    input_text chezmoi_repo "Chezmoi repo to setup" "Please enter the repo to sync from/to." "Provide the Git repository URL for ChezMoi: "

    if ! check_command_exists "chezmoi"; then
        install_chezmoi
    else
        continue_script "Chezmoi is already installed."
    fi

    # commands_to_run+=("sudo -u \"$chezmoi_username\" bash -c \"chezmoi init https://github.com/SpanishHans/Archsetup\"")
    live_command_output "" "" "Configuring chezmoi" "${commands_to_run[@]}"

    commands_to_run=()
    commands_to_run+=("chezmoi init https://github.com/SpanishHans/Archsetup")
    commands_to_run+=("mv /home/$chezmoi_username/.local/share/chezmoi/* /home/$chezmoi_username/.config/")
    live_command_output "$chezmoi_username" "" "Configuring chezmoi" "${commands_to_run[@]}"

    pause_script "Chezmoi" "Chezmoi Setup complete for user $chezmoi_username!"
}

chezmoi_mode () {
    local title="Chezmoi Installer"
    local description="This script provides an easy way to install Chezmoi for your system. Select a mode to install Chezmoi with."


    while true; do
        local options=(\
            "Chezmoi with default configs              (SpanishHans dotfiles repo)" \
            "Chezmoi without default configs           (User must provide dotfiles repo)" \
            "Back" \
        )
        menu_prompt tools_menu_choice "$title" "$description" "${options[@]}"
        case $tools_menu_choice in
            0)  configure_chezmoi_default;;
            1)  configure_chezmoi_no_default;;
            b)  break;;
            *)  continue_script "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}