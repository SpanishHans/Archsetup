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
    local user="$USER_WITH_SUDO_USER"
    local pass="$USER_WITH_SUDO_PASS"
    install_asdf "$user" "$pass"

    get_users userlist
    input_text\
        langs_username\
        "User to installa asdf and programming language installation and support."\
        "Please enter the user who shall get asdf and programming language installation and support.\n\n$userlist"\
        'What user to add asdf and programming language installation and support for?: '
    configure_asdf "$langs_username"

    while true; do
        local options=(\
            'Python         (Installs Python and its dependencies, including pip and virtualenv)'\
            'Node           (Installs Node.js, npm, and related JavaScript development tools)'\
            'Java           (Installs the Java Development Kit (JDK) for Java development)'\
            'Rust           (Installs the Rust programming language, Cargo, and related tools)'\
            'C              (Installs GCC, Make, and other necessary tools for C development)'\
            'CMake          (Installs CMake, a tool for managing build processes in C/C++)'\
            'Ninja          (Installs Ninja, a fast build system for compiling projects)'\
            '.NET           (Installs .NET SDK for cross-platform application development)'\
            'Neovim         (Installs Neovim, a modern, extensible text editor for developers)'\
            'Glow           (Installs Glow, a markdown reader)'\
            'Back           (Return to the previous menu)'\
        )

        menu_prompt virt_menu_choice "$title" "$description" "${options[@]}"
        case $virt_menu_choice in
            0)  configure_python "$langs_username";;
            1)  configure_node "$langs_username";;
            2)  configure_java "$langs_username";;
            3)  configure_rust "$langs_username";;
            4)  configure_make "$langs_username";;
            5)  configure_cmake "$langs_username";;
            6)  configure_ninja "$langs_username";;
            7)  configure_dotnet "$langs_username";;
            8)  configure_neovim "$langs_username";;
            9)  configure_chezmoi "$langs_username";;
            10) configure_starship "$langs_username";;
            11) configure_glow "$langs_username";;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}

install_asdf() {
    local user="$1"
    local pass="$2"

    if ! check_command_exists "asdf"; then
        install_aur_package "$user" "$pass" "https://aur.archlinux.org/asdf-vm.git"
    else
        continue_script 2 "ASDF installed" "ASDF is already installed."
    fi
}

