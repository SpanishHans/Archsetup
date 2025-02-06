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
# Prompts
################################################################################

prompts_menu(){
    get_users userlist
    input_text\
        prompt_username\
        "User to change prompt for."\
        "Select shells for a given user. Please select the user whose prompt shall be configured.\n\n$userlist"\
        "What user to configure prompt for?: "
    input_pass\
        prompt_pass\
        "$prompt_username"

    local title="Prompt picker"
    local description="This allows you to pick a prompt tool for your shell."
    while true; do
        local options=(\
            "Starship"\
            "OhMyPosh"\
            "Back"
        )
        menu_prompt term_choice "$title" "$description" "${options[@]}"
        case $term_choice in
            0)  configure_starship "$prompt_username" "$prompt_pass";;
            1)  configure_oh_my_posh "$prompt_username" "$prompt_pass";;
            b)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
}

################################################################################
# Starship
################################################################################

configure_starship (){
    local term_username="$1"
    local term_pass="$2"
    local starship_config_path="/home/$term_username/.config"
    local shell_path="$(getent passwd "$term_username" | cut -d: -f7)"

    commands_to_run=("curl -sS https://starship.rs/install.sh | sh")
    live_command_output "$term_username" "$term_pass" "yes" "Configuring Starship for $term_username." "${commands_to_run[@]}"

    if ! check_file_exists "$starship_config_path/starship.toml"; then
        local commands_to_run=("mkdir -p $starship_config_path && touch $starship_config_path/starship.toml")
        live_command_output "" "" "yes" "Creating config file" "${commands_to_run[@]}"
    else
        continue_script 2 "Folder exists" "Config file already exists at $starship_config_path. Skipping."
    fi

    case "$shell_path" in
        "/bin/bash" | "usr/bin/bash")
            config_file="/home/$term_username/.bashrc"
            init_command='eval "$(starship init bash)"'
            starship_themes "$term_username"
            ;;
        "/bin/zsh" | )
            config_file="/home/$term_username/.zshrc"
            init_command='eval "$(starship init zsh)"'
            starship_themes "$term_username"
            ;;
        "/bin/fish" | "/usr/bin/fish")
            config_file="/home/$term_username/.config/fish/config.fish"
            init_command='starship init fish | source'
            starship_themes "$term_username"
            ;;
        "/bin/elvish" | "/usr/bin/elvish")
            config_file="/home/$term_username/.elvish/rc.elv"
            init_command='eval (starship init elvish)'
            starship_themes "$term_username"
            ;;
        "/bin/tcsh" | "/usr/bin/tcsh")
            config_file="/home/$term_username/.tcshrc"
            init_command='eval `starship init tcsh`'
            starship_themes "$term_username"
            ;;
        *)
            continue_script 2 "Starship not available" "Starship is not supported for this shell"
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
    live_command_output "$term_username" "$term_pass" "yes" "Configuring Starship for $term_username." "${commands_to_run[@]}"
    continue_script 2 "Starship installed" "Starship installed correctly"
}

starship_themes() {
    local term_username="$1"

    title="Starship configurator: pick a theme"
    description="Please select a theme for Starship from the menu below."
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
            0)  starship_theme_pure_prompt "$term_username";;
            1)  starship_theme_pastel_powerline "$term_username";;
            2)  starship_theme_tokyo_night "$term_username";;
            3)  starship_theme_gruvbox_rainbow "$term_username";;
            4)  starship_theme_jetpack "$term_username";;
            b)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
}

starship_theme_pure_prompt() {
    local term_username="$1"

    local commands_to_run=()
    local commands_to_run+=("starship preset gruvbox-rainbow -o /home/$term_username/.config/starship.toml")
    live_command_output "" "" "yes" "Configuring theme for starship for $term_username" "${commands_to_run[@]}"
}

starship_theme_pastel_powerline() {
    local term_username="$1"

    local commands_to_run=()
    local commands_to_run+=("starship preset gruvbox-rainbow -o /home/$term_username/.config/starship.toml")
    live_command_output "" "" "yes" "Configuring theme for starship for $term_username" "${commands_to_run[@]}"
}

starship_theme_tokyo_night() {
    local term_username="$1"

    local commands_to_run=()
    local commands_to_run+=("starship preset gruvbox-rainbow -o /home/$term_username/.config/starship.toml")
    live_command_output "" "" "yes" "Configuring theme for starship for $term_username" "${commands_to_run[@]}"
}

