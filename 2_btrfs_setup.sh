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

configure_snapper()
{
    commands_to_run=()
    commands_to_run+=("mount | grep 'id=5'")
    commands_to_run+=("mount | grep -w '@'")
    commands_to_run+=("mount | grep '@home'")
    commands_to_run+=("mount | grep '@snapshots'")
    commands_to_run+=("sed -i '/^#.*\\/dev\\//d' /etc/fstab && sed -i '/^[[:space:]]*$/d' /etc/fstab")
    commands_to_run+=("umount /.snapshots && rm -rf /.snapshots && snapper -c root create-config /")
    commands_to_run+=("mount -a")
    commands_to_run+=("systemctl daemon-reload")
    commands_to_run+=("echo -e ================================================\n\
    >>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\n\
    ================================================\n")


    live_command_output "" "${commands_to_run[@]}"
    pause_script "" "BTRFS Setup complete!"
}

configure_snapper