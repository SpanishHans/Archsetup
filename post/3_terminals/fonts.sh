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

################################################################################
# Fonts
################################################################################

fonts_menu() {
    local selected_choices=()
    
    declare -A fonts=(
        ["Terminus"]="terminus-font A clean, monospaced font optimized for terminal use in text-only environments (init 3). Perfect for coding and system monitoring."
        ["Dejavu"]="ttf-dejavu-nerd A versatile font family with wide character support, balancing clarity and elegance for interfaces and documents."
        ["0x proto"]="ttf-0xproto-nerd A bold, futuristic font with sharp, geometric shapes, ideal for sci-fi and tech-inspired designs."
        ["Fira code"]="ttf-firacode-nerd A monospaced font with ligatures for coding, offering a clean and expressive environment for developers."
        ["Font awesome"]="ttf-font-awesome A scalable icon font with thousands of customizable icons, perfect for modern UI/UX design."
    )

    local options=()
    for key in "${!fonts[@]}"; do
        IFS=" " read -r pac_name desc <<< "${fonts[$key]}"
        options+=("$key" "$desc" "off")
    done

    selected_choices=($(multiselect_prompt "Choose Fonts" "Select multiple fonts" "${options[@]}"))

    pause_script "" "$selected_choices"

    local package_names=()
    for choice in "${selected_choices[@]}"; do
        IFS=" " read -r pac_name _ <<< "${fonts[$choice]}"
        package_names+=("$pac_name")
    done

    pause_script "" "$package_names"

    install_fonts "${package_names[@]}"
}

install_fonts() {
    local -a given_array=("$@")  # Correctly handle passed array elements
    local commands_to_run=()
    local options=()

    for key in "${!given_array[@]}"; do
        IFS='|' read -r pac_name desc <<< "${given_array[$key]}"
        pac_name=$(echo "$pac_name" | xargs)
        desc=$(echo "$desc" | xargs)
        
        install_pacman_packages "$pac_name"
        options+=("$pac_name")
    done

    continue_script 2 "Installed fonts" "Finished installing all selected fonts.

Installed:    
$(printf "%s\n" "${options[@]}")"
}


fonts_menu() {
    local selected_choices=()
    
    declare -A fonts=(
        ["Terminus"]="terminus-font A clean, monospaced font optimized for terminal use in text-only environments (init 3). Perfect for coding and system monitoring."
        ["Dejavu"]="ttf-dejavu-nerd A versatile font family with wide character support, balancing clarity and elegance for interfaces and documents."
        ["0x proto"]="ttf-0xproto-nerd A bold, futuristic font with sharp, geometric shapes, ideal for sci-fi and tech-inspired designs."
        ["Fira code"]="ttf-firacode-nerd A monospaced font with ligatures for coding, offering a clean and expressive environment for developers."
        ["Font awesome"]="ttf-font-awesome A scalable icon font with thousands of customizable icons, perfect for modern UI/UX design."
    )

    local options=()
    for key in "${!fonts[@]}"; do
        IFS=" " read -r pac_name desc <<< "${fonts[$key]}"
        options+=("$key" "$desc" "off")
    done

    selected_choices=($(multiselect_prompt "Choose Fonts" "Select multiple fonts" "${options[@]}"))

    
}
