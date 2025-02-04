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

configure_kitty() {
    install_pacman_package "kitty" ""
    live_command_output "" "" "Configuring kitty terminal" "${local commands_to_run[@]}"
}
configure_alacritty() {
    install_pacman_package "alacritty" ""
    live_command_output "" "" "Configuring alacritty terminal" "${local commands_to_run[@]}"
}
configure_terminator() {
    install_pacman_package "terminator" ""
    live_command_output "" "" "Configuring terminator terminal" "${local commands_to_run[@]}"
}
configure_tilix() {
    install_pacman_package "tilix" ""
    live_command_output "" "" "Configuring tilix terminal" "${local commands_to_run[@]}"
}
configure_gnome_terminal() {
    install_pacman_package "gnome-terminal" ""
    live_command_output "" "" "Configuring gnome-terminal terminal" "${local commands_to_run[@]}"
}
configure_konsole() {
    install_pacman_package "konsole" ""
    live_command_output "" "" "Configuring konsole terminal" "${local commands_to_run[@]}"
}

################################################################################
# Shell
################################################################################

configure_bash() {
    local term_user="$1"

    install_pacman_package "bash" ""
    local commands_to_run=()
    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/bash" ]; then
        local commands_to_run+=("chsh -s /bin/bash $term_user")
    fi
    live_command_output "" "" "Configuring bash terminal" "${local commands_to_run[@]}"

    local title="Install frameworks for bash"
    local description="This allows you to set up different frameworks for bash. Please select the framework which shall be configured."
    while true; do
        local options=(\
            "Bash it"\
            "Back"
        )
        menu_prompt bash_choice "$title" "$description" "${options[@]}"
        case $bash_choice in
            1)  configure_bash_it;break;;
            7)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
}

configure_zsh() {
    local term_user="$1"

    install_pacman_package "zsh" ""
    local commands_to_run=()
    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/zsh" ]; then
        local commands_to_run+=("chsh -s /bin/zsh $term_user")
    fi
    live_command_output "" "" "Configuring zsh terminal" "${local commands_to_run[@]}"

    local title="Install frameworks for zsh"
    local description="This allows you to set up different frameworks for zsh. Please select the framework which shall be configured."
    while true; do
        local options=(\
            "Oh My Zsh"\
            "Back"
        )
        menu_prompt zsh_choice "$title" "$description" "${options[@]}"
        case $zsh_choice in
            1)  configure_oh_my_zsh;break;;
            7)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
}

configure_fish() {
    local term_user="$1"

    install_pacman_package "fish" ""
    local commands_to_run=()
    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/fish" ]; then
        local commands_to_run+=("chsh -s /bin/fish $term_user")
    fi
    live_command_output "" "" "Configuring fish terminal" "${local commands_to_run[@]}"

    local title="Install frameworks for fish"
    local description="This allows you to set up different frameworks for fish. Please select the framework which shall be configured."
    while true; do
        local options=(\
            "Fisher"\
            "Back"
        )
        menu_prompt fish_choice "$title" "$description" "${options[@]}"
        case $fish_choice in
            1)  configure_fisher;break;;
            7)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
}

configure_elvish() {
    local term_user="$1"

    install_pacman_package "elvish" ""
    local commands_to_run=()
    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/elvish" ]; then
        local commands_to_run+=("chsh -s /bin/elvish $term_user")
    fi
    live_command_output "" "" "Configuring elvish terminal" "${local commands_to_run[@]}"
}

configure_tcsh() {
    local term_user="$1"

    install_pacman_package "tcsh" ""
    local commands_to_run=()
    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/tcsh" ]; then
        local commands_to_run+=("chsh -s /bin/tcsh $term_user")
    fi
    live_command_output "" "" "Configuring tcsh terminal" "${local commands_to_run[@]}"
}

configure_nushell() {
    local term_user="$1"

    install_pacman_package "nushell" ""
    local commands_to_run=()
    if [ "$(getent passwd "$term_user" | cut -d: -f7)" != "/bin/nu" ]; then
        local commands_to_run+=("chsh -s /bin/nu $term_user")
    fi
    live_command_output "" "" "Configuring nu terminal" "${local commands_to_run[@]}"
}

################################################################################
# Frameworks
################################################################################