configure_asdf() {
    local user="$1"
    local shell_path="$(getent passwd "$user" | cut -d: -f7)"
    local commands_to_run=()

    if check_folder_exists "/home/$user/.asdf"; then
        commands_to_run+=("rm -rf /home/$user/.asdf")
        continue_script 2 "ASDF folder exists" "ASDF already exists at /home/$user/.asdf. Removing."
    fi

    case "$shell_path" in
        "/bin/bash" | "/usr/bin/bash")
            local commands_to_run=()
            commands_to_run+=(
                "if ! grep -Fxq 'export PATH="${ASDF_DATA_DIR:-/home/$user/.asdf}/shims:$PATH"' /home/$user/.bash_profile; then
                    echo 'export PATH="${ASDF_DATA_DIR:-/home/$user/.asdf}/shims:$PATH"' >> /home/$user/.bash_profile
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
            commands_to_run+=(
                "if ! grep -Fxq 'export PATH="${ASDF_DATA_DIR:-/home/$user/.asdf}/shims:$PATH"' /home/$user/.zshrc; then
                    echo 'export PATH="${ASDF_DATA_DIR:-/home/$user/.asdf}/shims:$PATH"' >> /home/$user/.zshrc
                fi"
            )
            commands_to_run+=(
                "mkdir -p \"${ASDF_DATA_DIR:-/home/$user/.asdf}/completions\""
            )
            commands_to_run+=(
                "asdf completion zsh > \"${ASDF_DATA_DIR:-/home/$user/.asdf}/completions/_asdf\""
            )
            commands_to_run+=(
                "if ! grep -Fxq 'fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)' /home/$user/.zshrc; then
                    echo 'fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)' >> /home/$user/.zshrc
                    echo 'autoload -Uz compinit && compinit' >> /home/$user/.zshrc
                fi"
            )
            ;;
        "/bin/fish" | "/usr/bin/fish")
            local commands_to_run=()
            commands_to_run+=(
                "if ! grep -Fxq 'if test -z $ASDF_DATA_DIR' /home/$user/.config/fish/config.fish; then
                    echo 'if test -z $ASDF_DATA_DIR' >> /home/$user/.config/fish/config.fish
                    echo '    set _asdf_shims "$HOME/.asdf/shims"' >> /home/$user/.config/fish/config.fish
                    echo 'else' >> /home/$user/.config/fish/config.fish
                    echo '    set _asdf_shims "$ASDF_DATA_DIR/shims"' >> /home/$user/.config/fish/config.fish
                    echo 'end' >> /home/$user/.config/fish/config.fish
                    echo 'if not contains $_asdf_shims $PATH' >> /home/$user/.config/fish/config.fish
                    echo '    set -gx --prepend PATH $_asdf_shims' >> /home/$user/.config/fish/config.fish
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
                "if ! grep -Fxq 'var asdf_data_dir = ~\"/.asdf\"' /home/$user/.config/elvish/rc.elv; then
                    echo 'var asdf_data_dir = ~'/.asdf'' >> /home/$user/.config/elvish/rc.elv
                    echo 'if (and (has-env ASDF_DATA_DIR) (!=s $E:ASDF_DATA_DIR '')) {' >> /home/$user/.config/elvish/rc.elv
                    echo '  set asdf_data_dir = $E:ASDF_DATA_DIR' >> /home/$user/.config/elvish/rc.elv
                    echo '}' >> /home/$user/.config/elvish/rc.elv
                    echo 'if (not (has-value $paths $asdf_data_dir'/shims')) {' >> /home/$user/.config/elvish/rc.elv
                    echo '  set paths = [$path $@paths]' >> /home/$user/.config/elvish/rc.elv
                    echo '}' >> /home/$user/.config/elvish/rc.elv
                fi"
            )
            commands_to_run+=(
                "asdf completion elvish >> /home/$user/.config/elvish/rc.elv"
            )
            commands_to_run+=(
                "echo "\n"'set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~' >> /home/$user/.config/elvish/rc.elv"
            )
            ;;
        "/bin/nu" | "/usr/bin/nu")
            local commands_to_run=()
            commands_to_run+=(
                "if ! grep -Fxq 'let shims_dir = (' /home/$user/.config/nushell/config.nu; then
                    echo 'let shims_dir = (' >> /home/$user/.config/nushell/config.nu
                    echo '  if ( $env | get --ignore-errors ASDF_DATA_DIR | is-empty ) {' >> /home/$user/.config/nushell/config.nu
                    echo '    $env.HOME | path join '.asdf'' >> /home/$user/.config/nushell/config.nu
                    echo '  } else {' >> /home/$user/.config/nushell/config.nu
                    echo '    $env.ASDF_DATA_DIR' >> /home/$user/.config/nushell/config.nu
                    echo '  } | path join 'shims'' >> /home/$user/.config/nushell/config.nu
                    echo ')' >> /home/$user/.config/nushell/config.nu
                    echo '$env.PATH = ( $env.PATH | split row (char esep) | where { |p| $p != $shims_dir } | prepend $shims_dir )' >> /home/$user/.config/nushell/config.nu
                fi"
            )
            commands_to_run+=(
                "mkdir /home/$user/.asdf/completions"
            )
            commands_to_run+=(
                "asdf completion nushell | save /home/$user/.asdf/completions/nushell.nu"
            )
            commands_to_run+=(
                "if ! grep -Fxq 'let asdf_data_dir = (' /home/$user/.config/nushell/config.nu; then
                    echo 'let asdf_data_dir = (' >> /home/$user/.config/nushell/config.nu
                    echo '  if ( $env | get --ignore-errors ASDF_DATA_DIR | is-empty ) {' >> /home/$user/.config/nushell/config.nu
                    echo '    $env.HOME | path join '.asdf'' >> /home/$user/.config/nushell/config.nu
                    echo '  } else {' >> /home/$user/.config/nushell/config.nu
                    echo '    $env.ASDF_DATA_DIR' >> /home/$user/.config/nushell/config.nu
                    echo '  }' >> /home/$user/.config/nushell/config.nu
                    echo ')' >> /home/$user/.config/nushell/config.nu
                    echo '. "$asdf_data_dir/completions/nushell.nu"' >> /home/$user/.config/nushell/config.nu
                fi"
            )
            ;;
        *)
            continue_script 2 "asdf not available" "asdf is not supported for this shell"
            return
            ;;
    esac

    live_command_output "$user" "" "yes" "Configuring ASDF" "${commands_to_run[@]}"
    continue_script 2 "ASDF" "ASDF Setup complete!"
}

configure_python() {
    local user="$1"
    local commands_to_run=()
    commands_to_run+=("asdf plugin add python")
    commands_to_run+=("asdf list all python | column")
    commands_to_run+=("asdf install python 3.12.3")
    commands_to_run+=("asdf set python 3.12.3")

    live_command_output "" "" "yes" "Configuring Python from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Python" "Python Setup complete!"
}

