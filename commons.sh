#!/bin/bash

# Copyright (C) 2021-2024 Thien Tran, Tommaso Chiti
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

check_dialog(){
    if command -v dialog &> /dev/null; then
        USE_DIALOG=true
    else
        USE_DIALOG=false
    fi
    export USE_DIALOG
}

check_internet() {
    
    continue_script 2 "Testing internet connection" "A test for internet connection will now start."
    ping -c 3 -q google.com
    export HAS_INTERNET=true
    
}

check_live_env(){
    if [ -d /run/archiso ]; then
        LIVE_ENV=true
    elif [ -f /etc/arch-release ]; then
        LIVE_ENV=false
    else
        echo "Cannot determine if it's a live or installed environment"
        LIVE_ENV=false
    fi
    export LIVE_ENV
}

screen_height=$(tput lines)
screen_width=$(tput cols)
half_height=$((screen_height * 50 / 100))
half_width=$((screen_width * 50 / 100)) 
full_height=$((screen_height * 80 / 100))
full_width=$((screen_width * 80 / 100)) 

output() {
    printf '\e[1;31m%s\e[m\n' "$*"
}

terminal_title() {
    local msg_title="${1:-Default}"
    local wrapped_title=$(echo "$msg_title" | fold -s -w 100)
    local length=$(echo "$wrapped_title" | awk 'BEGIN { max = 0 } { if (length($0) > max) max = length($0) } END { print max }')
    local border=$(printf '%*s' $((length + 8)) '' | tr ' ' '=')

    echo -e "$border"
    echo -e ">>> $wrapped_title <<<"
    echo -e "$border"
}

pause_script() {
    local msg_title="${1:-Default}"
    local msg_text="${2:-Default}"
    local title=$(echo -e "$msg_title")
    local message=$(echo -e "$msg_text")

    dialog \
        --ok-label "Ok" \
        --backtitle "$title" \
        --title "$title" \
        --msgbox "$message" \
        $half_height $half_width 2>&1 >/dev/tty
    exit_code=$?
    case $exit_code in
        0)  return;;
        1)  exit;;
    esac
}

continue_script() {
    local time_sleep="$1"
    local msg_title="${2:-Default}"
    local msg_text="${3:-Default}"
    local title=$(echo -e "$msg_title")
    local message=$(echo -e "$msg_text")

    dialog \
        --ok-label "Ok" \
        --backtitle "$title" \
        --title "$title" \
        --infobox "$message" \
        $half_height $half_width 2>&1 >/dev/tty
    exit_code=$?
    sleep "$time_sleep"
    case $exit_code in
        0)  return;;
        1)  exit;;
    esac
}

output_error() {
        local cmd="$1"
        local exit_code="$2"
               
        local wrapped_cmd=$(echo "$cmd" | fold -s -w 100)

        if [ "$exit_code" -eq 0 ]; then
            echo -e "\
================================================\n\
>>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\n\
================================================\n\n" >> "$combined_log"
        else
            echo -e "\
============================================================\n\
>>> CRITICAL ERROR: COMMAND EXECUTION FAILED! <<<\n\
------------------------------------------------------------\n\
Exit Code: $exit_code\n\
Failed Command: $wrapped_cmd\n\
===========================================================\n\n" >> "$combined_log"
        fi
    }

scroll_window_output() {
    local choice="$1"
    local prompt="$2"
    local file="$3"
    local temp_file

    temp_file=$(mktemp) || { echo "Failed to create temp file"; return 1; }

    echo -e "$prompt\n\n$(cat "$file")" > "$temp_file"

    dialog \
        --backtitle "Viewing $file" \
        --title "$file on logs viewer" \
        --ok-label "Ok, Continue" \
        --extra-button \
        --extra-label "Cancel" \
        --textbox "$temp_file" \
        $full_height $full_width
    local exit_status=$?
    eval "$choice=\"$exit_status\""
    rm -f "$temp_file"
}

live_command_output() {
    local context="$1"
    shift 1
    local commands=("$@")
    local script_name=$(basename "$(realpath "$0")")
    local combined_log="/tmp/${script_name}_$(date +%Y_%m_%d_%H_%M_%S).log"
    local exit_code=0
    
    if ! id "installer" &>/dev/null; then
        useradd -m -G wheel -s /bin/bash installer
        echo "installer ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/installer
    fi

    cleanup() {
        rm -f "$combined_log"
    }
    trap cleanup EXIT

    execute_command() {
        local cmd="$1"
        {
            terminal_title "Running: $cmd" >> "$combined_log"
            
            if [[ "$cmd" =~ makepkg ]]; then
                sudo -u installer bash -c "$cmd" >> "$combined_log" 2>&1

            elif [[ "$cmd" =~ ssh-keygen || "$cmd" =~ ssh-agent || "$cmd" =~ ssh-add ]]; then
                if [[ -n "$TARGET_USER" ]]; then
                    sudo -u "$TARGET_USER" bash -c "$cmd" >> "$combined_log" 2>&1
                else
                    pause_script "Error: TARGET_USER is not set" "Please set TARGET_USER before running SSH commands."
                    return 1
                fi

            else
                eval "$cmd" >> "$combined_log" 2>&1
            fi
    
            exit_code=$?
            output_error "$cmd" "$exit_code"
        }
        return $exit_code
    }


    {
        for cmd in "${commands[@]}"; do
            execute_command "$cmd" || { 
                scroll_window_output return_value "$(terminal_title "$script_name Error, the logs are:")" "$combined_log"
                if [ $return_value -eq 3 ]; then
                    continue_script 2 "You decided to exit" "Script exited execution. Bye."
                    exit 1
                fi
                exit_code=$?
                sleep 2
                killall dialog
                break
            }
        done

        if [ $exit_code -eq 0 ]; then
            terminal_title "Done, continuing to next step!" >> "$combined_log"
            terminal_title "read the logs for this operation on $combined_log" >> "$combined_log"
            sleep 3
            killall dialog
            return 0  # Success
        else
            return 1  # Failure
        fi
    } &

    tail -f "$combined_log" | dialog \
        --backtitle "$script_name on live viewer" \
        --title "$title" \
        --programbox "" \
        "$full_height" "$full_width" 2>&1 >/dev/tty &

    dialog_pid=$!
    wait "$dialog_pid"
}

