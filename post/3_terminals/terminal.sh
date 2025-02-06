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
source ./post/users.sh

terminal_menu() {
    local title="Terminal global configurator."
    local description="This allows you to set up terminals, shells and frameworks for a given user."
    while true; do
        local options=(\
            "configure terminals"\
            "configure shells"\
            "configure prompts"\
            "Back"
        )
        menu_prompt term_choice "$title" "$description" "${options[@]}"
        case $term_choice in
            0)  terminals_menu;;
            1)  shells_menu;;
            2)  prompts_menu;;
            b)  break;;
            *)  echo "Invalid option. Please try again.";;
        esac
    done
}
