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

source ./globals.sh

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

    live_command_output "${commands_to_run[@]}"

    output "Initial Setup complete!"
    pause_script
}

libvirt_setup()
{
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S libvirt dnsmasq virt-manager && usermod -aG libvirt $USER")

    live_command_output "${commands_to_run[@]}"

    while true; do
        clear
        output 'What hypervisor do you want to install?'
        output '1) QEMU'
        output '2) LXC'
        output '3) VirtualBox'
        output '0) Nothing'
        read -p 'Insert the number of your selection: ' -r QEMU_choice
        case $QEMU_choice in
            
            1 ) qemu_setup
                break
                ;;
            2 ) lxc_setup
                break
                ;;
            3 ) virtualbox_setup
                break
                ;;
            0 ) output 'I dont want shit, get out of here'
                break
                ;;
            * ) output 'You did not enter a valid selection.'
        esac
    done

    output "Libvirt and whatever hypervisor you installed have been setup correctly!"
    pause_script
}

qemu_setup()
{

    commands_to_run=()

    while true; do
        clear
        output 'What qemu packages to install?'
        output '1) qemu-desktop (Full-system x86_64 only)'
        output '2) qemu-emulators-full (Full-system and Usermode emulation both for x86 and ARM)'
        output '3) qemu-full (Everything under the sun)'
        output '0) Nothing'
        read -p 'Insert the number of your selection: ' -r QEMU_choice
        case $QEMU_choice in
            
            1 ) commands_to_run+=("pacman --noconfirm -S qemu-desktop")
                break
                ;;
            2 ) commands_to_run+=("pacman --noconfirm -S qemu-emulators-full")
                break
                ;;
            3 ) commands_to_run+=("pacman --noconfirm -S qemu-full")
                break
                ;;
            0 ) output 'I dont want shit, get out of here'
                break
                ;;
            * ) output 'You did not enter a valid selection.'
        esac
    done

    live_command_output "${commands_to_run[@]}"

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

    live_command_output "${commands_to_run[@]}"

    output "Virtualbox Setup complete!"
    pause_script
}

initial_setup
libvirt_setup
get_out