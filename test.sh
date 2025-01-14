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

disk_prompt() {
    local devices=($(lsblk -dpnoNAME | grep -P "/dev/nvme|sd|mmcblk|vd"))
    local title="Starting disk picker"
    local description="This script only allows for FULLDISK install, cancel now with option 0 or ctrl+c if this is not what you want.
Select a disk from the disk below with its number."
    
    menu_prompt disk_menu disk_menu_status "$title" "$description" "${devices[@]}"

    case $disk_menu in
        0)  exit;;
        *)  disk="${devices[$((disk_menu - 1))]}";;
    esac
}

pause_script "Subvolume creation" "You are in btrfs installation mode.
The following volumes are required for the system to work and will be create automatically.

    1. @
    2. @home
    3. @snapshots
    
You can create other volumes in the next step."

title="Multiselect test"
description="Select subvols"
options=(\
    "Opt 1" \
    "Opt 2" \
    "Opt 3" \
)

while true; do
    
    subvol_prompt subvol_menu_choice main_menu_choice_status "$title" "$description" "${options[@]}"
    case $subvol_menu_choice in
        1)  pause_script "Subvolume creation" "1";;
        2)  pause_script "Subvolume creation" "2";;
        3)  pause_script "Subvolume creation" "3";;
        0)  exit;;
        *)  output "Invalid choice, please try again.";;
    esac
done
    
pause_script "Subvolume creation" "after"