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

initial_setup()
{
    commands_to_run=()
    commands_to_run+=("
        if LC_ALL=C.UTF-8 lscpu | grep -q 'Virtualization'; then
            echo 'Virtualization is supported on your system.';
        else
            echo 'Virtualization is not supported on your system.';
            exit 1;
        fi
    ")
    commands_to_run+=("
        if zgrep -q CONFIG_KVM= /proc/config.gz; then
            echo 'KVM support is enabled on your system.';
        else
            echo 'KVM support is not enabled on your system.';
            exit 1;
        fi
    ")

    commands_to_run+=("terminal_title 'Done with segment execuption'")
    live_command_output "" "${commands_to_run[@]}"

    output "Initial Setup complete!"
    pause_script
}

libvirt_setup()
{
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S libvirt dnsmasq virt-manager && usermod -aG libvirt $USER")

    live_command_output "${commands_to_run[@]}"

    title='What hypervisor do you want to install?'
    description="This script aids the installation of hypervisors."

    while true; do
        options=(\
            'QEMU'\
            'LXC'\
            'VirtualBox'\
            "Back"
        )

        menu_prompt tools_menu_choice tools_menu_choice_status "$title" "$description" "${options[@]}"

        case $tools_menu_choice in
            0)  qemu_setup
                break;;
            1)  lxc_setup
                break;;
            2)  virtualbox_setup
                break;;
            b) exit;;
            *) output "Invalid choice, please try again." ;;
        esac
    done

    output "Libvirt and whatever hypervisor you installed have been setup correctly!"
    pause_script
}

qemu_setup()
{

    commands_to_run=()

    title='What qemu packages to install?'
    description="This script aids the installation of QEMU versions."

    while true; do
        options=(\
            'qemu-desktop (Full-system x86_64 only)'\
            'qemu-emulators-full (Full-system and Usermode emulation both for x86 and ARM)'\
            'qemu-full (Everything under the sun)'\
            "Back"
        )

        menu_prompt tools_menu_choice tools_menu_choice_status "$title" "$description" "${options[@]}"

        case $tools_menu_choice in
            0)  commands_to_run+=("pacman --noconfirm -S qemu-desktop")
                break;;
            1)  commands_to_run+=("pacman --noconfirm -S qemu-emulators-full")
                break;;
            2)  commands_to_run+=("pacman --noconfirm -S qemu-full")
                break;;
            b) exit;;
            *) output "Invalid choice, please try again." ;;
        esac
    done

    commands_to_run+=("terminal_title 'Done with segment execuption'")
    live_command_output "" "${commands_to_run[@]}"

    output "Qemu Setup complete!"
    pause_script
}

lxc_setup()
{
    output "Lxc Setup complete!"
    pause_script
}

virtualbox_setup()
{

    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S virtualbox virtualbox-host-modules-arch,")
    commands_to_run+=("snp paru -S virtualbox-ext-oracle")

    commands_to_run+=("terminal_title 'Done with segment execuption'")
    live_command_output "" "${commands_to_run[@]}"

    output "Virtualbox Setup complete!"
    pause_script
}

initial_setup
libvirt_setup
get_out