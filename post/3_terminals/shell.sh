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
# Frameworks
################################################################################

configure_bash_it() {
    local term_user="$1"
    local commands_to_run=()

    if [[ -d "/home/$term_user/.bash_it" ]]; then
        commands_to_run+=("rm -rf /home/$term_user/.bash_it")
    fi

    commands_to_run+=("git clone --depth=1 https://github.com/Bash-it/bash-it.git /home/$term_user/.bash_it && /home/$term_user/.bash_it/install.sh")
    commands_to_run+=("chown -R $term_user:$term_user /home/$term_user/.bash_it")
    live_command_output "" "" "yes" "Installing Bash-it" "${commands_to_run[@]}"
}

configure_oh_my_zsh() {
    local term_user="$1"
    local commands_to_run=()

    if [[ -d "/home/$term_user/.oh-my-zsh" ]]; then
        commands_to_run+=("rm -rf /home/$term_user/.oh-my-zsh")
    fi

    if [[ ! -f "/home/$term_user/.zshrc" ]]; then
        commands_to_run+=("touch /home/$term_user/.zshrc")
    fi

    commands_to_run+=("git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /home/$term_user/.oh-my-zsh")
    commands_to_run+=("chown -R $term_user:$term_user /home/$term_user/.oh-my-zsh")
    commands_to_run+=("chown -R $term_user:$term_user /home/$term_user/.zshrc")
    
    commands_to_run+=("cp -f /home/$term_user/.zshrc /home/$term_user/.zshrc.orig")
    commands_to_run+=("cp -f /home/$term_user/.oh-my-zsh/templates/zshrc.zsh-template /home/$term_user/.zshrc")
        
    commands_to_run+=("chown -R $term_user:$term_user /home/$term_user/.oh-my-zsh")
    commands_to_run+=("chown -R $term_user:$term_user /home/$term_user/.zshrc")

    live_command_output "" "" "yes" "Installing ohmyzsh" "${commands_to_run[@]}"
}

configure_fisher() {
    local term_user="$1"
    local commands_to_run=()

    if ! [[ ! -f "/home/$term_user/.config/fish/functions/fisher.fish" ]] || ! check_command_exists "fisher"; then
        commands_to_run+=("fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'")
    fi

    live_command_output "" "" "yes" "Installing Fisher for Fish" "${commands_to_run[@]}"

}

################################################################################
# Shell
################################################################################

shells_menu() {
    pick_user \
        shell_username \
        "User to change shell for." \
        "Select shells for a given user. Please select the user whose shell shall be configured: "

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
            0)  configure_bash "$shell_username" ;;
            1)  configure_zsh "$shell_username" ;;
            2)  configure_fish "$shell_username" ;;
            3)  configure_elvish "$shell_username" ;;
            4)  configure_tcsh "$shell_username" ;;
            5)  configure_nushell "$shell_username" ;;
            b)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
}

configure_bash() {
    local term_user="$1"

    install_pacman_packages bash
    local commands_to_run=("chsh -s /usr/bin/bash $term_user")
    live_command_output "" "" "yes" "Configuring bash terminal" "${commands_to_run[@]}"

    local title="Install frameworks for bash"
    local description="This allows you to set up different frameworks for bash. Please select the framework which shall be configured."
    while true; do
        local options=(\
            "Bash it"\
            "Exit"
        )
        menu_prompt bash_choice "$title" "$description" "${options[@]}"
        case $bash_choice in
            0)  configure_bash_it "$term_user";break;;
            e)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
    continue_script 2 "Bash installed" "Bash installed correctly"
}

configure_zsh() {
    local term_user="$1"

    install_pacman_packages zsh
    local commands_to_run=("chsh -s /usr/bin/zsh $term_user")
    live_command_output "" "" "yes" "Configuring zsh terminal" "${commands_to_run[@]}"

    local title="Install frameworks for zsh"
    local description="This allows you to set up different frameworks for zsh. Please select the framework which shall be configured."
    while true; do
        local options=(\
            "Oh My Zsh"\
            "Exit"
        )
        menu_prompt zsh_choice "$title" "$description" "${options[@]}"
        case $zsh_choice in
            0)  configure_oh_my_zsh "$term_user";break;;
            e)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
    continue_script 2 "Zsh installed" "Zsh installed correctly"
}

configure_fish() {
    local term_user="$1"

    install_pacman_packages fish
    local commands_to_run=("chsh -s /usr/bin/fish $term_user")
    live_command_output "" "" "yes" "Configuring fish terminal" "${commands_to_run[@]}"

    local title="Install frameworks for fish"
    local description="This allows you to set up different frameworks for fish. Please select the framework which shall be configured."
    while true; do
        local options=(\
            "Fisher"\
            "Exit"
        )
        menu_prompt fish_choice "$title" "$description" "${options[@]}"
        case $fish_choice in
            0)  configure_fisher "$term_user";break;;
            e)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
    continue_script 2 "Fish installed" "Fish installed correctly"
}

configure_elvish() {
    local term_user="$1"

    install_pacman_packages elvish
    local commands_to_run=("chsh -s /usr/bin/elvish $term_user")
    live_command_output "" "" "yes" "Configuring elvish terminal" "${commands_to_run[@]}"
    continue_script 2 "Elvish installed" "Elvish installed correctly"
}

configure_tcsh() {
    local term_user="$1"

    install_pacman_packages tcsh
    local commands_to_run=("chsh -s /usr/bin/tcsh $term_user")
    live_command_output "" "" "yes" "Configuring tcsh terminal" "${commands_to_run[@]}"
    continue_script 2 "Tcsh installed" "Tcsh installed correctly"
}

configure_nushell() {
    local term_user="$1"

    install_pacman_packages nushell
    local commands_to_run=("chsh -s /usr/bin/nu $term_user")
    live_command_output "" "" "yes" "Configuring nu terminal" "${commands_to_run[@]}"
    continue_script 2 "Nushell installed" "Nushell installed correctly"
}
