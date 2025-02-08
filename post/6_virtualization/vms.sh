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

hypervisors_menu() {
    local title='Type 2 hypervisors.'
    local description="This script helps you install hypervisors for VMs. Pick between type 1 and type 2 (Type 1 is is fastest)."

    while true; do
        local options=(\
            'VM Hypervisors type 1        (FASTEST VMs: QEMU for x86, x86_64 and ARM.)'\
            'VM Hypervisors type 2        (SLOWEST VMs: Virtualbox, very common.)'\
            "Back"
        )
        menu_prompt ht2_menu_choice "$title" "$description" "${options[@]}"
        case $ht2_menu_choice in
            0)  hyper_type_1;;
            1)  hyper_type_2;;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}

hyper_type_1() {
    configure_libvirt

    get_users userlist
    input_text\
        qemu_user\
        "QEMU user"\
        "Please enter the user who shall be added to QEMU confs:\n\n$userlist"\
        "What user to add to QEMU confs?"

    local commands_to_run=()
    commands_to_run+=("sed -i \"s/^#user = .*/user = '$qemu_user'/\" /etc/libvirt/qemu.conf")
    commands_to_run+=("sed -i \"s/^#group = .*/group = '$qemu_user'/\" /etc/libvirt/qemu.conf")    

    title='What qemu packages to install?'
    description="This script aids the installation of type 1 hypervisors for the fastest possible VMs."

    while true; do
        options=(\
            'qemu-desktop             (Full-system emulation x86_64 only)'\
            'qemu-emulators-full      (Full-system and Usermode emulation both for x86 and ARM)'\
            'qemu-full                (Everything under the sun)'\
            "Back"
        )
        menu_prompt tools_menu_choice "$title" "$description" "${options[@]}"
        case $tools_menu_choice in
            0)  install_pacman_packages qemu-desktop
                break;;
            1)  install_pacman_packages qemu-emulators-full
                break;;
            2)  install_pacman_packages qemu-full
                break;;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done

    live_command_output "" "" "yes" "Installing selected QEMU hypervisor" "${commands_to_run[@]}"
    continue_script 2 "Qemu" "Qemu Setup complete!"
}

hyper_type_2() {
    input_pass\
        sysadmin_password\
        "sysadmin"
    local title='Type 2 hypervisors.'
    local description="This script helps you install type 2 hypervisors like Virtualbox and its extensions. Slower."

    while true; do
        local options=(\
            'Install Virtualbox          (Open source Virtualbox.)'\
            'Install extensions          (Extension is not open source, therefore separated.)'\
            "Back"
        )
        menu_prompt ht2_menu_choice "$title" "$description" "${options[@]}"
        case $ht2_menu_choice in
            0)  configure_virtualbox;;
            1)  configure_vbox_ext "sysadmin" "$sysadmin_password";;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}

configure_virtualbox() {
    install_pacman_packages virtualbox virtualbox-host-modules-arch
    continue_script 2 "Virtualbox" "Virtualbox Setup complete!"
}

configure_vbox_ext() {
    local user="$1"
    configure_virtualbox
    install_aur_package "$user" "$pass" "https://aur.archlinux.org/virtualbox-ext-oracle.git"
    continue_script 2 "Virtualbox Extensions" "Virtualbox extensions setup complete!"
}