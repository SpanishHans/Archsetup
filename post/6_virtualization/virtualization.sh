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
source ./post/6_virtualization/containers.sh
source ./post/6_virtualization/vms.sh

virtualization_menu () {
    local title='Virtualization Technology Installer'
    local description="This script helps you install various virtualization technologies for your system. Choose the one that best fits your needs."

    while true; do
        local options=(\
            'Containers         (Containers like Docker, Distrobox or LXC)' \
            'VM Hypervisors     (QEMU and Virtualbox)' \
            "Back"
        )
        menu_prompt virt_menu_choice "$title" "$description" "${options[@]}"
        case $virt_menu_choice in
            0)  containers_menu;;
            1)  hypervisors_menu;;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}
