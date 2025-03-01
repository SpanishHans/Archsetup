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
source ./post/4_software/aur.sh

asdf_menu () {
    local title='Programming Language Installation with ASDF'
    local description="This script helps you easily install and manage programming languages using the ASDF version manager."
    install_asdf
    pick_user \
        langs_username \
        "User to set up ASDF for" \
        "Please enter the user who shall get ASDF: "
    configure_asdf "$langs_username"

    pick_user \
        prompt_username \
        "User to setp ASDF program for" \
        "Install ASDF software for a given user. Please select the user who shall receive software: "

    while true; do
        local options=(\
            'Python             (Installs Python and its dependencies, including pip and virtualenv)' \
            'Node               (Installs Node.js, npm, and related JavaScript development tools)' \
            'Java               (Installs the Java Development Kit (JDK) for Java development)' \
            'Rust               (Installs the Rust programming language, Cargo, and related tools)' \
            'Make               (Installs GCC, Make, and other necessary tools for C development)' \
            'CMake              (Installs CMake, a tool for managing build processes in C/C++)' \
            'Ninja              (Installs Ninja, a fast build system for compiling projects)' \
            '.NET               (Installs .NET SDK for cross-platform application development)' \
            'Neovim             (Installs Neovim, a modern, extensible text editor for developers)' \
            'Chezmoi            (Installs Chezmoi, a dotmanager based on git)' \
            'Starship           (Installs Starship, a prompt for many terminals)' \
            'Glow               (Installs Glow, a markdown reader)' \
            'Install all        (Install all the above)' \
            'Back' \
        )

        menu_prompt virt_menu_choice "$title" "$description" "${options[@]}"
        case $virt_menu_choice in
            0)  configure_python;;
            1)  configure_node;;
            2)  configure_java;;
            3)  configure_rust;;
            4)  configure_make;;
            5)  configure_cmake;;
            6)  configure_ninja;;
            7)  configure_dotnet;;
            8)  configure_neovim;;
            9)  configure_chezmoi;;
            10) configure_starship;;
            11) configure_glow;;
            12) install_all_asdf;;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}

install_asdf() {
    install_aur_package "https://aur.archlinux.org/asdf-vm.git"
}

