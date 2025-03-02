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
    declare -A fonts=(
        ["terminus"]="terminus-font | A clean, monospaced font optimized for terminal use in text-only environments (init 3). Perfect for coding and system monitoring."
        ["dejavu"]="ttf-dejavu-nerd | A versatile font family with wide character support, balancing clarity and elegance for interfaces and documents."
        ["proto"]="ttf-0xproto-nerd | A bold, futuristic font with sharp, geometric shapes, ideal for sci-fi and tech-inspired designs."
        ["fira"]="ttf-firacode-nerd | A monospaced font with ligatures for coding, offering a clean and expressive environment for developers."
        ["fa"]="ttf-font-awesome | A scalable icon font with thousands of customizable icons, perfect for modern UI/UX design."
    )

    local options=()
    for key in "${!fonts[@]}"; do
        IFS=" | " read -r pac_name desc <<< "${fonts[$key]}"
        options+=("$key" "$desc" "off")
    done

    declare -a font_menu_choice
    multiselect_prompt \
        font_menu_choice \
        "Starting font picker" \
        "The following are fonts considered nerd because they are for the TTY or for the terminal.\n\nPlease choose what fonts you require." \
        options

    declare -A filtered_fonts
    for choice in "${font_menu_choice[@]}"; do
        if [[ -n "${fonts[$choice]}" ]]; then
            filtered_fonts["$choice"]="${fonts[$choice]}"
        fi;
    done

    install_fonts filtered_fonts
}

install_fonts() {
    local -n given_array="$1"
    local commands_to_run=()

    local options=()
    for key in "${!given_array[@]}"; do
        IFS=" | " read -r pac_name desc <<< "${given_array[$key]}"
        pac_name=$(echo "$pac_name" | xargs)
        desc=$(echo "$desc" | xargs)
        install_pacman_packages "$pac_name"
        local options+=("$pac_name")
    done

    continue_script 2 "Installed fonts" "Finished installing all selected fonts.

Installed:    
$(printf "%s\n" "${options[@]}")"
}

fonts_menu() {
    # options=(
    #     "1" "Option One" "off"
    #     "2" "Option Two" "off"
    #     "3" "Option Three" "off"
    #     "4" "Option Four" "off"
    # )

    # Declare a variable to store selected choices
    selected_choices=()
    
    declare -A fonts=(
        ["terminus"]="terminus-font | A clean, monospaced font optimized for terminal use in text-only environments (init 3). Perfect for coding and system monitoring."
        ["dejavu"]="ttf-dejavu-nerd | A versatile font family with wide character support, balancing clarity and elegance for interfaces and documents."
        ["proto"]="ttf-0xproto-nerd | A bold, futuristic font with sharp, geometric shapes, ideal for sci-fi and tech-inspired designs."
        ["fira"]="ttf-firacode-nerd | A monospaced font with ligatures for coding, offering a clean and expressive environment for developers."
        ["fa"]="ttf-font-awesome | A scalable icon font with thousands of customizable icons, perfect for modern UI/UX design."
    )

    local options=()
    for key in "${!fonts[@]}"; do
        IFS=" | " read -r pac_name desc <<< "${fonts[$key]}"
        options+=("$key" "$desc" "off")
    done

    # declare -a font_menu_choice

    # Call the function with the test array
    multiselect_prompt selected_choices "Choose Options" "Select multiple options from the list" "${fonts[@]}"

    # Check the exit status
    if [ $? -eq 0 ]; then
        echo "You selected: ${selected_choices[@]}"
        sleep 2
    else
        echo "Selection canceled."
        sleep 2
    fi
}