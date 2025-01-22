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


if [ "$USE_DIALOG" = false ]; then
    clear
    terminal_title "Command dialog not available."
    output
    output "The 'dialog' command is not installed."
    output
    read -p "Install dialog? (y/n): " install_dialog

    if [[ "$install_dialog" =~ ^[Yy]$ ]]; then
        sudo -S bash -c "pacman --noconfirm -Sy && pacman --noconfirm -S dialog"
        USE_DIALOG=true
    else
        USE_DIALOG=false
        echo "Dialog installation skipped. Quitting as it is required."
        exit 1 
    fi
fi

sudo mv ./.dialogrc $HOME/.dialogrc

title="Welcome to the Script Installer"
description="This script provides a menu to run various installation scripts.
Select an option from the menu to proceed."

while true; do
    options=(\
        "Install Arch" \
        "Configure Arch after install" \
        "Exit"
    )
    
    menu_prompt main_menu_choice main_menu_choice_status "$title" "$description" "${options[@]}"

    case $main_menu_choice in
        0)  pause_script "" "0"
            ./pre/install.sh;;
        1)  pause_script "" "1"
            ./post/configure.sh;;
        e)  exit;;
        *)  output "Invalid choice, please try again.";;
    esac
done