configure_bash_it() {
    local term_user="$1"
    local term_pass="$2"

    if ! check_folder_exists "/home/$term_user/.bash_it"; then
        local commands_to_run=()
        commands_to_run+=("git clone --depth=1 https://github.com/Bash-it/bash-it.git /home/$term_user/.bash_it && /home/$term_user/.bash_it/install.sh")
        live_command_output "$term_user" "$term_pass" "Installing Bash-it" "${commands_to_run[@]}"
    else
        continue_script "Bash-it is already installed."
    fi
}

configure_oh_my_zsh() {
    local term_user="$1"
    local term_pass="$2"

    if ! check_folder_exists "$/home/$term_user/.oh-my-zsh"; then
        local commands_to_run=()
        local commands_to_run+=("curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash")
        live_command_output "$term_user" "$term_pass" "Installing ohmyzsh" "${commands_to_run[@]}"
    else
        continue_script "Ohmyzsh is already installed."
    fi
}

configure_fisher() {
    local term_user="$1"
    local term_pass="$2"

    if ! check_folder_exists "/home/$term_user/.config/fish/functions/fisher.fish"; then
        local commands_to_run=()
        commands_to_run+=("fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'")
        live_command_output "$term_user" "$term_pass" "Installing Fisher for Fish" "${commands_to_run[@]}"
    else
        continue_script "Fisher is already installed."
    fi
}

################################################################################
# styling
################################################################################

starship_theme_pure_prompt() {
    local term_username="$1"

    local commands_to_run=()
    local commands_to_run+=("starship preset gruvbox-rainbow -o /home/$term_username/.config/starship.toml")
    live_command_output "" "" "Configuring starship for $term_username" "${local commands_to_run[@]}"
}

starship_theme_pastel_powerline() {
    local term_username="$1"

    local commands_to_run=()
    local commands_to_run+=("starship preset gruvbox-rainbow -o /home/$term_username/.config/starship.toml")
    live_command_output "" "" "Configuring starship for $term_username" "${local commands_to_run[@]}"
}

starship_theme_tokyo_night() {
    local term_username="$1"

    local commands_to_run=()
    local commands_to_run+=("starship preset gruvbox-rainbow -o /home/$term_username/.config/starship.toml")
    live_command_output "" "" "Configuring starship for $term_username" "${local commands_to_run[@]}"
}

starship_theme_gruvbox_rainbow() {
    local term_username="$1"

    local commands_to_run=()
    local commands_to_run+=("starship preset gruvbox-rainbow -o /home/$term_username/.config/starship.toml")
    live_command_output "" "" "Configuring starship for $term_username" "${local commands_to_run[@]}"
}

starship_theme_jetpack() {
    local term_username="$1"

    local commands_to_run=()
    local commands_to_run+=("starship preset gruvbox-rainbow -o /home/$term_username/.config/starship.toml")
    live_command_output "" "" "Configuring starship for $term_username" "${local commands_to_run[@]}"
}

starship_themes() {
    title="Shell configurator: pick shell"
    description="Please select a shell from the menu below."
    while true; do
        local options=(
            "Pure Prompt"\
            "Pastel Powerline"\
            "Tokyo Night"\
            "Gruvbox Rainbow"\
            "Jetpack"\
            "Back"
        )
        menu_prompt shell_choice "$title" "$description" "${options[@]}"
        case $shell_choice in
            0)  starship_theme_pure_prompt;;
            1)  starship_theme_pastel_powerline;;
            2)  starship_theme_tokyo_night;;
            3)  starship_theme_gruvbox_rainbow;;
            4)  starship_theme_jetpack;;
            b)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
}

configure_oh_my_posh(){
    local term_username="$1"
    local shell_path="$(getent passwd "$term_username" | cut -d: -f7)"

    if ! check_folder_exists "$starship_config_path/starship.toml"; then
        local commands_to_run=("mkdir -p $starship_config_path && touch $starship_config_path/starship.toml")
        live_command_output "" "" "Creating config file" "${commands_to_run[@]}"
    else
        continue_script "" "Config file already exists at $starship_config_path. Skipping."
    fi

    case "$shell_path" in
        "/bin/bash")
            config_file="/home/$term_username/.bashrc"
            init_command='eval "$(starship init bash)"'
            starship_themes
            ;;
        "/bin/zsh")
            config_file="/home/$term_username/.zshrc"
            init_command='eval "$(starship init zsh)"'
            starship_themes
            ;;
        "/bin/fish")
            config_file="/home/$term_username/.config/fish/config.fish"
            init_command='starship init fish | source'
            starship_themes
            ;;
        "/bin/elvish")
            config_file="/home/$term_username/.elvish/rc.elv"
            init_command='eval (starship init elvish)'
            starship_themes
            ;;
        "/bin/tcsh")
            config_file="/home/$term_username/.tcshrc"
            init_command='eval `starship init tcsh`'
            starship_themes
            ;;
        *)
            continue_script "Starship not available" "Starship is not supported for this shell"
            return
            ;;
    esac

    local commands_to_run=(
        "if ! grep -Fxq '$init_command' $config_file; then
            echo '$init_command' >> $config_file
            echo 'Starship initialization added to $config_file'
        else
            echo 'Starship initialization already present in $config_file'
        fi"
    )
    live_command_output "$term_username" "" "Configuring Starship for $term_username." "${commands_to_run[@]}"
}

