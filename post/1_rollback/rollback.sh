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

rollback_menu() {
    local title="BTRFS Rollback Configurator"
    local description="This script simplifies the process of setting up rollback support with BTRFS. It requires BTRFS for managing snapshots and rollback functionality. Select an option to proceed."
    local user="$USER_WITH_SUDO_USER"
    local pass="$USER_WITH_SUDO_PASS"

    while true; do
        local options=(\
            "Install snapper                     (Wrapper for btrfs subvols. Manages snaps)"\
            "Install snap-pac                    (Snaps for pacman commands)"\
            "Install snapper-rollback            (tool for autorollback from snaps)"\
            "Install snp                         (Snaps whenever user wants)"\
            "Clean fstab                         (Clean fstab from comments)"\
            "Back"
        )
        menu_prompt build_choice "$title" "$description" "${options[@]}"
        case $build_choice in
            0)  configure_snapper;;
            1)  configure_snap_pac;;
            2)  configure_snapper_rollback "$user" "$pass";;
            3)  configure_snp "$user" "$pass";;
            4)  clean_fstab;;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again.";;
        esac
    done
}

clean_fstab() {
    sed -i '/^#.*\/dev\//d' /etc/fstab && sed -i '/^[[:space:]]*$/d' /etc/fstab
}

configure_snapper() {
    install_pacman_packages snapper
    local commands_to_run=()

    if ! check_folder_exists "/.snapshots"; then
        commands_to_run+=("mkdir -p /.snapshots")
    fi
    commands_to_run+=("umount /.snapshots && rm -rf /.snapshots")
    commands_to_run+=("snapper -c root create-config /")
    commands_to_run+=("mount -a")
    commands_to_run+=("systemctl daemon-reload")
    
    live_command_output "" "" "yes" "Configuring Snapper for rollbacks" "${commands_to_run[@]}"
    continue_script 2 "Snapper" "Snapper setup complete!"
}

configure_snap_pac() {
    install_pacman_packages snap-pac
    continue_script 2 "Snap-pac" "Snap-pac setup complete!"
}

configure_snapper_rollback() {
    local user="$1"
    local pass="$2"
    install_aur_package "$user" "$pass" "https://aur.archlinux.org/snapper-rollback.git"


    commands_to_run=()
    commands_to_run+=("
        if grep -qE '^[#]*mountpoint[[:space:]]*=[[:space:]]*/btrfsroot' /etc/snapper-rollback.conf; then
            sed -i 's|^[#]*mountpoint[[:space:]]*=[[:space:]]*/btrfsroot|mountpoint = /.btrfsroot|' /etc/snapper-rollback.conf
            echo \"mountpoint updated to /.btrfsroot in /etc/snapper-rollback.conf\"
        else
            echo \"mountpoint entry not found in /etc/snapper-rollback.conf\"
        fi")
    live_command_output "" "" "yes" "Configuring snapper-rollback" "${commands_to_run[@]}"
    continue_script 2 "Snapper-rollback complete" "Snapper-rollback setup complete!"
}

configure_snp() {
    local user="$1"
    local pass="$2"
    install_aur_package "$user" "$pass" "https://aur.archlinux.org/snp.git"
}
