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

root_password_prompt () {
    local pass="$1"
    set_password root_password root_password_status "root"
    eval "$pass='$root_password'"
}

superuser_setup () {
    clear
    pause_script "Entered root user setup!" "The following section will help you configure the password for the root user. This script does not create more users during install, they are created after install if you so desire.

With this in mind, DONT LOOSE YOUR ROOT PASSWORD, or you wont be able to login after install."

    root_password_prompt root_password
    masked_root_password="${root_password:0:1}*******${root_password: -1}"
    export root_password

    pause_script 'Root user confirmation' "Username:    root
Root Password:    $masked_root_password"
}