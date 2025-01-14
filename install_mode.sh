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

source ./globals.sh

options=(\
    "@var_cache" \
    "@var_spool" \
    "@var_tmp" \
    "@var_log" \
    "@var_crash" \
    "@var_lib_libvirt_images" \
    "@var_lib_machines" \
    "@var_lib_flatpak" \
    "@var_lib_docker" \
    "@var_lib_distrobox" \
    "@var_lib_gdm" \
    "@var_lib_AccountsService" \
)

title="Starting subvol picker"
description="The following volumes are required for the system to work and will be create automatically.

1. @
2. @home
3. @snapshots

Please choose what extra subvolumes you require."

subvol_prompt subvol_menu_choice subvol_menu_choice_status "$title" "$description" "${options[@]}"
pause_script "" "$subvol_menu_choice"