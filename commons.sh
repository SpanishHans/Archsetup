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

check_live_env
check_dialog

screen_height=$(tput lines)
screen_width=$(tput cols)
half_height=$((screen_height * 50 / 100))
half_width=$((screen_width * 50 / 100)) 
full_height=$((screen_height * 80 / 100))
full_width=$((screen_width * 80 / 100)) 

output() {
    printf '\e[1;31m%s\e[m\n' "$*"
}

pause_script() {
    local msg_title="${1:-Default}"
    local msg_text="${2:-Nothing}"
    local title=$(echo -e "$msg_title")
    local message=$(echo -e "$msg_text")

    if [ "$USE_DIALOG" = true ]; then
        dialog --ok-label "Ok" --backtitle "$title" --msgbox "$message" $half_height $half_width 2>&1 >/dev/tty
        exit_code=$?
        case $exit_code in
            0)  return;;
            1)  exit;;
        esac

    fi
}

continue_script() {
    local msg_title="${1:-Default}"
    local msg_text="${2:-Default}"
    local title=$(echo -e "$msg_title")
    local message=$(echo -e "$msg_text")

    if [ "$USE_DIALOG" = true ]; then
        dialog --ok-label "Ok" --backtitle "$title" --infobox "$message" $half_height $half_width 2>&1 >/dev/tty
        exit_code=$?
        sleep 0.7
        case $exit_code in
            0)  return;;
            1)  exit;;
        esac

    fi
}

handle_exit_code() {
    local code="$1"
    local mode="${2:-return}"
    case $code in
        0) $mode ;;
        1) exit ;;
        *) pause_script 'Error' "Unknown exit code: $code" ;;
    esac
}

live_command_output() {
    local user="${1:-root}"
    local context="${2:-Default}"
    shift 2
    local commands=("$@")
    local exit_code=0
    local combined_log=$(mktemp)
    
    output_error() {
        local cmd="$1"
        local err="$2"
        if [ "$exit_code" -eq 0 ]; then
            echo -e "\
================================================\n\
>>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\n\
================================================\n" >> "$combined_log"
        else
            echo -e "\
============================================================\n\
>>> CRITICAL ERROR: COMMAND EXECUTION FAILED! <<<\n\
------------------------------------------------------------\n\
Failed Command: $cmd\n\
Error Message: $err\n\
===========================================================\n" >> "$combined_log"
        fi
    }
    
    execute_command() {
        local cmd="$1"
        local error_msg
        if [ "$user" = "root" ]; then
            $cmd >> "$combined_log" 2>&1  # Capture both stdout and stderr in the same log
            exit_code=$?  # Capture the exit code of the command
        else
            sudo -u "$user" bash -c "$cmd" >> "$combined_log" 2>&1
            exit_code=$?  # Capture the exit code of the command
        fi
        output_error "$cmd" "$exit_code"
    }

    if [ "$USE_DIALOG" = true ]; then
        for cmd in "${commands[@]}"; do
            execute_command "$cmd" &
        done
        dialog --exit-label "Ok" --backtitle "Live command output for $context" --tailbox "$combined_log" "$full_height" "$full_width" 2>&1 >/dev/tty
        exit_code=$?

    fi
    
    handle_exit_code "$exit_code" "return"
}

input_text() {
    local choice="$1"
    local status="$2"
    local msg_title="${3:-Default}"
    local msg_text="${4:-Default}"
    local msg_prompt="${5:-Default}"
    local title=$(echo -e "$msg_title")
    local message=$(echo -e "$msg_text")
    local prompt=$(echo -e "$msg_prompt")
    local dialog_output
    local console_output
    local exit_code=0

    if [ "$USE_DIALOG" = true ]; then
        dialog_output=$(dialog --backtitle "$title" --ok-label "Continue" \
            --inputbox "$message" $half_height $half_width 2>&1 >/dev/tty)
        exit_code=$?
        eval "$choice=\"$dialog_output\""

    fi
    eval "$status=\"$exit_code\""
    handle_exit_code "$exit_code" "return"
}

root_pass() {
    if [ "$ROOT_PASS_SET" = true ]; then
        return
    fi

    while true; do
        if [ "$USE_DIALOG" = true ]; then
            ROOT_PASS=$(dialog --backtitle "Sudo Password" --ok-label "Continue" \
                --insecure --passwordbox "Enter your sudo password: " $half_height $half_width 2>&1 >/dev/tty)
            exit_code=$?

        fi
        
        handle_exit_code "$exit_code" "return"

        if echo "$ROOT_PASS" | sudo -S whoami 2>/dev/null | grep -q "^root$"; then
            ROOT_PASS_SET=true
            export ROOT_PASS
            break
        else
            pause_script "Title" "Invalid password. Please try again."
        fi
    done
}

set_password() {
    local choice="$1"
    local status="$2"
    local user="$3"
    local password1 password2 exit_code

    while true; do
        if [ "$USE_DIALOG" = true ]; then

            password1=$(dialog --backtitle "Password Prompt for '$user'" --ok-label "Continue" --insecure --passwordbox "Enter password for '$user'" $half_height $half_width 2>&1 >/dev/tty)
            exit_code=$?

            password2=$(dialog --backtitle "Password Prompt for '$user'" --ok-label "Continue" --insecure --passwordbox "Re-enter password for '$user'" $half_height $half_width 2>&1 >/dev/tty)
            exit_code=$?

        fi
        
        if [ "$password1" != "$password2" ]; then
            pause_script "Password Error" "Passwords for '$user' do not match. Please try again."
        else
            eval "$choice=\"$password1\""
            eval "$status=\"$exit_code\""
            break
        fi
        handle_exit_code "$exit_code" "break"
    done
}

menu_prompt() {
    local choice="$1"
    local status="$2"
    local msg_title="${3:-Default}"
    local msg_text="${4:-Default}"
    shift 4
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
        --ok-label "Select" \
        --menu "$description" \
        $half_height $half_width 15 \
        "${menu_items[@]}" \
        2>&1 >/dev/tty)
    exit_code=$?
    eval "$choice=\"$dialog_output\""
    eval "$status=\"$exit_code\""

    handle_exit_code "$exit_code" "return"

}

multiselect_prompt() {
    local choices="$1"
    local status="$2"
    local -n given_array="$3"
    local msg_title="${4:-Default}"
    local msg_text="${5:-Default}"
    local title=$(echo -e "$msg_title")
    local description=$(echo -e "$msg_text \n\nUse SPACE to select/deselect options and OK when finished.")
    
    local options=()
    for key in "${!given_array[@]}"; do
        IFS=" | " read -r disk flags path desc <<< "${given_array[$key]}"
        options+=("$key" "$desc" "on")
    done

    if [ "$USE_DIALOG" = true ]; then
    
        dialog_output=$(dialog \
            --backtitle "$title" \
            --checklist "$description" \
            $full_height $full_width 15 \
            "${options[@]}" \
            2>&1 >/dev/tty)
        exit_code=$?
        
        IFS=$' ' read -r -a choices_array <<< "$dialog_output"
            
        eval "$choices=(${choices_array[@]})"
        eval "$status=\"$exit_code\""

        handle_exit_code "$exit_code" "return"
        
    fi
}
