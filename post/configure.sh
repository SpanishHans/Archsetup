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

if [ "$LIVE_ENV" = true ]; then
    pause_script "ERROR" "The configure script must be run from a machine with ArchLinux already installed.

Exiting!!!
    "
    exit
    if [ "$(id -u)" -ne 0 ]; then
        pause_script "ERROR" "The configure script must be run as root user.

Exiting!!!"
        exit
    fi
fi

title="Configure your PC after install"
description="Welcome to the menu for setting things up after install. Here you can find a lot of utilities to make the process of setting your pc as easy as possible."

while true; do
    options=(\
        "Configure users and passwords" \
        "Configure Btrfs subvolumes and Snapper" \
        "Configure basic utils" \
        "Configure DEs" \
        "Configure Nvidia" \
        "Configure Plymouth" \
        "Configure Virt-Manager" \
        "Configure extra utils" \
        "Exit"
    )
    
    menu_prompt configure_choice configure_choice_status "$title" "$description" "${options[@]}"

    case $configure_choice in
        0)  ./post/users.sh;;
        1)  ./post/snapper_config.sh;;
        2)  ./post/utils.sh;;
        3)  ./post/desktops.sh;;
        4)  ./post/nvidia.sh;;
        5)  ./post/plymouth.sh;;
        6)  ./post/virt_manager.sh;;
        7)  ./post/tools.sh;;
        e)  exit;;
        *)  output "Invalid choice, please try again.";;
    esac
done
