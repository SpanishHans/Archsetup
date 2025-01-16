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

username_prompt() {
    
    input_text username username_status "Non-admin user" "Menu for creating a username with no admin privileges.

Enter the username for the new user: " "Enter the username for the new user: "

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

    export username
    export fullname
}

user_password_prompt () {
    set_password user_password user_password_status "$fullname"
    export user_password
}

root_password_prompt () {
    set_password root_password root_password_status "root"
    export root_password
}

sysadmin_password_prompt () {
    set_password sysadmin_password sysadmin_password_status "sysadmin"
    export sysadmin_password
}

