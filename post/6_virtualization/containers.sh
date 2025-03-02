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
source ./post/4_software/pacman.sh
source ./post/6_virtualization/libvirt.sh

containers_menu() {
    local title='Type 2 hypervisors.'
    local description="This script helps you install different types of containers."

    while true; do
        local options=(\
            'Container technology         (Containers.)' \
            'Distrobox                    (Containers for running tiny VMs.)' \
            'LXC Containers               (Containers but closer to baremetal. Fixed resources, think VM.)' \
            "Back"
        )
        menu_prompt ht2_menu_choice "$title" "$description" "${options[@]}"
        case $ht2_menu_choice in
            0)  configure_classic_containers;;
            1)  configure_distrobox;;
            2)  configure_lxc;;
            b)  break;;
            *)  continue_script 2 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}

configure_classic_containers() {
    local title='Select a container technology.'
    local description="This script helps you install various container technologies. Choose the one that best fits your needs."

    while true; do
        local options=(\
            'Docker              (Classic containers, propietary and daemon based.)' \
            'Podman              (FLOSS containers, every container is its own process, generally rootless.)' \
            "Back"
        )
        menu_prompt ht1_menu_choice "$title" "$description" "${options[@]}"
        case $ht1_menu_choice in
            0)  configure_docker;;
            1)  configure_podman;;
            b)  break;;
            *)  continue_script 2 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}

configure_docker() {
    install_pacman_packages docker docker-compose
    pick_user \
        docker_user \
        "Docker user" \
        "Please enter the user who shall be added to docker group: "

    local commands_to_run=()
    commands_to_run+=("usermod -aG docker $docker_user")
    commands_to_run+=("systemctl enable docker")
    commands_to_run+=("systemctl start --now docker")

    live_command_output "" "Installing Docker" "${commands_to_run[@]}"
    continue_script 2 "Docker" "Docker Setup complete!"
}

configure_podman() {
    install_pacman_packages podman podman-compose
    continue_script 2 "Podman" "Podman Setup complete!"
}

configure_distrobox() {
    install_pacman_packages distrobox
    continue_script 2 "Distrobox" "Distrobox Setup complete!"
}

configure_lxc() {
    configure_libvirt
    continue_script 2 "Lxc" "Lxc Setup complete!"
}