configure_asdf() {
    local user="$1"
    local shell_path="$(getent passwd "$user" | cut -d: -f7)"
    local commands_to_run=()

    if [[ ! -d "/root/.asdf" ]]; then
        commands_to_run+=("mkdir -p /root/.asdf")
    fi

    if [[ ! -d "/opt/asdf" ]]; then
        commands_to_run+=("mkdir -p /opt/asdf")
    fi

    if [[ ! -f "/home/$user/.tool-versions" ]]; then
        commands_to_run+=("touch /home/$user/.tool-versions")
        commands_to_run+=("chown $user:$user /home/$user/.tool-versions")
    fi

    live_command_output  "Configuring ASDF" "${commands_to_run[@]}"
    
    local commands_to_run=()
    case "$shell_path" in
        "/bin/bash" | "/usr/bin/bash")
            local commands_to_run=()
            commands_to_run+=(
                "if ! grep -Fxq 'export ASDF_DATA_DIR=/opt/asdf' /home/$user/.bash_profile; then
                    echo 'export ASDF_DATA_DIR=/opt/asdf' >> /home/$user/.bash_profile
                fi"
            )
            commands_to_run+=(
                "if ! grep -Fxq 'export PATH="\${ASDF_DATA_DIR:-\$HOME/.asdf}/shims:\$PATH"' /home/$user/.bash_profile; then
                    echo 'export PATH="\${ASDF_DATA_DIR:-\$HOME/.asdf}/shims:\$PATH"' >> /home/$user/.bash_profile
                fi"
            )
            commands_to_run+=(
                "if ! grep -Fxq '. <(asdf completion bash)' /home/$user/.bashrc; then
                    echo '. <(asdf completion bash)' >> /home/$user/.bashrc
                fi"
            )
            ;;
        "/bin/zsh" | "/usr/bin/zsh")
            local commands_to_run=()
            local ASDF_DATA_DIR="\$ASDF_DATA_DIR"
            local HOME="\$HOME"
            local PATH="\$PATH"
            commands_to_run+=(
                "if ! grep -Fxq 'export ASDF_DATA_DIR=/opt/asdf' /home/$user/.zshrc; then
                    echo 'export ASDF_DATA_DIR=/opt/asdf' >> /home/$user/.zshrc
                fi"
            )
            commands_to_run+=(
                "if ! grep -Fxq 'export PATH="\${ASDF_DATA_DIR:-\$HOME/.asdf}/shims:\$PATH"' /home/$user/.zshrc; then
                    echo 'export PATH="\${ASDF_DATA_DIR:-\$HOME/.asdf}/shims:\$PATH"' >> /home/$user/.zshrc
                fi"
            )
            commands_to_run+=(
                "mkdir -p "/opt/asdf/completions""
            )
            commands_to_run+=(
                "asdf completion zsh > "/opt/asdf/completions/_asdf""
            )
            commands_to_run+=(
                "if ! grep -Fxq 'fpath=(\${ASDF_DATA_DIR:-\$HOME/.asdf}/completions \$fpath)' /home/$user/.zshrc; then
                    echo 'fpath=(\${ASDF_DATA_DIR:-\$HOME/.asdf}/completions \$fpath)' >> /home/$user/.zshrc
                    echo 'autoload -Uz compinit && compinit' >> /home/$user/.zshrc
                fi"
            )
            ;;
        "/bin/fish" | "/usr/bin/fish")
            local commands_to_run=()
            commands_to_run+=(
                "if ! grep -Fxq 'set -gx --prepend ASDF_DATA_DIR "/opt/asdf"' /home/$user/.config/fish/config.fish; then
                    echo 'set -gx --prepend ASDF_DATA_DIR "/opt/asdf"' >> /home/$user/.config/fish/config.fish
                fi"
            )
            commands_to_run+=(
                "if ! grep -Fxq 'if test -z \$ASDF_DATA_DIR' /home/$user/.config/fish/config.fish; then
                    echo 'if test -z \$ASDF_DATA_DIR' >> /home/$user/.config/fish/config.fish
                    echo '    set _asdf_shims "\$HOME/.asdf/shims"' >> /home/$user/.config/fish/config.fish
                    echo 'else' >> /home/$user/.config/fish/config.fish
                    echo '    set _asdf_shims "\$ASDF_DATA_DIR/shims"' >> /home/$user/.config/fish/config.fish
                    echo 'end' >> /home/$user/.config/fish/config.fish
                    echo 'if not contains \$_asdf_shims \$PATH' >> /home/$user/.config/fish/config.fish
                    echo '    set -gx --prepend PATH \$_asdf_shims' >> /home/$user/.config/fish/config.fish
                    echo 'end' >> /home/$user/.config/fish/config.fish
                    echo 'set --erase _asdf_shims' >> /home/$user/.config/fish/config.fish
                fi"
            )
            commands_to_run+=(
                "asdf completion fish > /home/$user/.config/fish/completions/asdf.fish"
            )
            ;;
        "/bin/elvish" | "/usr/bin/elvish")
            local commands_to_run=()
            commands_to_run+=(
                "if ! grep -Fxq 'var asdf_data_dir = \"/opt/asdf\"' /home/$user/.config/elvish/rc.elv; then
                    echo 'var asdf_data_dir = ~'/.asdf'' >> /home/$user/.config/elvish/rc.elv
                    echo 'if (and (has-env ASDF_DATA_DIR) (!=s \$E:ASDF_DATA_DIR '')) {' >> /home/$user/.config/elvish/rc.elv
                    echo '  set asdf_data_dir = \$E:ASDF_DATA_DIR' >> /home/$user/.config/elvish/rc.elv
                    echo '}' >> /home/$user/.config/elvish/rc.elv
                    echo 'if (not (has-value \$paths \$asdf_data_dir'/shims')) {' >> /home/$user/.config/elvish/rc.elv
                    echo '  set paths = [\$path $@paths]' >> /home/$user/.config/elvish/rc.elv
                    echo '}' >> /home/$user/.config/elvish/rc.elv
                fi"
            )
            commands_to_run+=(
                "asdf completion elvish >> /home/$user/.config/elvish/rc.elv"
            )
            commands_to_run+=(
                "echo "\n"'set edit:completion:arg-completer[asdf] = \$_asdf:arg-completer~' >> /home/$user/.config/elvish/rc.elv"
            )
            ;;
        "/bin/nu" | "/usr/bin/nu")
            local commands_to_run=()
            commands_to_run+=(
                "if ! grep -Fxq '\$env.ASDF_DATA_DIR = \"/opt/asdf\"' /home/$user/.config/nushell/config.nu; then
                    echo '\$env.ASDF_DATA_DIR = \"/opt/asdf\"' >> /home/$user/.config/nushell/config.nu
                fi"
            )
            commands_to_run+=(
                "if ! grep -Fxq 'let shims_dir = (' /home/$user/.config/nushell/config.nu; then
                    echo 'let shims_dir = (' >> /home/$user/.config/nushell/config.nu
                    echo '  if ( \$env | get --ignore-errors ASDF_DATA_DIR | is-empty ) {' >> /home/$user/.config/nushell/config.nu
                    echo '    \$env.HOME | path join '.asdf'' >> /home/$user/.config/nushell/config.nu
                    echo '  } else {' >> /home/$user/.config/nushell/config.nu
                    echo '    \$env.ASDF_DATA_DIR' >> /home/$user/.config/nushell/config.nu
                    echo '  } | path join 'shims'' >> /home/$user/.config/nushell/config.nu
                    echo ')' >> /home/$user/.config/nushell/config.nu
                    echo '\$env.PATH = ( \$env.PATH | split row (char esep) | where { |p| \$p != \$shims_dir } | prepend \$shims_dir )' >> /home/$user/.config/nushell/config.nu
                fi"
            )
            commands_to_run+=(
                "mkdir /opt/asdf/completions"
            )
            commands_to_run+=(
                "asdf completion nushell | save /opt/asdf/completions/nushell.nu"
            )
            commands_to_run+=(
                "if ! grep -Fxq 'let asdf_data_dir = (' /home/$user/.config/nushell/config.nu; then
                    echo 'let asdf_data_dir = (' >> /home/$user/.config/nushell/config.nu
                    echo '  if ( \$env | get --ignore-errors ASDF_DATA_DIR | is-empty ) {' >> /home/$user/.config/nushell/config.nu
                    echo '    \$env.HOME | path join '.asdf'' >> /home/$user/.config/nushell/config.nu
                    echo '  } else {' >> /home/$user/.config/nushell/config.nu
                    echo '    \$env.ASDF_DATA_DIR' >> /home/$user/.config/nushell/config.nu
                    echo '  }' >> /home/$user/.config/nushell/config.nu
                    echo ')' >> /home/$user/.config/nushell/config.nu
                    echo '. "\$asdf_data_dir/completions/nushell.nu"' >> /home/$user/.config/nushell/config.nu
                fi"
            )
            ;;
        *)
            continue_script 2 "asdf not available" "asdf is not supported for this shell"
            return
            ;;
    esac

    live_command_output  "Configuring ASDF" "${commands_to_run[@]}"
    continue_script 2 "ASDF Config" "ASDF configuration complete!"
}

