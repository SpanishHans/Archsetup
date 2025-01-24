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
    input_text chezmoi_username chezmoi_username_status "Chezmoi User to setup" "Please enter the user whose chezmoi shall be configured" 'What user to configure chezmoi for?: '
    input_text chezmoi_repo chezmoi_repo_status "Chezmoi repo to setup" "Please enter the repo to sync from/to." "Provide the Git repository URL for ChezMoi: "

    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S chezmoi")
    commands_to_run+=("sudo -u \"$chezmoi_username\" bash -c \"chezmoi init $chezmoi_repo\"")
    
    live_command_output "" "${commands_to_run[@]}"
    pause_script "Chezmoi" "Chezmoi Setup complete for user $username!"
}


configure_asdf()
{
    input_text chezmoi_repo chezmoi_repo_status "User asdf" "Please enter the user whose asdf shall be configured" 'What user to add asdf for?: '

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
    
    live_command_output "" "${commands_to_run[@]}"
    pause_script "ASDF" "ASDF Setup complete!"
}

configure_clipboard()
{
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S wl-clipboard cliphist grim slurp")

    
    live_command_output "" "${commands_to_run[@]}"
    pause_script "Clipboard" "Clipboard Setup complete!"
}

configure_python() {

    input_text python_user python_user_status "User asdf python" "Please enter the user whose asdf python shall be configured" 'What user to add asdf python for?: '

    commands_to_run=()
    commands_to_run+=("sudo -u $python_user asdf plugin add python")
    commands_to_run+=("sudo -u $python_user asdf install python 3.12.3")

    
    live_command_output "" "${commands_to_run[@]}"
    pause_script "Python" "Python Setup complete!"
}

configure_node()
{
    input_text node_user node_user_status "User asdf node" "Please enter the user whose asdf node shall be configured" 'What user to add asdf node for?: '

    commands_to_run=()
    commands_to_run+=("sudo -u $node_user asdf plugin add nodejs")
    commands_to_run+=("sudo -u $node_user asdf install node latest")
    commands_to_run+=("sudo -u $node_user asdf global nodejs latest")

        
    live_command_output "" "${commands_to_run[@]}"
    pause_script "Node" "Node Setup complete!"
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
