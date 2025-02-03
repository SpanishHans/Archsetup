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

################################################################################
# Fonts
################################################################################

install_fonts() {
    local -n given_array="$1"
    local commands_to_run=()

    local options=()
    for key in "${!given_array[@]}"; do
        IFS=" | " read -r pac_name desc <<< "${given_array[$key]}"

        pac_name=$(echo "$pac_name" | xargs)
        desc=$(echo "$desc" | xargs)
        local commands_to_run+=("pacman --noconfirm -S $pac_name")
        local options+=("$pac_name")
    done

    live_command_output "" "" "Configuring selected fonts" "${local commands_to_run[@]}"
    pause_script "Finished configuring fonts" "Finished installing all selected fonts.

Installed:    
$(printf "%s\n" "${options[@]}")"
}

configure_nerd_fonts() {

    declare -A fonts
    local fonts=(
        ["terminus"]="terminus-font | A clean, monospaced font optimized for terminal use in text-only environments (init 3). Perfect for coding and system monitoring."
        ["dejavu"]="ttf-dejavu-nerd | A versatile font family with wide character support, balancing clarity and elegance for interfaces and documents."
        ["proto"]="ttf-0xproto-nerd | A bold, futuristic font with sharp, geometric shapes, ideal for sci-fi and tech-inspired designs."
        ["fira"]="ttf-firacode-nerd | A monospaced font with ligatures for coding, offering a clean and expressive environment for developers."
        ["fa"]="ttf-font-awesome | A scalable icon font with thousands of customizable icons, perfect for modern UI/UX design."
    )

    local menu_options=()
    for key in "${!fonts[@]}"; do
        IFS=" | " read -r pac_name desc <<< "${fonts[$key]}"
        menu_options+=("$key" "$desc" "off")
    done
    
    multiselect_prompt\
        font_menu_choice\
        menu_options\
        "Starting font picker"\
        "The following are fonts considered nerd beucase they are for the tty or for the terminal.
        
Please choose what fonts you require."

    declare -A filtered_fonts
    for choice in "${font_menu_choice[@]}"; do
        if [[ -n "${fonts[$choice]}" ]]; then
            filtered_fonts["$choice"]="${fonts[$choice]}"
        fi
    done
    install_fonts filtered_fonts
}

################################################################################
# Terminals
################################################################################

configure_bash() {
    install_pacman_package "bash" "$"
    local commands_to_run=()
    local commands_to_run+=("chsh -s \$(which bash)")

    live_command_output "" "" "" "${commands_to_run[@]}"
}

################################################################################
# Shell
################################################################################

configure_bash() {
    install_pacman_package "bash" ""
    local commands_to_run=()
    local commands_to_run+=("chsh -s \$(which bash)")

    live_command_output "" "" "Configuring bash terminal" "${local commands_to_run[@]}"
}

