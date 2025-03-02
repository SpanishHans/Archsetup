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

    continue_script 2 "Virt-Manager" "Virt manager initial check completed:

1) KVM. --> $kvm_ok
2) Virtualization --> $virtualization_ok"
}

configure_libvirt() {
    local libvirt_user="$1"
    install_pacman_packages libvirt dnsmasq virt-manager

    check_kvm

    local commands_to_run=()
    commands_to_run+=("usermod -aG libvirt $libvirt_user")

    commands_to_run+=("echo \"unix_sock_group = 'libvirt' \" | tee -a /etc/libvirt/libvirtd.conf")
    commands_to_run+=("echo \"unix_sock_rw_perms = '0770' \" | tee -a /etc/libvirt/libvirtd.conf")

    commands_to_run+=("systemctl enable libvirtd")
    commands_to_run+=("systemctl restart libvirtd")
    live_command_output "" "" "Installing dependencies" "${commands_to_run[@]}"

    continue_script 2 "Libvirt" "Libvirt has been setup correctly!"
}