configure_node() {
    local user="$1"
    local commands_to_run=()
    commands_to_run+=("asdf plugin add nodejs")
    commands_to_run+=("asdf list all nodejs | column")
    commands_to_run+=("asdf install nodejs 22.14.0")
    commands_to_run+=("asdf set nodejs 22.14.0")

    live_command_output "" "" "yes" "Configuring Node from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Node" "Node Setup complete!"
}

configure_java() {
    local user="$1"
    local commands_to_run=()
    commands_to_run+=("asdf plugin add java")
    commands_to_run+=("asdf list all java | column")
    commands_to_run+=("asdf install java latest:adoptopenjdk-23")
    commands_to_run+=("asdf set java latest:adoptopenjdk-23")

    live_command_output "" "" "yes" "Configuring Java from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Java" "Java Setup complete!"
}

configure_rust() {
    local user="$1"
    local commands_to_run=()
    commands_to_run+=("asdf plugin add rust")
    commands_to_run+=("asdf list all rust | column")
    commands_to_run+=("asdf install rust 1.84.0")
    commands_to_run+=("asdf set rust 1.84.0")

    live_command_output "" "" "yes" "Configuring Rust from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Rust" "Rust Setup complete!"
}

configure_make() {
    local user="$1"
    local commands_to_run=()
    commands_to_run+=("asdf plugin add make")
    commands_to_run+=("asdf list all make | column")
    commands_to_run+=("asdf install make 4.4.1")
    commands_to_run+=("asdf set make 4.4.1")

    live_command_output "" "" "yes" "Configuring Make from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Make" "Make Setup complete!"
}

configure_cmake() {
    local user="$1"
    local commands_to_run=()
    commands_to_run+=("asdf plugin add cmake")
    commands_to_run+=("asdf list all cmake | column")
    commands_to_run+=("asdf install cmake 3.31.4")
    commands_to_run+=("asdf set cmake 3.31.4")

    live_command_output "" "" "yes" "Configuring Cmake from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Cmake" "Cmake Setup complete!"
}

configure_ninja() {
    local user="$1"
    local commands_to_run=()
    commands_to_run+=("asdf plugin add ninja")
    commands_to_run+=("asdf list all ninja | column")
    commands_to_run+=("asdf install ninja 1.12.0")
    commands_to_run+=("asdf set ninja 1.12.0")

    live_command_output "" "" "yes" "Configuring Ninja from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Ninja" "Ninja Setup complete!"
}

configure_dotnet() {
    local user="$1"
    local commands_to_run=()
    commands_to_run+=("asdf plugin add dotnet")
    commands_to_run+=("asdf list all dotnet | column")
    commands_to_run+=("asdf install dotnet 9.0.200")
    commands_to_run+=("asdf set dotnet 9.0.200")

    live_command_output "" "" "yes" "Configuring Dotnet from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Dotnet" "Dotnet Setup complete!"
}

configure_neovim() {
    local user="$1"
    local commands_to_run=()
    commands_to_run+=("asdf plugin add neovim")
    commands_to_run+=("asdf list all neovim | column")
    commands_to_run+=("asdf install neovim stable")
    commands_to_run+=("asdf set neovim stable")

    live_command_output "" "" "yes" "Configuring Neovim from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Neovim" "Neovim Setup complete!"
}

configure_chezmoi() {
    local user="$1"
    local commands_to_run=()
    commands_to_run+=("asdf plugin add chezmoi")
    commands_to_run+=("asdf list all chezmoi | column")
    commands_to_run+=("asdf install chezmoi 2.59.1")
    commands_to_run+=("asdf set chezmoi 2.59.1")

    live_command_output "" "" "yes" "Configuring Chezmoi from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Chezmoi" "Chezmoi Setup complete!"
}

configure_starship() {
    local user="$1"
    local commands_to_run=()
    commands_to_run+=("asdf plugin add starship")
    commands_to_run+=("asdf list all starship | column")
    commands_to_run+=("asdf install starship 1.22.1")
    commands_to_run+=("asdf set starship 1.22.1")

    live_command_output "" "" "yes" "Configuring Starship from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Starship" "Starship Setup complete!"
}

configure_glow() {
    local user="$1"
    local commands_to_run=()
    commands_to_run+=("asdf plugin add glow")
    commands_to_run+=("asdf list all glow | column")
    commands_to_run+=("asdf install glow 2.0.0")
    commands_to_run+=("asdf set glow 2.0.0")

    live_command_output "" "" "yes" "Configuring Glow from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Glow" "Glow Setup complete!"
}