configure_zsh() {
    install_pacman_package "zsh" ""
    local commands_to_run=()
    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/zsh" ]; then
        local commands_to_run+=("chsh -s /bin/zsh $term_user")
    fi
    local commands_to_run+=("chsh -s \$(which zsh)")
    local commands_to_run+=("sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"")

    live_command_output "" "" "Configuring zsh terminal" "${local commands_to_run[@]}"
}

configure_fish() {
    install_pacman_package "fish" ""
    local commands_to_run=()
    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/fish" ]; then
        local commands_to_run+=("chsh -s /bin/fish $term_user")
    fi
    local commands_to_run+=("curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher")

    live_command_output "" "" "Configuring fish terminal" "${local commands_to_run[@]}"
}

configure_elvish() {
    install_pacman_package "elvish" ""
    local commands_to_run=()
    local commands_to_run+=("chsh -s \$(which elvish)")

    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/elvish" ]; then
        local commands_to_run+=("chsh -s /bin/elvish $term_user")
    fi

    live_command_output "" "" "Configuring elvish terminal" "${local commands_to_run[@]}"
}

configure_tcsh() {
    install_pacman_package "tcsh" ""
    local commands_to_run=()

    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/tcsh" ]; then
        local commands_to_run+=("chsh -s /bin/tcsh $term_user")
    fi

    live_command_output "" "" "Configuring tcsh terminal" "${local commands_to_run[@]}"
}

configure_ksh() {
    install_pacman_package "ksh" ""
    local commands_to_run=()

    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/ksh" ]; then
        local commands_to_run+=("chsh -s /bin/ksh $term_user")
    fi

    live_command_output "" "" "Configuring ksh terminal" "${local commands_to_run[@]}"
}

configure_dash() {
    install_pacman_package "dash" ""
    local commands_to_run=()

    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/dash" ]; then
        local commands_to_run+=("chsh -s /bin/dash $term_user")
    fi

    live_command_output "" "" "Configuring dash terminal" "${local commands_to_run[@]}"
}

################################################################################
# Frameworks
################################################################################

configure_bash() {
    local commands_to_run=()
    if ! command -v bash &> /dev/null; then
        local commands_to_run+=("sudo pacman -S --noconfirm bash")
    fi
    local commands_to_run+=("chsh -s \$(which bash)")

    for cmd in "${local commands_to_run[@]}"; do
        eval "$cmd"
    done
}

configure_zsh() {
    local commands_to_run=()
    if ! command -v zsh &> /dev/null; then
        local commands_to_run+=("sudo pacman -S --noconfirm zsh")
    fi
    local commands_to_run+=("chsh -s \$(which zsh)")
    local commands_to_run+=("sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"")

    for cmd in "${local commands_to_run[@]}"; do
        eval "$cmd"
    done
}

configure_fish() {
    local commands_to_run=()
    if ! command -v fish &> /dev/null; then
        local commands_to_run+=("sudo pacman -S --noconfirm fish")
    fi
    local commands_to_run+=("chsh -s \$(which fish)")
    local commands_to_run+=("curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher")

    for cmd in "${local commands_to_run[@]}"; do
        eval "$cmd"
    done
}

configure_elvish() {
    local commands_to_run=()
    if ! command -v elvish &> /dev/null; then
        local commands_to_run+=("sudo pacman -S --noconfirm elvish")
    fi
    local commands_to_run+=("chsh -s \$(which elvish)")

    for cmd in "${local commands_to_run[@]}"; do
        eval "$cmd"
    done
}

configure_tcsh() {
    local commands_to_run=()
    if ! command -v tcsh &> /dev/null; then
        local commands_to_run+=("pacman --noconfirm -S tcsh")
    fi

    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/tcsh" ]; then
        local commands_to_run+=("chsh -s /bin/tcsh $term_user")
    fi

    for cmd in "${local commands_to_run[@]}"; do
        eval "$cmd"
    done
}

configure_ksh() {
    local commands_to_run=()
    if ! command -v ksh &> /dev/null; then
        local commands_to_run+=("pacman --noconfirm -S ksh")
    fi

    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/ksh" ]; then
        local commands_to_run+=("chsh -s /bin/ksh $term_user")
    fi

    for cmd in "${local commands_to_run[@]}"; do
        eval "$cmd"
    done
}

configure_dash() {
    local commands_to_run=()
    if ! command -v dash &> /dev/null; then
        local commands_to_run+=("pacman --noconfirm -S dash")
    fi

    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/dash" ]; then
        local commands_to_run+=("chsh -s /bin/dash $term_user")
    fi

    for cmd in "${local commands_to_run[@]}"; do
        eval "$cmd"
    done
}

################################################################################
# extras
################################################################################

set_oh_my_zsh () {
    local term_user="$1"
    local term_pass="$2"
    
    configure_zsh

    if [ ! -d "/home/$term_user/.oh-my-zsh" ]; then
        local commands_to_run=()
        local commands_to_run+=("curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash")
    fi

    live_command_output "" "" "Configuring zsh for $term_user" "${local commands_to_run[@]}"
}


set_oh_my_zsh_and_starship () {
    local term_user="$1"
    local term_pass="$2"
    
    configure_zsh

    if [ ! -d "/home/$term_user/.oh-my-zsh" ]; then
        local commands_to_run=()
        local commands_to_run+=("curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash")
    fi

    local commands_to_run+=(
        "if ! grep -Fxq 'eval \"\$(starship init zsh)\"' /home/$term_username/.zshrc; then
            echo 'eval \"\$(starship init zsh)\"' >> /home/$term_username/.zshrc
            echo \"Starship initialization added to .zshrc\"
        else
            echo \"Starship initialization already present in .zshrc\"
        fi"
    )
    local commands_to_run+=("mkdir -p /home/$term_username/.config && touch /home/$term_username/.config/starship.toml")
    local commands_to_run+=("starship preset gruvbox-rainbow -o /home/$term_username/.config/starship.toml")
    live_command_output "" "" "Configuring starship for $term_username" "${local commands_to_run[@]}"
    
}

################################################################################
# Menus
################################################################################

configure_shell() {
    get_users userlist

    input_text\
        term_username\
        "User to change shell for."\
        "Select shells for a given user. Please select the user whose shell shall be configured.\n\n$userlist"\
        "What user to configure terminal for?: "
    input_pass\
        term_pass\
        "$term_username"

    title="Shell configurator: pick shell"
    description="Please select a shell from the menu below."
    while true; do
        local options=(
            "Bash"\
            "Zsh"\
            "Fish"\
            "Elvish"\
            "Tcsh"\
            "Ksh"\
            "Dash"\
            "Exit"
        )
        menu_prompt shell_choice "$title" "$description" "${options[@]}"
        case $choice in
            1)  echo "You selected Bash.";;
            7)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done

    pause_script "Terminal" "Terminal Setup complete!"
}

configure_terminal() {
    get_users userlist

    local title="Terminal configurator: pick user"
    local description="This allows you to set up different modes of zsh for a given user. Please select the user whose terminal shall be configured.\n\n$userlist"
    get_users
    input_text\
        term_username\
        "Terminal configuration"\
        "This allows you to set up different terminal frameworks for a given user. Please select the user whose terminal shall be configured.\n\n$userlist"\
        "What user to configure terminal for?: "
    input_pass\
        term_pass\
        "$term_username"

    title="Terminal configurator: pick mode"
    description="Please select configuration mode from the menu below."
    while true; do
        local options=(\
            "Kitty"\
            "Alacritty"\
            "Terminator"\
            "Tilix"\
            "GNOME Terminal"\
            "Konsole"\
            "Back"
        )
        menu_prompt term_choice "$title" "$description" "${options[@]}"
        case $choice in
            1)  configure_kitty;;
            2)  configure_alacritty;;
            3)  configure_terminator;;
            4)  configure_tilix;;
            5)  configure_gnome_terminal;;
            6)  configure_konsole;;
            7)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done

    pause_script "Terminal" "Terminal Setup complete!"
}
