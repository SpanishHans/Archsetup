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

language_menu () {
    local title='Programming Language Installation with ASDF'
    local description="This script helps you easily install and manage programming languages using the ASDF version manager."

    get_users userlist
    input_text\
        langs_username\
        "User to installa asdf and programming language installation and support."\
        "Please enter the user who shall get asdf and programming language installation and support.\n\n$userlist"\
        'What user to add asdf and programming language installation and support for?: '
    configure_asdf "$langs_username"

    while true; do
        local options=(\
            'Python                     (Installs Python and its dependencies)'\
            'Node                       (Installs Node.js and npm for JavaScript development)'\
            'Java                       (Installs the Java Development Kit (JDK) for Java development)'\
            'Rust                       (Installs the Rust programming language and cargo)'\
            'C                          (Installs GCC and necessary tools for C development)'\
            "Back"
        )

        menu_prompt virt_menu_choice "$title" "$description" "${options[@]}"
        case $virt_menu_choice in
            0)  configure_python "$langs_username";;
            1)  configure_node "$langs_username";;
            2)  configure_java "$langs_username";;
            3)  configure_rust "$langs_username";;
            4)  configure_c "$langs_username";;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}

configure_asdf() {
    local asdf_username="$1"
    local build_path="/home/$asdf_username/.asdf"
    local shell_path="$(getent passwd "$term_username" | cut -d: -f7)"

    if ! check_folder_exists "$build_path"; then
        commands_to_run=()
        commands_to_run+=("mkdir -p $build_path")
        commands_to_run+=("git clone $url $build_path")
        commands_to_run+=("chown -R $asdf_username:$asdf_username $build_path")
        live_command_output "" "" "yes" "Cloning asdf" "${commands_to_run[@]}"
    else
        continue_script 2 "asdf folder exists" "asdf repository already exists at $build_path. Skipping clone."
    fi

    case "$shell_path" in
        "/bin/bash")
            commands_to_run=()
            commands_to_run+=(
                "if ! grep -Fxq 'export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"' /home/$asdf_username/.bash_profile; then
                    echo 'export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"' >> /home/$asdf_username/.bash_profile
                else
                    echo \"asdf initialization already present in .bash_profile\"
                fi"
            )
            ;;
        "/bin/zsh")
            commands_to_run=()
            commands_to_run+=(
                "if ! grep -Fxq 'export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"' /home/$asdf_username/.zshrc; then
                    echo 'export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"' >> /home/$asdf_username/.zshrc
                else
                    echo \"asdf initialization already present in .zshrc\"
                fi"
            )
            ;;
        "/bin/fish")
            commands_to_run=()
            commands_to_run+=(
                "if ! grep -Fxq '# ASDF configuration code' /home/$asdf_username/.config/fish/config.fish; then
                    echo '' >> /home/$asdf_username/.config/fish/config.fish
                    echo '# ASDF configuration code' >> /home/$asdf_username/.config/fish/config.fish
                    echo 'if test -z \$ASDF_DATA_DIR' >> /home/$asdf_username/.config/fish/config.fish
                    echo '    set _asdf_shims \"\$HOME/.asdf/shims\"' >> /home/$asdf_username/.config/fish/config.fish
                    echo 'else' >> /home/$asdf_username/.config/fish/config.fish
                    echo '    set _asdf_shims \"\$ASDF_DATA_DIR/shims\"' >> /home/$asdf_username/.config/fish/config.fish
                    echo 'end' >> /home/$asdf_username/.config/fish/config.fish
                    echo '' >> /home/$asdf_username/.config/fish/config.fish
                    echo '# Do not use fish_add_path (added in Fish 3.2) because it' >> /home/$asdf_username/.config/fish/config.fish
                    echo '# potentially changes the order of items in PATH' >> /home/$asdf_username/.config/fish/config.fish
                    echo 'if not contains \$_asdf_shims \$PATH' >> /home/$asdf_username/.config/fish/config.fish
                    echo '    set -gx --prepend PATH \$_asdf_shims' >> /home/$asdf_username/.config/fish/config.fish
                    echo 'end' >> /home/$asdf_username/.config/fish/config.fish
                    echo 'set --erase _asdf_shims' >> /home/$asdf_username/.config/fish/config.fish
                else
                    echo \"ASDF initialization already present in config.fish\"
                fi"
            )
            ;;
        "/bin/elvish")
            commands_to_run=()
            commands_to_run+=(
                "if ! grep -Fxq 'var asdf_data_dir = ~\"/.asdf\"' /home/$asdf_username/.config/elvish/rc.elv; then
                    echo '' >> /home/$asdf_username/.config/elvish/rc.elv
                    echo 'var asdf_data_dir = ~\"/.asdf\"' >> /home/$asdf_username/.config/elvish/rc.elv
                    echo 'if (and (has-env ASDF_DATA_DIR) (!=s \$E:ASDF_DATA_DIR \"\")) {' >> /home/$asdf_username/.config/elvish/rc.elv
                    echo '  set asdf_data_dir = \$E:ASDF_DATA_DIR' >> /home/$asdf_username/.config/elvish/rc.elv
                    echo '}' >> /home/$asdf_username/.config/elvish/rc.elv
                    echo '' >> /home/$asdf_username/.config/elvish/rc.elv
                    echo 'if (not (has-value \$paths \$asdf_data_dir\"/shims\")) {' >> /home/$asdf_username/.config/elvish/rc.elv
                    echo '  set paths = [\$path \$@paths]' >> /home/$asdf_username/.config/elvish/rc.elv
                    echo '}' >> /home/$asdf_username/.config/elvish/rc.elv
                else
                    echo \"ASDF initialization already present in rc.elv\"
                fi"
            )
            ;;
        "/bin/tcsh")
            commands_to_run=()
            commands_to_run+=(
                "if ! grep -Fxq '. \"\$HOME/.asdf/asdf.sh\"' /home/$asdf_username/.zshrc; then
                    echo '' >> /home/$asdf_username/.zshrc
                    echo '. \"\$HOME/.asdf/asdf.sh\"' >> /home/$asdf_username/.zshrc
                    echo 'fpath=(\${ASDF_DIR}/completions \$fpath)' >> /home/$asdf_username/.zshrc
                    echo 'autoload -Uz compinit && compinit' >> /home/$asdf_username/.zshrc
                else
                    echo \"asdf initialization already present in .zshrc\"
                fi"
            )
            ;;
        *)
            continue_script 2 "Starship not available" "Starship is not supported for this shell"
            return
            ;;
    esac
    
    live_command_output "" "" "yes" "Configuring ASDF" "${commands_to_run[@]}"
    continue_script "ASDF" "ASDF Setup complete!"
}

configure_python() {
    local python_user="$1"

    commands_to_run=()
    commands_to_run+=("sudo -u $python_user asdf plugin add python")
    commands_to_run+=("sudo -u $python_user asdf install python 3.12.3")

    live_command_output "" "" "yes" "Configuring python from ASDF" "${commands_to_run[@]}"
    continue_script "Python" "Python Setup complete!"
}

configure_node() {
    local node_user="$1"

    commands_to_run=()
    commands_to_run+=("sudo -u $node_user asdf plugin add nodejs")
    commands_to_run+=("sudo -u $node_user asdf install node latest")

    live_command_output "" "" "yes" "Configuring Node from ASDF" "${commands_to_run[@]}"
    continue_script 2 "Node" "Node Setup complete!"
}

configure_java() {
    local java_user="$1"

    continue_script 2 "Java" "Java Setup complete!"
}

configure_rust() {
    local rust_user="$1"
    continue_script 2 "Rust" "Rust Setup complete!"
}

configure_c() {
    local c_user="$1"
    continue_script 2 "C" "C Setup complete!"
}
