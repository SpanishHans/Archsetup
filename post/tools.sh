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
source ./post/chezmoi.sh
source ./post/users.sh

configure_git() {
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S git")

    get_users userlist
    input_text\
        git_user\
        "User account"\
        "Please enter the user whose git shall be configured\n\n$userlist"\
        "What user to configure git for?: "
    input_text\
        gitusername\
        "Github user of '$git_user'"\
        "Please enter the username in github for '$git_user'"\
        "Enter Git username: "
    input_text\
        gitemail\
        "Github email of '$git_user'"\
        "Please enter the email in github for '$git_user'"\
        "Enter Git email: "
    input_pass\
        sshpass\
        "$git_user"

    home_path="/home/$git_user"
    gitconfig_path="$home_path/.gitconfig"

    commands_to_run+=(
        "cat > $gitconfig_path <<EOF
        [init]
            defaultBranch = main
        [user]
            name = $gitusername
            email = $gitemail
        [core]
            editor = nano
        [alias]
            st = status
            co = checkout
            br = branch
            cm = commit
        [color]
            ui = auto
        EOF"
    )
    commands_to_run+=("chown $git_user:$git_user $gitconfig_path")

    ssh_key_path="$home_path/.ssh/id_ed25519"
    if [ -f "$ssh_key_path" ]; then
        commands_to_run+=("echo 'SSH key already exists at $ssh_key_path.'")
    else
        commands_to_run+=("echo 'Generating SSH key at $ssh_key_path...'")
        commands_to_run+=("mkdir -p $home_path/.ssh")
        commands_to_run+=("ssh-keygen -t ed25519 -C '$gitemail' -f '$ssh_key_path' -P '$sshpass' -N '$sshpass'")
        commands_to_run+=("chown -R $git_user:$git_user $home_path/.ssh")
        commands_to_run+=("sudo -u $git_user bash -c \"eval \\\"\$(ssh-agent -s)\\\" && ssh-add '$ssh_key_path'\"")

    fi
    commands_to_run+=("cat \"${ssh_key_path}.pub\"")
    
    live_command_output "" "" "Installing git" "${commands_to_run[@]}"
    pause_script "Git" "Git Setup complete!"
}

configure_clipboard() {
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S wl-clipboard cliphist grim slurp")

    live_command_output "" "" "Configuring clipboard" "${commands_to_run[@]}"
    pause_script "Clipboard" "Clipboard Setup complete!"
}

tools_menu () {
    local title="Basic Tools Installer"
    local description="This script provides an easy way to install essential tools for your system. Select an option to install the tool of your choice."


    while true; do
        local options=(\
            "Git                (Version control)" \
            "Chezmoi            (dotfile manager)" \
            "Clipboard          (History)" \
            "Back" \
        )
        menu_prompt tools_menu_choice "$title" "$description" "${options[@]}"
        case $tools_menu_choice in
            0)  configure_git;;
            3)  chezmoi_mode;;
            4)  configure_clipboard;;
            b)  break;;
            *)  continue_script "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}