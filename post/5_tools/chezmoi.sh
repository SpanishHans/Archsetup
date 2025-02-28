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
source ./post/4_software/asdf.sh

chezmoi_menu() {
    pick_user \
        chezmoi_username \
        "Chezmoi User to setup" \
        "Please enter the user whose chezmoi shall be configured: "

    configure_chezmoi "$chezmoi_username"
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
            0)  configure_chezmoi_default "$chezmoi_username";;
            1)  configure_chezmoi_no_default "$chezmoi_username";;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}

configure_chezmoi_default() {
    local chezmoi_username="$1"

    local commands_to_run=()

    if [[ -d "/home/$chezmoi_username/.local/share/chezmoi" ]]; then
        commands_to_run+=("rm -rf /home/$chezmoi_username/.local/share/chezmoi")
    fi

    commands_to_run+=("chezmoi init https://github.com/SpanishHans/dotfiles")
    commands_to_run+=("cp -rf /home/$chezmoi_username/.local/share/chezmoi/private_dot_config/* /home/$chezmoi_username/.config/")
    live_command_output  "Configuring chezmoi" "${commands_to_run[@]}"

    continue_script 2 "Chezmoi" "Chezmoi Setup complete for user $chezmoi_username!"
}

configure_chezmoi_no_default() {
    local chezmoi_username="$1"
    input_text \
        chezmoi_repo \
        "Chezmoi repo to setup" \
        "Please enter the repo to sync from/to." \
        "Provide the Git repository URL for ChezMoi: "

    local commands_to_run=()

    if [[ -d "/home/$chezmoi_username/.local/share/chezmoi" ]]; then
        commands_to_run+=("rm -rf /home/$chezmoi_username/.local/share/chezmoi")
    fi

    commands_to_run+=("chezmoi init \"$chezmoi_repo\"")
    commands_to_run+=("cp -rf /home/$chezmoi_username/.local/share/chezmoi/private_dot_config /home/$chezmoi_username/.config/")
    live_command_output  "Configuring chezmoi" "${commands_to_run[@]}"

    continue_script 2 "Chezmoi" "Chezmoi Setup complete for user $chezmoi_username!"
}
