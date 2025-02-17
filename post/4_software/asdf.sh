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
            'Python         (Installs Python and its dependencies, including pip and virtualenv)'\
            'Node           (Installs Node.js, npm, and related JavaScript development tools)'\
            'Java           (Installs the Java Development Kit (JDK) for Java development)'\
            'Rust           (Installs the Rust programming language, Cargo, and related tools)'\
            'Make           (Installs GCC, Make, and other necessary tools for C development)'\
            'CMake          (Installs CMake, a tool for managing build processes in C/C++)'\
            'Ninja          (Installs Ninja, a fast build system for compiling projects)'\
            '.NET           (Installs .NET SDK for cross-platform application development)'\
            'Neovim         (Installs Neovim, a modern, extensible text editor for developers)'\
            'Chezmoi        (Installs Chezmoi, a dotmanager based on git)'\
            'Starship       (Installs Starship, a prompt for many terminals)'\
            'Glow           (Installs Glow, a markdown reader)'\
            'Back'\
        )

        menu_prompt virt_menu_choice "$title" "$description" "${options[@]}"
        case $virt_menu_choice in
            0)  configure_python "$prompt_username";;
            1)  configure_node "$prompt_username";;
            2)  configure_java "$prompt_username";;
            3)  configure_rust "$prompt_username";;
            4)  configure_make "$prompt_username";;
            5)  configure_cmake "$prompt_username";;
            6)  configure_ninja "$prompt_username";;
            7)  configure_dotnet "$prompt_username";;
            8)  configure_neovim "$prompt_username";;
            9)  configure_chezmoi "$prompt_username";;
            10) configure_starship "$prompt_username";;
            11) configure_glow "$prompt_username";;
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

    if [[ ! -d "/root/.asdf" ]]; then
        commands_to_run+=("mkdir -p /root/.asdf")
    fi

    if [[ ! -d "/opt/asdf" ]]; then
        commands_to_run+=("mkdir -p /opt/asdf")
    fi
    live_command_output "" "" "yes" "Configuring ASDF" "${commands_to_run[@]}"
    
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

    live_command_output "" "" "yes" "Configuring ASDF" "${commands_to_run[@]}"
    continue_script 2 "ASDF Config" "ASDF configuration complete!"
}

configure_python() {
    local user="$1"
    local path="/home/$git_user/.tool-versions"
    local item="python"
    local version="3.12.3"
    

    local commands_to_run=()
    asdf plugin list | grep -q "$item" || commands_to_run+=("asdf plugin add $item")
    asdf list $item | grep -q "$version" || commands_to_run+=("asdf install $item $version")
    
    commands_to_run+=("touch $path")
    commands_to_run+=(
        "cat > $path <<EOF
        $item $version
        EOF"
    )
    commands_to_run+=("chown $user:$user $path")
    
    commands_to_run+=("cp -rf /root/.asdf/* /opt/asdf")
    commands_to_run+=("chmod -R a+rx /opt/asdf")
    commands_to_run+=("chown -R sysadmin:sysadmin /opt/asdf")

    live_command_output "" "" "yes" "Configuring Python from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Python" "Python Setup complete!"
}

configure_node() {
    local user="$1"
    local path="/home/$git_user/.tool-versions"
    local item="nodejs"
    local version="22.14.0"

    local commands_to_run=()
    asdf plugin list | grep -q "$item" || commands_to_run+=("asdf plugin add $item")
    asdf list $item | grep -q "$version" || commands_to_run+=("asdf install $item $version")
    
    commands_to_run+=("touch $path")
    commands_to_run+=(
        "cat > $path <<EOF
        $item $version
        EOF"
    )
    commands_to_run+=("chown $user:$user $path")

    commands_to_run+=("cp -rf /root/.asdf/* /opt/asdf")
    commands_to_run+=("chmod -R a+rx /opt/asdf")
    commands_to_run+=("chown -R sysadmin:sysadmin /opt/asdf")

    live_command_output "" "" "yes" "Configuring Node from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Node" "Node Setup complete!"
}

