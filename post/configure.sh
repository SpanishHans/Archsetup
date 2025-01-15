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
    if [ "$(id -u)" -ne 0 ]; then
        pause_script "" "You must be logged in as root on a machine with arch installed to use these scripts."
        exit 1
    fi
else    
    export ROOT_PASS=""
    export ROOT_PASS_SET=false
    root_pass
fi

title="Welcome to the Script Installer"
description="This script provides a menu to run various installation scripts.
Select an option from the menu to proceed."

while true; do
    options=(\
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
        2)  ./post/snapper_config.sh;;
        3)  ./post/utils.sh;;
        4)  ./post/desktops.sh;;
        5)  ./post/nvidia.sh;;
        6)  ./post/plymouth.sh;;
        7)  ./post/virt_manager.sh;;
        8)  ./post/tools.sh;;
        0)  exit;;
        *)  output "Invalid choice, please try again.";;
    esac
done
