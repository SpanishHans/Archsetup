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
source ./post/users.sh

check_kvm() {
    virtualization_ok=""
    kvm_ok=""

    if LC_ALL=C.UTF-8 lscpu | grep -q 'Virtualization'; then
        virtualization_ok='Virtualization supported: YES';
    else
        virtualization_ok='Virtualization supported: NO';
        exit 1;
    fi

    if zgrep -q CONFIG_KVM= /proc/config.gz; then
        kvm_ok='KVM enabled: YES';
    else
        kvm_ok='KVM enabled: NO';
        exit 1;
    fi

    pause_script "Virt-Manager" "Virt manager initial check completed:

1) KVM. --> $kvm_ok
2) Virtualization --> $virtualization_ok"
}

configure_libvirt() {

    check_kvm
    get_users userlist
    input_text\
        libvirt_user\
        "Libvirt user"\
        "Please enter the user who shall be added to libvirt group:\n\n$userlist"\
        "What user to add to libvirt group?"

    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S libvirt dnsmasq virt-manager")
    commands_to_run+=("usermod -aG libvirt $libvirt_user")

    commands_to_run+=("echo \"unix_sock_group = 'libvirt'\" | tee -a /etc/libvirt/libvirtd.conf")
    commands_to_run+=("echo \"unix_sock_rw_perms = '0770'\" | tee -a /etc/libvirt/libvirtd.conf")

    commands_to_run+=("systemctl restart libvirtd")
    live_command_output "" "" "Installing dependencies" "${commands_to_run[@]}"

    pause_script "Libvirt" "Libvirt has been setup correctly!"
}

configure_docker() {
    get_users userlist
    input_text\
        docker_user\
        "Docker user"\
        "Please enter the user who shall be added to docker group\n\n$userlist"\
        "What user to add to docker group?: "

    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S docker docker-compose && usermod -aG docker $docker_user")
    commands_to_run+=("systemctl enable docker")
    commands_to_run+=("systemctl start --now docker")

    live_command_output "" "" "Installing Docker" "${commands_to_run[@]}"
    pause_script "Docker" "Docker Setup complete!"
}

configure_podman() {
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S podman")
    
    live_command_output "" "" "Installing Podman" "${commands_to_run[@]}"
    pause_script "Podman" "Podman Setup complete!"
}

configure_distrobox() {
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S distrobox")

    live_command_output "" "" "Installing Distrobox" "${commands_to_run[@]}"
    pause_script "Distrobox" "Distrobox Setup complete!"
}

configure_lxc() {
    if ! command -v virsh &>/dev/null; then
        continue_script "No libvirt" "Libvirt is not installed. Proceeding with configuration."
        configure_libvirt
    else
        continue_script "libvirt exists" "Libvirt is already installed."
    fi
    pause_script "Lxc" "Lxc Setup complete!"
}

configure_virtualbox() {
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S virtualbox virtualbox-host-modules-arch")

    live_command_output "" "" "Installing Virtualbox" "${commands_to_run[@]}"
    pause_script "Virtualbox" "Virtualbox Setup complete!"
}

configure_vbox_ext() {
    local user="$1"
    if ! command -v virtualbox &>/dev/null; then
        continue_script "No Virtualbox" "Virtualbox is not installed. Proceeding with configuration."
        configure_virtualbox
    else
        continue_script "Virtualbox exists" "Virtualbox is already installed."
    fi
    install_aur_package "$user" "https://aur.archlinux.org/virtualbox-ext-oracle.git"
}

configure_classic_containers() {
    local title='Select a container technology.'
    local description="This script helps you install various container technologies. Choose the one that best fits your needs."

    while true; do
        local options=(\
            'Docker              (Classic containers, propietary and daemon based.)'\
            'Podman              (FLOSS containers, every container is its own process, generally rootless.)'\
            "Back"
        )
        menu_prompt ht1_menu_choice "$title" "$description" "${options[@]}"
        case $ht1_menu_choice in
            0)  configure_docker;;
            1)  configure_podman;;
            b)  break;;
            *)  continue_script "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}

config_containers() {
    local title='Type 2 hypervisors.'
    local description="This script helps you install different types of containers."

    while true; do
        local options=(\
            'Container technology         (Containers)'\  
            'Distrobox                    (Containers for running tiny VMs.)'\
            'LXC Containers               (Containers but closer to baremetal. Fixed resources, think VM.)'\
            "Back"
        )
        menu_prompt ht2_menu_choice "$title" "$description" "${options[@]}"
        case $ht2_menu_choice in
            0)  configure_classic_containers;;
            1)  configure_distrobox;;
            2)  configure_lxc;;
            b)  break;;
            *)  continue_script "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}

hyper_type_1() {
    if ! command -v virsh &>/dev/null; then
        continue_script "No libvirt" "Libvirt is not installed. Proceeding with configuration."
        configure_libvirt
    else
        continue_script "libvirt exists" "Libvirt is already installed."
    fi
    commands_to_run=()
    commands_to_run+=("sed -i \"s/^#user = .*/user = '$libvirt_user'/\" /etc/libvirt/qemu.conf")
    commands_to_run+=("sed -i \"s/^#group = .*/group = '$libvirt_user'/\" /etc/libvirt/qemu.conf")    

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
            0)  commands_to_run+=("pacman --noconfirm -S qemu-desktop")
                break;;
            1)  commands_to_run+=("pacman --noconfirm -S qemu-emulators-full")
                break;;
            2)  commands_to_run+=("pacman --noconfirm -S qemu-full")
                break;;
            b)  break;;
            *)  continue_script "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done

    live_command_output "" "" "Installing selected QEMU hypervisor" "${commands_to_run[@]}"
    pause_script "Qemu" "Qemu Setup complete!"
}

hyper_type_2() {
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
            1)  configure_vbox_ext "sysadmin";;
            b)  break;;
            *)  continue_script "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}

config_hypervisors() {
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
            *)  continue_script "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}

virtualization_menu () {
    local title='Virtualization Technology Installer'
    local description="This script helps you install various virtualization technologies for your system. Choose the one that best fits your needs."

    while true; do
        local options=(\
            'Containers         (Containers like Docker, Distrobox or LXC)'\  
            'VM Hypervisors     (QEMU and Virtualbox)'\
            "Back"
        )
        menu_prompt virt_menu_choice "$title" "$description" "${options[@]}"
        case $virt_menu_choice in
            0)  config_containers;;
            1)  config_hypervisors;;
            b)  break;;
            *)  continue_script "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}