starship_theme_gruvbox_rainbow() {
    local term_username="$1"

    local commands_to_run=()
    local commands_to_run+=("starship preset gruvbox-rainbow -o /home/$term_username/.config/starship.toml")
    live_command_output "" "" "yes" "Configuring theme for starship for $term_username" "${commands_to_run[@]}"
}

starship_theme_jetpack() {
    local term_username="$1"

    local commands_to_run=()
    local commands_to_run+=("starship preset gruvbox-rainbow -o /home/$term_username/.config/starship.toml")
    live_command_output "" "" "yes" "Configuring theme for starship for $term_username" "${commands_to_run[@]}"
}

################################################################################
# Oh my posh
################################################################################

configure_oh_my_posh () {
    local term_username="$1"
    local term_pass="$2"
    local posh_config_path="/home/$term_username/bin"
    local shell_path="$(getent passwd "$term_username" | cut -d: -f7)"

    commands_to_run=("curl -sS https://starship.rs/install.sh | sh")
    live_command_output "$term_username" "$term_pass" "yes" "Configuring Starship for $term_username." "${commands_to_run[@]}"

    if ! check_folder_exists "$posh_config_path"; then
        local commands_to_run=("mkdir -p $posh_config_path")
        live_command_output "" "" "yes" "Creating config file" "${commands_to_run[@]}"
    else
        continue_script 2 "Folder exists" "Config file already exists at $posh_config_path. Skipping."
    fi

    case "$shell_path" in
        "/bin/bash" | "usr/bin/bash")
            config_file="/home/$term_username/.bashrc"
            init_command='eval "$(oh-my-posh init bash)"'
            oh_my_posh_themes "$term_username" "$config_file" "$init_command"
            ;;
        "/bin/zsh" | "usr/bin/zsh")
            config_file="/home/$term_username/.zshrc"
            init_command='eval "$(oh-my-posh init zsh)"'
            oh_my_posh_themes "$term_username" "$config_file" "$init_command"
            ;;
        "/bin/fish" | "usr/bin/fish")
            config_file="/home/$term_username/.config/fish/config.fish"
            init_command='oh-my-posh init fish | source'
            oh_my_posh_themes "$term_username" "$config_file" "$init_command"
            ;;
        "/bin/elvish" | "usr/bin/elvish")
            config_file="/home/$term_username/.elvish/rc.elv"
            init_command='eval (oh-my-posh init elvish)'
            oh_my_posh_themes "$term_username" "$config_file" "$init_command"
            ;;
        "/bin/tcsh" | "usr/bin/tcsh")
            config_file="/home/$term_username/.tcshrc"
            init_command='eval "`oh-my-posh init tcsh`"'
            oh_my_posh_themes "$term_username" "$config_file" "$init_command"
            ;;
        *)
            continue_script 2 "Oh my posh not available" "Oh my posh is not supported for this shell"
            return
            ;;
    esac

    local commands_to_run=(
        "if ! grep -Fxq '$init_command' $config_file; then
            echo '$init_command' >> $config_file
            echo 'Oh my posh initialization added to $config_file'
        else
            echo 'Oh my posh initialization already present in $config_file'
        fi"
    )
    live_command_output "$term_username" "$term_pass" "yes" "Configuring Oh my posh for $term_username." "${commands_to_run[@]}"
    continue_script 2 "Oh my posh installed" "Oh my posh installed correctly"
}

oh_my_posh_themes() {
    local term_username="$1"
    local file="$2"
    local comm="$3"

    title="posh configurator: pick a theme"
    description="Please select a theme for posh from the menu below."
    while true; do
        local options=(
            "1 shell"\
            "Back"
        )
        menu_prompt shell_choice "$title" "$description" "${options[@]}"
        case $shell_choice in
            0)  posh_theme_1_shell "$term_username" "$file" "$comm";;
            b)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
}

posh_theme_1_shell() {
    local term_username="$1"
    local config_file="$2"
    local init_command="$3"
    local extra_flags="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json"
    local full_command="$init_command $extra_flags"

    local commands_to_run=(
        "if grep -E -q \"^$init_command(\\s|$)\" $config_file; then
            sed -i \"s|^$init_command.*|$full_command|\" $config_file
            echo 'Existing init_command replaced in $config_file'
        else
            echo '$full_command' >> $config_file
            echo 'init_command added to $config_file'
        fi"
    )
    live_command_output "$term_username" "" "yes" "Configuring Oh my posh for $term_username." "${commands_to_run[@]}"
}

#https://ohmyposh.dev/docs/themes
