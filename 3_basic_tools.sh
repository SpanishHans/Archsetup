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

source ./globals.sh

configure_git() {
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S git")
    commands_to_run+=("echo -e ================================================\n
    >>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\
    ================================================\n'")

    input_text git_user git_user_status "User account" "Please enter the user whose git shall be configured" "What user to configure git for?: "
    input_text gitusername gitusername_status "Github user of $git_user" "Please enter the username in github for $git_user" "Enter Git username: "
    input_text gitemail gitemail_status "Github email of $git_user" "Please enter the email in github for $git_user" "Enter Git email: "

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

    ssh_key_path="$home_path/.ssh/id_ed25519"
    if [ -f "$ssh_key_path" ]; then
        commands_to_run+=("echo 'SSH key already exists at $ssh_key_path.'")
    else
        commands_to_run+=("echo 'Generating SSH key at $ssh_key_path...'")
        commands_to_run+=("mkdir -p $home_path/.ssh")
        commands_to_run+=("ssh-keygen -t ed25519 -C '$gitemail' -f '$ssh_key_path'")
        commands_to_run+=("chown -R $git_user:$git_user $home_path/.ssh")
        commands_to_run+=("chown $git_user:$git_user $gitconfig_path")
        commands_to_run+=("sudo -u $git_user bash -c \"eval \$(ssh-agent -s) && ssh-add '$ssh_key_path'\"")

    fi
    commands_to_run+=("cat $ssh_key_path")
    commands_to_run+=("echo -e ================================================\n
    >>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\
    ================================================\n'")

    live_command_output "" "${commands_to_run[@]}"
    pause_script "" "Git Setup complete!"
}

configure_paru()
{
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S --needed base-devel rustup")
    commands_to_run+=("git clone https://aur.archlinux.org/paru.git /home/sysadmin/.paru")
    commands_to_run+=("chown -R sysadmin:sysadmin /home/sysadmin/.paru")
    commands_to_run+=("sudo -u sysadmin bash -c 'rustup default stable'")
    commands_to_run+=("sudo -u sysadmin bash -i -c 'cd /home/sysadmin/.paru &&  makepkg -si'")
    commands_to_run+=("echo -e ================================================\n
    >>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\
    ================================================\n'")

    live_command_output "" "${commands_to_run[@]}"
    pause_script "" "Paru Setup complete!"
}

configure_snp()
{
    commands_to_run=()
    commands_to_run+=("sudo -u sysadmin bash -c 'paru -S snp [edit: --noconfirm ]'")
    # commands_to_run+=("sudo -u sysadmin bash -i -c 'paru -S snp'")
    commands_to_run+=("echo -e ================================================\n
    >>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\
    ================================================\n'")

    live_command_output "" "${commands_to_run[@]}"
    pause_script "" "Snp Setup complete!"
}

configure_snapper_rollback()
{
    commands_to_run=()
    commands_to_run+=("sudo -u sysadmin bash -c 'paru -S snapper-rollback [edit: --noconfirm ]'")
    # commands_to_run+=("sudo -u sysadmin bash -i -c 'paru -S snapper-rollback'")
    commands_to_run+=("
        if grep -qE '^[#]*mountpoint[[:space:]]*=[[:space:]]*/btrfsroot' /etc/snapper-rollback.conf; then
            sed -i 's|^[#]*mountpoint[[:space:]]*=[[:space:]]*/btrfsroot|mountpoint = /.btrfsroot|' /etc/snapper-rollback.conf
            echo \"mountpoint updated to /.btrfsroot in /etc/snapper-rollback.conf\"
        else
            echo \"mountpoint entry not found in /etc/snapper-rollback.conf\"
        fi")
    commands_to_run+=("echo -e ================================================\n
    >>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\
    ================================================\n'")

    live_command_output "" "${commands_to_run[@]}"
    pause_script "" "Snapper-rollback Setup complete!"
}

configure_terminal() {

    local title="Terminal configurator: pick user"
    local description="This allows you to set up different modes of zsh for a given user.
    Please give me the user whose terminal shall be configured.
    This might break dotfiles for that user!"
    input_text term_username term_username_status "Terminal configuration" "$description" "What user to configure terminal for?: "

    title="Terminal configurator: pick mode"
    description="Please select configuration mode from the menu below."
    while true; do
        options=(\
            "Mode 1: Zsh + Oh My Zsh" \
            "Mode 2: Zsh + Oh My Zsh + Starship" \
        )
        
        menu_prompt terminal_choice terminal_choice_status "$title" "$description" "${options[@]}"
    
        case $terminal_choice in
            1)  commands_to_run+=("pacman --noconfirm -S zsh curl ttf-dejavu-nerd ttf-0xproto-nerd ttf-font-awesome starship")
                commands_to_run+=("chsh -s /bin/zsh $term_username")
                commands_to_run+=("curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/ohmyzsh_install.sh")
                commands_to_run+=("sudo -u $term_username bash /tmp/ohmyzsh_install.sh")
                break;;
            2)  commands_to_run+=("pacman --noconfirm -S zsh curl ttf-dejavu-nerd ttf-0xproto-nerd ttf-font-awesome starship")
                commands_to_run+=("chsh -s /bin/zsh $term_username")
                commands_to_run+=("curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/ohmyzsh_install.sh")
                commands_to_run+=("sudo -u $term_username bash /tmp/ohmyzsh_install.sh")
                commands_to_run+=(
                    "if ! grep -Fxq 'eval \"\$(starship init zsh)\"' /home/$term_username/.zshrc; then
                        echo 'eval \"\$(starship init zsh)\"' >> /home/$term_username/.zshrc
                        echo \"Starship initialization added to .zshrc\"
                    else
                        echo \"Starship initialization already present in .zshrc\"
                    fi"
                )
                commands_to_run+=("mkdir -p /home/$term_username/.config && touch /home/$term_username/.config/starship.toml")
                commands_to_run+=("starship preset gruvbox-rainbow -o /home/$term_username/.config/starship.toml")
                break;;
            0)  exit;;
            *)  output "Invalid choice, please try again.";;
        esac
    done
    
    commands_to_run+=("echo -e ================================================\n
    >>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\
    ================================================\n'")


    live_command_output "" "${commands_to_run[@]}"
    pause_script "" "Terminal Setup complete!"
}

configure_flatpak()
{
    # Initialize arrays for commands
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S flatpak")
    commands_to_run+=("echo -e ================================================\n
    >>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\
    ================================================\n'")


    live_command_output "" "${commands_to_run[@]}"
    pause_script "" "Flatpak Setup complete!"
}

configure_docker()
{
    input_text docker_user docker_user_status "Docker user" "Please enter the user who shall be added to docker group" "What user to add to docker group?: "

    local title="${1:-}"
    local desc="${2:-}"
    local prom="${3:-}"
    local variable="${4:-}"

    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S docker docker-compose && usermod -aG docker $docker_user")
    commands_to_run+=("systemctl enable docker")
    commands_to_run+=("systemctl start --now docker")
    commands_to_run+=("echo -e ================================================\n
    >>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\
    ================================================\n'")


    live_command_output "" "${commands_to_run[@]}"
    pause_script "" "Docker Setup complete!"
}

configure_distrobox()
{
    # Initialize arrays for commands
    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S distrobox")
    commands_to_run+=("echo -e ================================================\n
    >>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\
    ================================================\n'")


    live_command_output "" "${commands_to_run[@]}"
    pause_script "" "Distrobox Setup complete!"
}

titulo="Basic tools installer"

descripcion="This script provides a menu to install some basic arch tools.
Select an option from the menu to proceed."

while true; do
    options=(\
        "Configure git" \
        "Configure paru" \
        "Configure snp" \
        "Configure snapper-rollback" \
        "Configure terminal" \
        "Configure flatpak" \
        "Configure docker" \
        "Configure distrobox" \
    )
    
    menu_prompt menu_choice_3 menu_choice_status_3 "$titulo" "$descripcion" "${options[@]}"

    case $menu_choice_3 in
        1)  configure_git;;
        2)  configure_paru;;
        3)  configure_snp;;
        4)  configure_snapper_rollback;;
        5)  configure_terminal;;
        6)  configure_flatpak;;
        7)  configure_docker;;
        8)  configure_distrobox;;
        0)  exit;;
        *)  pause_script "" "Invalid choice, please try again." ;;
    esac
done