input_text() {
    local choice="$1"
    local msg_title="${2:-Default}"
    local msg_text="${3:-Default}"
    local msg_prompt="${4:-Default}"
    local title=$(echo -e "$msg_title")
    local message=$(echo -e "$msg_text")
    local prompt=$(echo -e "$msg_prompt")
    local dialog_output
    local console_output
    local exit_code=0
    local fulltext="$message
    
$prompt"

    dialog_output=$(dialog \
        --backtitle "$title" \
        --title "$title" \
        --ok-label "Continue" \
        --inputbox "$fulltext" \
        $half_height $half_width 2>&1 >/dev/tty)
    exit_code=$?
    eval "$choice=\"$dialog_output\""
    return $exit_code
}

input_pass() {
    local choice="$1"
    local msg_title="${2:-Default}"
    local msg_text="${3:-Default}"
    local msg_prompt="${4:-Default}"
    local title=$(echo -e "$msg_title")
    local message=$(echo -e "$msg_text")
    local prompt=$(echo -e "$msg_prompt")
    local dialog_output
    local console_output
    local exit_code=0
    local fulltext="$message
    
$prompt"

    dialog_output=$(dialog \
        --backtitle "$title" \
        --title "$title" \
        --ok-label "Continue" \
        --insecure \
        --passwordbox "$fulltext" \
        $half_height $half_width 2>&1 >/dev/tty)
    exit_code=$?
    eval "$choice=\"$dialog_output\""
    return $exit_code
}

ensure_same_pass() {
    local user="$1"
    local pass="$2"
    local pass1 pass2
    local msg_title="Password validation for: $user"
    
    while true; do
        local msg_text="Please enter your password."
        local msg_prompt="Enter your password"
        input_pass pass1 "$msg_title" "$msg_text" "$msg_prompt"
        
        local msg_text="Please confirm your password."
        local msg_prompt="Confirm your password"
        input_pass pass2 "$msg_title" "$msg_text" "$msg_prompt"
        
        if [ "$pass1" != "$pass2" ]; then
            continue_script 2 "Passwords don't match" "Passwords do not match. Please try again."
        else
            break
        fi
    done
    eval "$pass=\"$pass1\""
    return 0
}

menu_prompt() {
    local choice="$1"
    local msg_title="${2:-Default}"
    local msg_text="${3:-Default}"
    shift 3
    local options=("$@")
    local title=$(echo -e "$msg_title")
    local description=$(echo -e "$msg_text")
    local menu_items=()
    
    for i in "${!options[@]}"; do
        if [[ "${options[i]}" == "Continue" ]]; then
            menu_items+=("c" "${options[i]}")
        elif [[ "${options[i]}" == "Exit" ]]; then
            menu_items+=("e" "${options[i]}")
        elif [[ "${options[i]}" == "Back" ]]; then
            menu_items+=("b" "${options[i]}")
        else
            menu_items+=($((i)) "${options[i]}")
        fi
    done

    dialog_output=$(dialog \
        --backtitle "$title" \
        --title "$title" \
        --ok-label "Select" \
        --menu "$description" \
        $full_height $full_width 15 "${menu_items[@]}" 2>&1 >/dev/tty)
    exit_code=$?
    eval "$choice=\"$dialog_output\""

    return $exit_code

}

multiselect_prompt() {
    local choices="$1"
    local -n options="$2"
    local msg_title="${3:-Default}"
    local msg_text="${4:-Default}"
    local title=$(echo -e "$msg_title")
    local description=$(echo -e "$msg_text \n\nUse SPACE to select/deselect options and OK when finished.")

    dialog_output=$(dialog \
        --backtitle "$title" \
        --title "$title" \
        --checklist "$description" \
        $full_height $full_width 15 "${options[@]}" 2>&1 >/dev/tty)
    exit_code=$?
    
    IFS=$' ' read -r -a choices_array <<< "$dialog_output"
        
    eval "$choices=(${choices_array[@]})"
    return $exit_code
}
