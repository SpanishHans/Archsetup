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

if command -v dialog &> /dev/null; then
    USE_DIALOG=true
else
    USE_DIALOG=false
fi

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
    local length=${#msg_title}
    local border=$(printf '%*s' $((length + 4)) '' | tr ' ' '-')
    title=$(echo -e "$msg_title")
    
    printf '\e[1;34m%-6s\e[m\n' "$border"
    printf '\e[1;34m%-6s\e[m\n' "| $title |"
    printf '\e[1;34m%-6s\e[m\n' "$border"
}

get_out()
{
    clear
    return 0
}

pause_script() {
    local msg_title="${1:-Default}"
    local msg_text="${2:-Default}"
    title=$(echo -e "$msg_title")
    message=$(echo -e "$msg_text")

    if [ "$USE_DIALOG" = true ]; then
        dialog --ok-label "Ok" --backtitle "$title" --msgbox "$message" $half_height $half_width 2>&1 >/dev/tty
        exit_code=$?
        case $exit_code in
            0)  return;;
            1)  exit;;
            *)  pause_script 'Error' "Unknown exit code: $exit_code";;
        esac
    else
        output
        terminal_title "$title"

        output "$message"
        output
        read -p 'Continue...'
        exit_code=$?
        case $exit_code in
            0)  return;;
            1)  exit;;
            *)  pause_script 'Error' "Unknown exit code: $exit_code";;
        esac
    fi
}

live_command_output() {
    local commands=("$@")

    if [ "$USE_DIALOG" = true ]; then
        temp_file=$(mktemp)
        for cmd in "${commands[@]}"; do
            echo $ROOT_PASS | sudo -S bash -c "$cmd" > $temp_file 2>&1 || echo -e "\
============================================================\n\
>>> CRITICAL ERROR: COMMAND EXECUTION FAILED! <<<\n\
------------------------------------------------------------\n\
Failed Command: $cmd\n\
============================================================" >> $temp_file &
        done
        dialog --exit-label "Ok" --backtitle "Live Command Output" --tailbox $temp_file $full_height $full_width 2>&1 >/dev/tty
        exit_code=$?

        case $exit_code in
            0)  return;;
            1)  exit;;
            *)  pause_script 'Error' "Unknown exit code: $exit_code";;
        esac
    else
        clear
        terminal_title "Live Command Output"
        output "Press Ctrl+C to stop."
        output

        for cmd in "${commands[@]}"; do
            echo $ROOT_PASS | sudo -S bash -c "$cmd" || echo -e "\
============================================================\n\
>>> CRITICAL ERROR: COMMAND EXECUTION FAILED! <<<\n\
------------------------------------------------------------\n\
Failed Command: $cmd\
============================================================"
        done
        exit_code="0"
        pause_script "Live command" "Command has finished execution"

        case $exit_code in
            0)  return;;
            1)  exit;;
            *)  pause_script 'Error' "Unknown exit code: $exit_code";;
        esac
    fi
}

input_text() {
    local choice="$1"
    local status="$2"
    local msg_title="${3:-Default}"
    local msg_text="${4:-Default}"
    local msg_prompt="${5:-Default}"
    title=$(echo -e "$msg_title")
    message=$(echo -e "$msg_text")
    prompt=$(echo -e "$msg_prompt")

    if [ "$USE_DIALOG" = true ]; then
        dialog_output=$(dialog --backtitle "$title" --ok-label "Continue" --inputbox "$message" $half_height $half_width 2>&1 >/dev/tty)
        exit_code=$?
        
        eval "$choice=\"$dialog_output\""
        eval "$status=\"$exit_code\""

        case $exit_code in
            0)  return;;
            1)  exit;;
            *)  pause_script 'Error' "Unknown exit code: $exit_code";;
        esac

    else
        clear
        terminal_title "$text"
        output "$message"
        output

        read -p "$prompt" console_output
        exit_code=$?
        
        eval "$choice=\"$console_output\""
        eval "$status=\"$exit_code\""

        case $exit_code in
            0)  return;;
            1)  exit;;
            *)  pause_script 'Error' "Unknown exit code: $exit_code";;
        esac
    fi
}

