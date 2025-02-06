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
source ./post/chezmoi.sh
source ./post/users.sh


configure_clipboard() {
    install_pacman_packages wl-clipboard cliphist grim slurp
    continue_script 2 "Clipboard" "Clipboard Setup complete!"
}

tools_menu () {
    local title="Basic Tools Installer"
    local description="This script provides an easy way to install essential tools for your system. Select an option to install the tool of your choice."


    while true; do
        local options=(\
            "Git                (Version control)" \
            "Chezmoi            (dotfile manager)" \
            "Clipboard          (History)" \
            "Back" \
        )
        menu_prompt tools_menu_choice "$title" "$description" "${options[@]}"
        case $tools_menu_choice in
            0)  configure_git;;
            3)  chezmoi_mode;;
            4)  configure_clipboard;;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}