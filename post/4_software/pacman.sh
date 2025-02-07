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

install_pacman_packages() {
    local packages=("$@")
    local packages_to_install=()

    for package in "${packages[@]}"; do
        if check_command_exists "$package"; then
            packages_to_install+=("$package")
        else
            continue_script 1 "Package $package exists" "$package is already installed."
        fi
    done

    if [ "${#packages_to_install[@]}" -gt 0 ]; then
        live_command_output "" "" "yes" "Installing packages" "pacman -S --noconfirm ${packages_to_install[*]}"
    else
        continue_script 2 "Packages exist" "All packages are already installed."
    fi
}