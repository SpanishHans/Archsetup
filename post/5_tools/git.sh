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

git_menu() {
    install_pacman_packages git openssh
    commands_to_run=()

    get_users userlist
    input_text\
        git_user\
        "User account"\
        "Please enter the user whose git shall be configured\n\n$userlist"\
        "What user to configure git for?: "
    continue_script 2 "$git_user password" "Please provide that users password for running commands on his behalf."
    input_pass\
        pass\
        "$git_user"
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
    continue_script 2 "ssh key password" "Please create a secure password for the ssh key that $git_user will have."
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
    fi
    live_command_output "" "" "yes" "Installing git" "${commands_to_run[@]}"

    commands_to_run=()
    commands_to_run+=("ssh-agent -s && ssh-add '$ssh_key_path'")
    live_command_output "$git_user" "$pass" "yes" "Installing git" "${commands_to_run[@]}"

    commands_to_run=()
    commands_to_run+=("cat \"${ssh_key_path}.pub\"")
    live_command_output "" "" "yes" "Installing git" "${commands_to_run[@]}"

    continue_script 1 "Git" "Git Setup complete!"
}
