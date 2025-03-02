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
    local commands_to_run=()

    pick_user \
        git_user \
        "Local User to setup git for" \
        "Please enter the user whose git shall be configured: "

    input_text \
        gitusername \
        "Github user of '$git_user'" \
        "Please enter the username in github for '$git_user'" \
        "Enter Git username: "

    input_text \
        gitemail \
        "Github email of '$git_user'" \
        "Please enter the email in github for '$git_user'" \
        "Enter Git email: "

    input_pass \
        sshpass \
        "Password for ssh key" \
        "Please provide the password for tthe ssh key that shall be used to authenticate on Github." \
        "Please input the password for the ssh key: "

    home_path="/home/$git_user"
    gitconfig_path="$home_path/.gitconfig"

    if [[ -f "$gitconfig_path" ]]; then
        commands_to_run+=("rm -rf $gitconfig_path")
    fi

    commands_to_run+=("touch $gitconfig_path")
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
")
    commands_to_run+=("chown $git_user:$git_user $gitconfig_path")
    live_command_output "" "Installing git" "${commands_to_run[@]}"

    local commands_to_run=()
    ssh_key_path="$home_path/.ssh/id_ed25519"
    if [[ -f "$ssh_key_path" ]]; then
        rm -rf $ssh_key_path
    fi

    commands_to_run+=("ssh-keygen -t ed25519 -C \"$gitemail\" -f \"$ssh_key_path\" -N \"$sshpass\" && chown -R $git_user:$git_user $home_path/.ssh && eval \"\$(ssh-agent -s)\" && ssh-add \"$ssh_key_path\"")
    export TARGET_USER="$git_user"
    live_command_output "sysuser" "Creating ssh keys" "${commands_to_run[@]}"

    pause_script "" "Done creating SSH key.\n\nPlease add the following text to your GitHub account to gain push access and access to private repos:\n\n$(cat \"${ssh_key_path}.pub\")"
    continue_script 2 "Git" "Git Setup complete!"
}
