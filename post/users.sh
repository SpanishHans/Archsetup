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

source ./commons.sh

user_password_prompt () {
    local user="$1"
    local pass="$2"
    set_password user_password user_password_status "$user"
    eval "$pass='$user_password'"
}

configure_users() {
    local title="Entered user setup" 
    local description='The following section will help you create new users for your system. You can decide for each user if they should or should not be an admin user with sudo.'
    local options=(\
        "Create New User" \
        "Modify Existing User" \
        "Delete User" \
        "List Existing Users" \
        "Continue" \
        "Exit"
    )

    
    while true; do
        menu_prompt conf_users_menu conf_users_menu_status "$title" "$description" "${options[@]}"
        case $conf_users_menu in
            0)  create_user;;
            1)  modify_user;;
            2)  delete_user;;
            3)  list_users;;
            c)  break;;
            e)  exit;;
            *)  pause_script "Option not valid" "That is not an option, returning to start menu.";exit;;
        esac
    done
}

create_user() {
    input_text username username_status "New user" "Menu for creating a new user." "Enter the username for the new user: "

    local prohibited_usernames=("root" "admin" "test" "user" "guest")
    local username_pattern='^[a-zA-Z0-9._-]+$'
    local min_length=3
    local max_length=32

    while true; do
        if [ -z "${username}" ]; then
            pause_script "Empty username" 'Sorry, you need to enter a username.'
        elif [[ " ${prohibited_usernames[*]} " =~ " ${username} " ]]; then
            pause_script "Prohibited username" 'Sorry, this username is prohibited. Please choose a different username.'
        elif [[ ! "${username}" =~ ${username_pattern} ]]; then
            pause_script "Invalid characters" 'Sorry, the username can only contain letters, numbers, dots, underscores, or dashes.'
        elif (( ${#username} < min_length )); then
            pause_script "Username too short" "Sorry, the username must be at least ${min_length} characters long."
        elif (( ${#username} > max_length )); then
            pause_script "Username too long" "Sorry, the username must be no more than ${max_length} characters long."
        else
            break
        fi

        input_text username username_status "Rootless username prompt" "Username for the user with no root access" "Enter the username for the new user: "
    done
    fullname="$(tr '[:lower:]' '[:upper:]' <<< "${username:0:1}")${username:1}"
    useradd -c "$fullname" -m "$username"
    user_password_prompt fullname user_password

    echo "$username:$user_password" | chpasswd
    
    local title="Should $username be sudo?"
    local description="Please determine if user $username should have admin privileges or not."
    local options=(\
        "No, dont give admin privileges to $username." \
        "Yes, give $username admin privileges."
    )

    while true; do
        menu_prompt wheel_menu wheel_menu_status "$title" "$description" "${options[@]}"
        case $wheel_menu in
            0)  sudo_access="n";break;;
            1)  sudo_access="y";break;;
            *)  continue_script "Option not valid" "That is not an option, retry.";;
        esac
    done

    if [[ "$sudo_access" == "y" ]]; then
        usermod -aG wheel "$username" && continue_script "$username is now admin" "User $username now has admin privileges."
    fi
}

delete_user() {
    input_text username username_status "Delete user" "Menu for deleting a user. This will DELETE THEIR FILES!" "Enter the username to delete: "
    
    if id "$username" &>/dev/null; then
        userdel -r "$username" && pause_script "$username deleted" "User $username and their files deleted."
    else
        continue_script "User $username does not exist."
    fi
}

list_users() {
    local users=$(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd | tr '\n' ' ')
    pause_script "List of Existing Users: $users"
}

user_setup () {
    clear
    pause_script "Entered user setup!" "The following section will help you configure extra users for the machine as it was set to only have root by default by the install script. It is recommended to have one admin user with wheel/sudo permissions and one without them. The following menu shall help you create more users.

Lets configure extra users."
    configure_users
}

user_setup