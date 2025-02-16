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

if [ "$HAS_INTERNET" = false ]; then
    networks=$(iwctl station wlan0 scan && iwctl station wlan0 get-networks | column -t)

    pause_script "No internet" "You dont seem to have internet.
Please connect to a network with Ethernet or to a wifi network. For wifi use 'iwctl station ANTENNA (normally wlan0) connect NETWORK_SSID'

Available Networks:
$networks"
    exit 1
fi

cp -f .dialogrc /root/.dialogrc

launcher_menu () 
{
    local title="Script Installer Menu"
    local description="This script provides a menu to run various installation and configuration scripts for your system. Select an option to proceed.
    
Navigate though the menus with the arrow keys or with the paging keys. 
Select with enter. 
Press space for multiselect."

    while true; do
        local options=(\
            "Install Arch" \
            "Configure Arch after install" \
            "Exit"
        )
        menu_prompt main_menu_choice "$title" "$description" "${options[@]}"
        case $main_menu_choice in
            0)  ./pre/install.sh;exit;;
            1)  ./post/configure.sh;;
            e)  exit;;
            *)  continue_script 2 "Not a valid choice!" "Invalid choice, please try again.";;
        esac
    done
}

launcher_menu