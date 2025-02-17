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
        EOF"
    )
    commands_to_run+=("chown $git_user:$git_user $gitconfig_path")
    live_command_output "" "" "yes" "Installing git" "${commands_to_run[@]}"

    local commands_to_run=()
    ssh_key_path="$home_path/.ssh/id_ed25519"
    if [[ -f "$ssh_key_path" ]]; then
        commands_to_run+=("rm -rf $ssh_key_path")
    fi

    commands_to_run+=("ssh-keygen -t ed25519 -C \"$gitemail\" -f \"$ssh_key_path\" -N \"$sshpass\"")
    commands_to_run+=("chown -R $git_user:$git_user $home_path/.ssh")
    live_command_output "$git_user" "$pass" "yes" "Installing git" "${commands_to_run[@]}"


    pause_script "" "Done creating SSH key.

Now run the following commands:

1. Start the SSH agent:
   ssh-agent -s

2. Add your new key to the agent:
   ssh-add \"$ssh_key_path\"

Please add the following text to your GitHub account to gain push access and access to private repos:

$(cat \"${ssh_key_path}.pub\")
"
    continue_script 1 "Git" "Git Setup complete!"
}