configure_starship () {
    local term_username="$1"
    local starship_config_path="/home/$term_username/.config"
    local shell_path
    shell_path="$(getent passwd "$term_username" | cut -d: -f7)"

    if ! check_folder_exists "$starship_config_path/starship.toml"; then
        local commands_to_run=("mkdir -p $starship_config_path && touch $starship_config_path/starship.toml")
        live_command_output "" "" "Creating config file" "${commands_to_run[@]}"
    else
        continue_script "" "Config file already exists at $starship_config_path. Skipping."
    fi

    case "$shell_path" in
        "/bin/bash")
            config_file="/home/$term_username/.bashrc"
            init_command='eval "$(starship init bash)"'
            starship_themes
            ;;
        "/bin/zsh")
            config_file="/home/$term_username/.zshrc"
            init_command='eval "$(starship init zsh)"'
            starship_themes
            ;;
        "/bin/fish")
            config_file="/home/$term_username/.config/fish/config.fish"
            init_command='starship init fish | source'
            starship_themes
            ;;
        "/bin/elvish")
            config_file="/home/$term_username/.elvish/rc.elv"
            init_command='eval (starship init elvish)'
            starship_themes
            ;;
        "/bin/tcsh")
            config_file="/home/$term_username/.tcshrc"
            init_command='eval `starship init tcsh`'
            starship_themes
            ;;
        *)
            continue_script "Starship not available" "Starship is not supported for this shell"
            return
            ;;
    esac

    local commands_to_run=(
        "if ! grep -Fxq '$init_command' $config_file; then
            echo '$init_command' >> $config_file
            echo 'Starship initialization added to $config_file'
        else
            echo 'Starship initialization already present in $config_file'
        fi"
    )
    live_command_output "$term_username" "" "Configuring Starship for $term_username." "${commands_to_run[@]}"
}

prompts_bash(){
    local title="zsh prompt picker"
    local description="This allows you to pick a prompt tool for your shell."
    while true; do
        local options=(\
            "Starship"\
            "OhMyPosh"\
            "Back"
        )
        menu_prompt term_choice "$title" "$description" "${options[@]}"
        case $term_choice in
            0)  configure_starship;;
            b)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
}

prompts_zsh(){
    local title="prompt picker"
    local description="This allows you to pick a prompt tool for your shell."
    while true; do
        local options=(\
            "Starship"\
            "Back"
        )
        menu_prompt term_choice "$title" "$description" "${options[@]}"
        case $term_choice in
            0)  configure_starship;;
            b)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
}

################################################################################
# Menus
################################################################################

configure_terminal() {
    local title="Terminal configurator."
    local description="This allows you to set up different terminals. Please select the terminal which shall be configured."
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
        case $term_choice in
            0)  configure_kitty;;
            1)  configure_alacritty;;
            2)  configure_terminator;;
            3)  configure_tilix;;
            4)  configure_gnome_terminal;;
            5)  configure_konsole;;
            b)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
}

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
            "Nushell"\
            "Back"
        )
        menu_prompt shell_choice "$title" "$description" "${options[@]}"
        case $shell_choice in
            0)  configure_bash;;
            1)  configure_zsh;;
            2)  configure_fish;;
            3)  configure_elvish;;
            4)  configure_tcsh;;
            5)  configure_nushell;;
            b)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
}

menu_terminal() {

    local title="Terminal global configurator."
    local description="This allows you to set up terminals, shells and frameworks for a given user."
    while true; do
        local options=(\
            "configure terminals"\
            "configure shells"\
            "Back"
        )
        menu_prompt term_choice "$title" "$description" "${options[@]}"
        case $term_choice in
            1)  configure_terminal;;
            2)  configure_shell;;
            7)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
}