configure_java() {
    local user="$1"
    local path="/home/$git_user/.tool-versions"
    local item="java"
    local version="latest:adoptopenjdk-23"

    local commands_to_run=()
    asdf plugin list | grep -q "$item" || commands_to_run+=("asdf plugin add $item")
    asdf list $item | grep -q "$version" || commands_to_run+=("asdf install $item $version")
    
    commands_to_run+=("touch $path")
    commands_to_run+=(
        "cat > $path <<EOF
        $item $version
        EOF"
    )
    commands_to_run+=("chown $user:$user $path")

    commands_to_run+=("cp -rf /root/.asdf/* /opt/asdf")
    commands_to_run+=("chmod -R a+rx /opt/asdf")
    commands_to_run+=("chown -R sysadmin:sysadmin /opt/asdf")

    live_command_output "" "" "yes" "Configuring Java from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Java" "Java Setup complete!"
}

configure_rust() {
    local user="$1"
    local path="/home/$git_user/.tool-versions"
    local item="rust"
    local version="1.84.0"

    local commands_to_run=()
    asdf plugin list | grep -q "$item" || commands_to_run+=("asdf plugin add $item")
    asdf list $item | grep -q "$version" || commands_to_run+=("asdf install $item $version")
    
    commands_to_run+=("touch $path")
    commands_to_run+=(
        "cat > $path <<EOF
        $item $version
        EOF"
    )
    commands_to_run+=("chown $user:$user $path")

    commands_to_run+=("cp -rf /root/.asdf/* /opt/asdf")
    commands_to_run+=("chmod -R a+rx /opt/asdf")
    commands_to_run+=("chown -R sysadmin:sysadmin /opt/asdf")

    live_command_output "" "" "yes" "Configuring Rust from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Rust" "Rust Setup complete!"
}

configure_make() {
    local user="$1"
    local path="/home/$git_user/.tool-versions"
    local item="make"
    local version="4.4.1"

    local commands_to_run=()
    asdf plugin list | grep -q "$item" || commands_to_run+=("asdf plugin add $item")
    asdf list $item | grep -q "$version" || commands_to_run+=("asdf install $item $version")
    
    commands_to_run+=("touch $path")
    commands_to_run+=(
        "cat > $path <<EOF
        $item $version
        EOF"
    )
    commands_to_run+=("chown $user:$user $path")

    commands_to_run+=("cp -rf /root/.asdf/* /opt/asdf")
    commands_to_run+=("chmod -R a+rx /opt/asdf")
    commands_to_run+=("chown -R sysadmin:sysadmin /opt/asdf")

    live_command_output "" "" "yes" "Configuring Make from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Make" "Make Setup complete!"
}

configure_cmake() {
    local user="$1"
    local path="/home/$git_user/.tool-versions"
    local item="cmake"
    local version="3.31.4"

    local commands_to_run=()
    asdf plugin list | grep -q "$item" || commands_to_run+=("asdf plugin add $item")
    asdf list $item | grep -q "$version" || commands_to_run+=("asdf install $item $version")
    
    commands_to_run+=("touch $path")
    commands_to_run+=(
        "cat > $path <<EOF
        $item $version
        EOF"
    )
    commands_to_run+=("chown $user:$user $path")

    commands_to_run+=("cp -rf /root/.asdf/* /opt/asdf")
    commands_to_run+=("chmod -R a+rx /opt/asdf")
    commands_to_run+=("chown -R sysadmin:sysadmin /opt/asdf")

    live_command_output "" "" "yes" "Configuring Cmake from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Cmake" "Cmake Setup complete!"
}

configure_ninja() {
    local user="$1"
    local path="/home/$git_user/.tool-versions"
    local item="ninja"
    local version="1.12.0"

    local commands_to_run=()
    asdf plugin list | grep -q "$item" || commands_to_run+=("asdf plugin add $item")
    asdf list $item | grep -q "$version" || commands_to_run+=("asdf install $item $version")
    
    commands_to_run+=("touch $path")
    commands_to_run+=(
        "cat > $path <<EOF
        $item $version
        EOF"
    )
    commands_to_run+=("chown $user:$user $path")
    
    commands_to_run+=("cp -rf /root/.asdf/* /opt/asdf")
    commands_to_run+=("chmod -R a+rx /opt/asdf")
    commands_to_run+=("chown -R sysadmin:sysadmin /opt/asdf")

    live_command_output "" "" "yes" "Configuring Ninja from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Ninja" "Ninja Setup complete!"
}

