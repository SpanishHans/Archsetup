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

configure_chezmoi()
{
    read -p 'What user to configure chezmoi for?: ' -r username
    while [ -z "$username" ]; do
        output "Error: You need to enter a user."
        read -p 'What user to configure chezmoi for?: ' -r username
    done
    
    read -p "Provide the Git repository URL for ChezMoi: " chezmoi_repo
    while [ -z "$chezmoi_repo" ]; do
        echo "Error: You need to enter a valid Git repository URL."
        exit 1
    done
    
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S chezmoi")

    commands_to_run+=("terminal_title 'Done with segment execuption'")
    live_command_output "" "${commands_to_run[@]}"

    # CHECK THIS ON DOCUMENTATION. HAS TO BE STARTED ON USER HOME.
    sudo -u "$username" chezmoi init "$chezmoi_repo"

    output "Chezmoi Setup complete for user $username!"
    pause_script
}


configure_asdf()
{
    read -p 'What user to add asdf for?: ' -r username
    while [ -z "$username" ]; do
        output "Error: You need to enter a user."
        read -p 'What user to add asdf for?: ' -r username
    done

    commands_to_run=()
    commands_to_run+=("git clone https://github.com/asdf-vm/asdf.git /home/$username/.asdf")
    commands_to_run+=("chown -R $username:$username /home/$username/.asdf")
    commands_to_run+=(
        "if ! grep -Fxq '. \"\$HOME/.asdf/asdf.sh\"' /home/$username/.zshrc; then
            echo '' >> /home/$username/.zshrc
            echo '. \"\$HOME/.asdf/asdf.sh\"' >> /home/$username/.zshrc
            echo 'fpath=(\${ASDF_DIR}/completions \$fpath)' >> /home/$username/.zshrc
            echo 'autoload -Uz compinit && compinit' >> /home/$username/.zshrc
        else
            echo \"asdf initialization already present in .zshrc\"
        fi"
    )

    commands_to_run+=("terminal_title 'Done with segment execuption'")
    live_command_output "" "${commands_to_run[@]}"

    output "ASDF Setup complete!"
    pause_script
}

configure_clipboard()
{
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S rofi-wayland wl-clipboard cliphist grim slurp")

    commands_to_run+=("terminal_title 'Done with segment execuption'")
    live_command_output "" "${commands_to_run[@]}"

    output "Clipboard Setup complete!"
    pause_script
}

configure_python()
{
    read -p 'What user to add asdf python for?: ' -r username
    while [ -z "$username" ]; do
        output "Error: You need to enter a user."
        read -p 'What user to add asdf python for?: ' -r username
    done

    commands_to_run=()
    commands_to_run+=("sudo -u $username asdf plugin add python")
    commands_to_run+=("sudo -u $username asdf install python 3.12.3")

    commands_to_run+=("terminal_title 'Done with segment execuption'")
    live_command_output "" "${commands_to_run[@]}"

    output "Python Setup complete!"
    pause_script
}

configure_node()
{
    read -p 'What user to add asdf python for?: ' -r username
    while [ -z "$username" ]; do
        output "Error: You need to enter a user."
        read -p 'What user to add asdf python for?: ' -r username
    done

    commands_to_run=()
    commands_to_run+=("sudo -u $username asdf plugin add nodejs")
    commands_to_run+=("sudo -u $username asdf install node latest")
    commands_to_run+=("sudo -u $username asdf global nodejs latest")

    commands_to_run+=("terminal_title 'Done with segment execuption'")    
    live_command_output "" "${commands_to_run[@]}"

    output "Python Setup complete!"
    pause_script
}

title="Welcome to the tools Installer"
description="This script aids the installation of additional useful tools."

while true; do
    options=(\
        "Configure chezmoi" \
        "Configure asdf" \
        "Configure clipboard" \
        "Configure python" \
        "Configure node" \
        "Back"
    )

    menu_prompt tools_menu_choice tools_menu_choice_status "$title" "$description" "${options[@]}"

    case $tools_menu_choice in
        0) configure_chezmoi;;
        1) configure_asdf;;
        2) configure_clipboard;;
        3) configure_python;;
        4) configure_node;;
        b) exit;;
        *) output "Invalid choice, please try again." ;;
    esac
done