root_pass() {
    if [ "$ROOT_PASS_SET" = true ]; then
        return
    fi

    while true; do
        if [ "$USE_DIALOG" = true ]; then
            ROOT_PASS=$(dialog --backtitle "Sudo Password" --ok-label "Continue" --insecure --passwordbox "Enter your sudo password: " $half_height $half_width 2>&1 >/dev/tty)
            exit_code=$?
            case $exit_code in
                0)  return;;
                1)  exit;;
                *)  pause_script 'Error' "Unknown exit code: $exit_code";;
            esac
        else
            clear
            terminal_title "Sudo Password"
            output

            read -s -p "This script requires root permissions. Enter your root password: " -r ROOT_PASS
            exit_code=$?
            output
            case $exit_code in
                0)  return;;
                1)  exit;;
                *)  pause_script 'Error' "Unknown exit code: $exit_code";;
            esac
        fi

        if echo "$ROOT_PASS" | sudo -S whoami 2>/dev/null | grep -q "^root$"; then
            ROOT_PASS_SET=true
            export ROOT_PASS
        else
            pause_script "Title" "Invalid password. Please try again."
        fi
    done
}

set_password() {
    local choice="$1"
    local status="$2"
    local username="${3:-Default}"
    user=$(echo -e "$username")

    while true; do
        if [ "$USE_DIALOG" = true ]; then

            password1=$(dialog --backtitle "Password Prompt for '$user'" --ok-label "Continue" --insecure --passwordbox "Enter password for '$user'" $half_height $half_width 2>&1 >/dev/tty)
            exit_code=$?

            password2=$(dialog --backtitle "Password Prompt for '$user'" --ok-label "Continue" --insecure --passwordbox "Re-enter password for '$user'" $half_height $half_width 2>&1 >/dev/tty)
            exit_code=$?

            if [ "$password1" != "$password2" ]; then
                pause_script "Password Error" "Passwords for '$username' do not match. Please try again."
            else
                eval "$choice=\"$password1\""
                eval "$status=\"$exit_code\""
                case $exit_code in
                    0)  break;;
                    1)  exit;;
                    *)  pause_script 'Error' "Unknown exit code: $exit_code";;
                esac
            fi

        else
            clear
            terminal_title "Password Prompt for '$user'"
            output "Please enter a password for: '$user'"
            output
            
            read -s -p "Enter password for '$user': " password1
            exit_code=$?
            output
            read -s -p "Re-enter password for '$user': " password2
            exit_code=$?

            if [ "$password1" != "$password2" ]; then
                pause_script "Password Error" "Passwords for '$user' do not match. Please try again."
            else
                eval "$choice=\"$password1\""
                eval "$status=\"$exit_code\""
                case $exit_code in
                    0)  break;;
                    1)  exit;;
                    *)  pause_script 'Error' "Unknown exit code: $exit_code";;
                esac
            fi
        fi
    done
}

menu_prompt() {
    local choice="$1"
    local status="$2"
    local msg_title="${3:-Default}"
    local text="${4:-Default}"
    shift 4
    local options=("$@")
    title=$(echo -e "$msg_title")
    description=$(echo -e "$text")

    menu_items=()
    for i in "${!options[@]}"; do
        menu_items+=($((i + 1)) "${options[i]}")
    done
    menu_items+=(0 "Exit")

    if [ "$USE_DIALOG" = true ]; then
        dialog_output=$(dialog \
            --backtitle "$title" \
            --ok-label "Select" \
            --menu "$description" \
            $half_height $half_width 4 \
            "${menu_items[@]}" 2>&1 >/dev/tty)
        exit_code=$?
        eval "$choice=\"$dialog_output\""
        eval "$status=\"$exit_code\""

        case $exit_code in
            0)  return;;
            1)  exit;;
            *)  pause_script 'Error' "Unknown exit code: $exit_code";;
        esac

    else
        clear
        terminal_title "$title"
        output "$description"
        output
        
        for ((i=0; i<${#menu_items[@]}; i+=2)); do
            echo "${menu_items[i]}. ${menu_items[i+1]}"
        done
        output

        read -p "Choose an option from the above: " -r console_output
        exit_code=0
        eval "$choice=\"$console_output\""
        eval "$status=\"$exit_code\""

        case $exit_code in
            0)  return;;
            1)  exit;;
            *)  pause_script 'Error' "Unknown exit code: $exit_code";;
        esac
        
    fi
}