configure_dotnet() {
    local user="$1"
    local path="/home/$git_user/.tool-versions"
    local item="dotnet"
    local version="9.0.200"

    local commands_to_run=()
    asdf plugin list | grep -q "$item" || commands_to_run+=("asdf plugin add $item")
    asdf list $item | grep -q "$version" || commands_to_run+=("asdf install $item $version")
    
    commands_to_run+=("touch $path")
    commands_to_run+=(
        "cat > $path <<EOF
        $item $version
        EOF"
    )
    commands_to_run+=("chown $user:$user $path")

    commands_to_run+=("cp -rf /root/.asdf/* /opt/asdf")
    commands_to_run+=("chmod -R a+rx /opt/asdf")
    commands_to_run+=("chown -R sysadmin:sysadmin /opt/asdf")

    live_command_output "" "" "yes" "Configuring Dotnet from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Dotnet" "Dotnet Setup complete!"
}

configure_neovim() {
    local user="$1"
    local path="/home/$git_user/.tool-versions"
    local item="neovim"
    local version="stable"

    local commands_to_run=()
    asdf plugin list | grep -q "$item" || commands_to_run+=("asdf plugin add $item")
    asdf list $item | grep -q "$version" || commands_to_run+=("asdf install $item $version")
    
    commands_to_run+=("touch $path")
    commands_to_run+=(
        "cat > $path <<EOF
        $item $version
        EOF"
    )
    commands_to_run+=("chown $user:$user $path")
    
    commands_to_run+=("cp -rf /root/.asdf/* /opt/asdf")
    commands_to_run+=("chmod -R a+rx /opt/asdf")
    commands_to_run+=("chown -R sysadmin:sysadmin /opt/asdf")

    live_command_output "" "" "yes" "Configuring Neovim from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Neovim" "Neovim Setup complete!"
}

configure_chezmoi() {
    local user="$1"
    local path="/home/$git_user/.tool-versions"
    local item="chezmoi"
    local version="2.59.1"

    local commands_to_run=()
    asdf plugin list | grep -q "$item" || commands_to_run+=("asdf plugin add $item")
    asdf list $item | grep -q "$version" || commands_to_run+=("asdf install $item $version")
    
    commands_to_run+=("touch $path")
    commands_to_run+=(
        "cat > $path <<EOF
        $item $version
        EOF"
    )
    commands_to_run+=("chown $user:$user $path")

    commands_to_run+=("cp -rf /root/.asdf/* /opt/asdf")
    commands_to_run+=("chmod -R a+rx /opt/asdf")
    commands_to_run+=("chown -R sysadmin:sysadmin /opt/asdf")

    live_command_output "" "" "yes" "Configuring Chezmoi from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Chezmoi" "Chezmoi Setup complete!"
}

configure_starship() {
    local user="$1"
    local path="/home/$git_user/.tool-versions"
    local item="starship"
    local version="1.22.1"

    local commands_to_run=()
    asdf plugin list | grep -q "$item" || commands_to_run+=("asdf plugin add $item")
    asdf list $item | grep -q "$version" || commands_to_run+=("asdf install $item $version")
    
    commands_to_run+=("touch $path")
    commands_to_run+=(
        "cat > $path <<EOF
        $item $version
        EOF"
    )
    commands_to_run+=("chown $user:$user $path")

    commands_to_run+=("cp -rf /root/.asdf/* /opt/asdf")
    commands_to_run+=("chmod -R a+rx /opt/asdf")
    commands_to_run+=("chown -R sysadmin:sysadmin /opt/asdf")

    live_command_output "" "" "yes" "Configuring Starship from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Starship" "Starship Setup complete!"
}

configure_glow() {
    local user="$1"
    local path="/home/$git_user/.tool-versions"
    local item="glow"
    local version="2.0.0"

    local commands_to_run=()
    asdf plugin list | grep -q "$item" || commands_to_run+=("asdf plugin add $item")
    asdf list $item | grep -q "$version" || commands_to_run+=("asdf install $item $version")
    
    commands_to_run+=("touch $path")
    commands_to_run+=(
        "cat > $path <<EOF
        $item $version
        EOF"
    )
    commands_to_run+=("chown $user:$user $path")
    
    commands_to_run+=("cp -rf /root/.asdf/* /opt/asdf")
    commands_to_run+=("chmod -R a+rx /opt/asdf")
    commands_to_run+=("chown -R sysadmin:sysadmin /opt/asdf")

    live_command_output "" "" "yes" "Configuring Glow from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Glow" "Glow Setup complete!"
}
