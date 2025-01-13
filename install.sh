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

source ./globals.sh

if [ "$USE_DIALOG" = false ]; then
    clear
    terminal_title "Command dialog not available."
    output
    output "The 'dialog' command is not installed."
    output "Would you like to install it to improve the user experience?"
    output
    read -p "Install dialog? (y/n): " install_dialog

    if [[ "$install_dialog" =~ ^[Yy]$ ]]; then
        sudo -S bash -c "pacman --noconfirm -Sy && pacman --noconfirm -S dialog"
        USE_DIALOG=true
    else
        USE_DIALOG=false
    fi
    export USE_DIALOG
fi

sudo mv $HOME/ArchSetup/.dialogrc $HOME/.dialogrc

if [ "$LIVE_ENV" = false ]; then
    # Check if the active user is root
    if [ "$(id -u)" -ne 0 ]; then
        pause_script "" "You must be logged in as root to use these scripts."
        exit 1
    fi
    
    export ROOT_PASS=""
    export ROOT_PASS_SET=false
    root_pass
fi

title="Welcome to the Script Installer"
description="This script provides a menu to run various installation scripts.
Select an option from the menu to proceed."

while true; do
    options=(\
        "Install Arch" \
        "Configure Btrfs subvolumes and Snapper" \
        "Configure basic utils" \
        "Configure DEs" \
        "Configure Nvidia" \
        "Configure Plymouth" \
        "Configure Virt-Manager" \
        "Configure extra utils" \
    )
    
    menu_prompt main_menu_choice main_menu_choice_status "$title" "$description" "${options[@]}"

    case $main_menu_choice in
        1)  ./1_install.sh;;
        2)  ./2_btrfs_setup.sh;;
        3)  ./3_basic_tools.sh;;
        4)  ./4_desktops.sh;;
        5)  ./5_nvidia.sh;;
        6)  ./6_plymouth.sh;;
        7)  ./7_virt_manager.sh;;
        8)  ./8_utils.sh;;
        0)  exit;;
        *)  output "Invalid choice, please try again.";;
    esac
done