install_with_asdf() {
    local user="$1"
    local item="$2"
    local version="$3"

    check_asdf_package "$user" "$item" "$version"
}

check_asdf_package() {
    local user="$1"
    local item="$2"
    local version="$3"

    if asdf list "$item" | grep -q "$version"; then
        continue_script 2 "$item already installed" "$item is already installed."
    else
        install_asdf_package "$user" "$item" "$version"
    fi
}

install_asdf_package() {
    local user="$1"
    local item="$2"
    local version="$3"
    local path="/home/$user/.tool-versions"
    local commands_to_run=()

    asdf plugin list | grep -q "$item" || commands_to_run+=("asdf plugin add $item")
    asdf list $item | grep -q "$version" || commands_to_run+=("asdf install $item $version")

    commands_to_run+=(
        "if ! grep -Fxq '$item $version' $path; then
            echo '$item $version' >> $path
        fi")
    asdf set $item $version
    
    commands_to_run+=("cp -rf /root/.asdf/* /opt/asdf")
    commands_to_run+=("chmod -R a+rx /opt/asdf")
    commands_to_run+=("chown -R sysadmin:sysadmin /opt/asdf")
    live_command_output  "Configuring $item from ASDF" "${commands_to_run[@]}"
}

install_all_asdf () {
    configure_python
    configure_node
    configure_java
    configure_rust
    configure_make
    configure_cmake
    configure_ninja
    configure_dotnet
    configure_neovim
    configure_chezmoi
    configure_starship
    configure_glow
    continue_script 2 "Everything" "Everything setup complete!"
}

configure_python() {
    local user="$1"
    local item="python"
    local version="3.12.3"

    install_with_asdf "$user" "$item" "$version"
}

configure_node() {
    local user="$1"
    local item="nodejs"
    local version="22.14.0"

    install_with_asdf "$user" "$item" "$version"
}

configure_java() {
    local user="$1"
    local item="java"
    local version="latest:adoptopenjdk-23"

    install_with_asdf "$user" "$item" "$version"
}

configure_rust() {
    local user="$1"
    local item="rust"
    local version="1.84.0"

    install_with_asdf "$user" "$item" "$version"
}

configure_make() {
    local user="$1"
    local item="make"
    local version="4.4.1"

    install_with_asdf "$user" "$item" "$version"
}

configure_cmake() {
    local user="$1"
    local item="cmake"
    local version="3.31.4"

    install_with_asdf "$user" "$item" "$version"
}

configure_ninja() {
    local user="$1"
    local item="ninja"
    local version="1.12.0"

    install_with_asdf "$user" "$item" "$version"
}

configure_dotnet() {
    local user="$1"
    local item="dotnet"
    local version="9.0.200"

    install_with_asdf "$user" "$item" "$version"
}

configure_neovim() {
    local user="$1"
    local item="neovim"
    local version="stable"

    install_with_asdf "$user" "$item" "$version"
}

configure_chezmoi() {
    local user="$1"
    local item="chezmoi"
    local version="2.59.1"

    install_with_asdf "$user" "$item" "$version"
}

configure_starship() {
    local user="$1"
    local item="starship"
    local version="1.22.1"

    install_with_asdf "$user" "$item" "$version"
}

configure_glow() {
    local user="$1"
    local item="glow"
    local version="2.0.0"

    install_with_asdf "$user" "$item" "$version"
}
