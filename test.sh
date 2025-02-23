# Ensure user input is valid and prevent injection
validate_user() {
    local user="$1"
    if ! id "$user" &>/dev/null; then
        echo "Error: Invalid user '$user'." >&2
        exit 1
    fi
}

# Safely modify sudoers using visudo
add_pacman_nopass() {
    local user="$1"
    validate_user "$user"

    if ! sudo grep -q "^$user ALL=(ALL) NOPASSWD: /usr/bin/pacman" /etc/sudoers; then
        echo "$user ALL=(ALL) NOPASSWD: /usr/bin/pacman" | sudo EDITOR='tee -a' visudo >/dev/null
    fi
}

remove_pacman_nopass() {
    local user="$1"
    validate_user "$user"

    sudo sed -i "/^$user ALL=(ALL) NOPASSWD: \/usr\/bin\/pacman$/d" /etc/sudoers
}

# Execute command securely
execute_command() {
    local cmd="$1"
    local run_user="$user"

    # Switch user if command contains 'makepkg'
    if [[ "$cmd" == *"makepkg"* ]]; then
        run_user="sysadmin"
        add_pacman_nopass "$run_user"
    fi

    validate_user "$run_user"

    # Log setup
    local combined_log="/tmp/$(basename "$0")_$(date +%Y_%m_%d_%H_%M_%S).log"

    echo "Running: $cmd" | tee -a "$combined_log"

    if [ "$run_user" = "root" ]; then
        eval "$cmd" 2>&1 | tee -a "$combined_log"
    else
        sudo -u "$run_user" bash -c "$cmd" 2>&1 | tee -a "$combined_log"
    fi

    local exit_code=${PIPESTATUS[0]}

    if [[ "$run_user" == "sysadmin" ]]; then
        remove_pacman_nopass "$run_user"
    fi

    return $exit_code
}

cleanup() {
    rm -f "$combined_log"
}

# Handle live output securely
live_command_output() {
    local user="${1:-root}"
    shift
    local commands=("$@")

    trap cleanup EXIT INT TERM

    local exit_code=0

    for cmd in "${commands[@]}"; do
        execute_command "$cmd" || exit_code=$?
        [[ $exit_code -ne 0 ]] && break
    done

    return $exit_code
}

# Example usage
user="youruser"   # Replace with the actual username
live_command_output "$user" "whoami" "echo 'Running secure commands'"
