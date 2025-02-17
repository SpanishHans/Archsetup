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
source ./post/1_rollback/rollback.sh
source ./post/2_desktops/desktops.sh
source ./post/3_terminals/terminal.sh
source ./post/4_software/software.sh
source ./post/5_tools/tools.sh
source ./post/6_virtualization/virtualization.sh
source ./post/7_plymouth/plymouth.sh
source ./post/8_nvidia/nvidia.sh

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

configure_menu () {
    local user="sysadmin"

    input_pass "$user" pass "Password check for $user" "PKBUILD builds can not be done with root, therefore we shall use the user: 
    
- '$user'"

    check_pass \
        "$user" \
        "$pass"

    export USER_WITH_SUDO_USER="$user"
    export USER_WITH_SUDO_PASS="$pass"

    pause_script "" "$pass"

    local title="Configure your PC after install"
    local description="Welcome to the menu for setting things up after install. Here you can find a lot of utilities to make the process of setting your pc as easy as possible."

    while true; do
        local options=(\
            "Users and passwords             (Set new users and admins)" \
            "Rollback                        (Restore to previous system state)" \
            "Desktop Environments            (Desktop UI / Window managers)" \
            "Customize terminal              (Customize terminal framework and style)" \
            "Install software                (Install common software from Flatpak or AUR.)" \
            "Extra tools and utils           (Git, chezmoi, multi clipboard)" \
            "Virtualization                  (Docker, Virtualbox, virt-manager, LXC)" \
            "Programming languages           (Python, Javascript, Java, C, Rust)" \
            "Plymouth                        (Startup animation)" \
            "Nvidia                          (Nvidia Graphics cards)" \
            "Back"
        )
        menu_prompt configure_choice "$title" "$description" "${options[@]}"
        case $configure_choice in
            0)  users_menu;;
            1)  rollback_menu;;
            2)  desktops_menu;;
            3)  terminal_menu;;
            4)  software_menu;;
            5)  tools_menu;;
            6)  virtualization_menu;;
            7)  plymouth_menu;;
            8)  nvidia_menu;;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again.";;
        esac
    done
}

configure_menu
