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
source ./pre/disk_format.sh
source ./pre/networking.sh
source ./pre/user_setup.sh

if [ "$LIVE_ENV" = false ]; then
    pause_script "" "The install script must be run from the archlinux-YEAR.MONTH.DAY-x86_64.iso image.

Exiting!!!
    "
    exit
    if [ "$(id -u)" -ne 0 ]; then
        pause_script "" "The install script must be run as root user.

Exiting!!!"
        exit
    fi
fi

title="Welcome to the installer script"
description="This script will help you format your disks to your needs and then install ArchLinux.

Enjoy!"

pause_script "$title" "$description"

locale=en_US
kblayout=us

continue_script 'Partitioning' 'Starting section for disk formatting and partitioning, please wait.'
select_disk_prompt
select_efi_partition
select_root_partition
pause_script 'EFI' "EFI part: $EFI_PART
ROOT part: $ROOT_PART
ROOT type: $ROOT_FSTYPE"

continue_script 'User setup' 'Starting section for user setup, please wait.'
username_prompt
user_password_prompt
root_password_prompt
sysadmin_password_prompt

masked_user_password="${user_password:0:1}*******${user_password: -1}"
masked_root_password="${root_password:0:1}*******${root_password: -1}"
masked_sysadmin_password="${sysadmin_password:0:1}*******${sysadmin_password: -1}"

userdata="Username:    $username
Full Name:    $fullname
User Password:    $masked_user_password
Root Password:    $masked_root_password
Sysadmin Password:    $masked_sysadmin_password"
pause_script 'User confirmation' "$userdata"

continue_script 'Networking' 'Starting section for networking, please wait.'
hostname_prompt
pause_script 'Hostname' "Hostname:    ${hostname}"

start_format

continue_script 'Detect CPU vendor' 'Detecting ucode for processor brand'
CPU=$(grep -m 1 'vendor_id' /proc/cpuinfo)
if [[ "${CPU}" == *"AuthenticAMD"* ]]; then
    continue_script '' 'Installing ucode for AMD'
    microcode="amd-ucode"
elif [[ "${CPU}" == *"GenuineIntel"* ]]; then
    microcode="intel-ucode"
    continue_script '' 'Installing ucode for Intel'
else
    echo "Unknown CPU vendor. Exiting."
    exit 1
fi

continue_script 'Installing base system' 'Installing the base system (it may take a while).'
pacstrap /mnt \
  base \
  linux \
  linux-firmware \
  "${microcode}" \
  grub \
  efibootmgr \
  sudo \
  polkit \
  snapper \
  networkmanager \
  firewalld \
  openssh \
  nano \
  tree \
  less \
  terminus-font \
  wayland \
  pipewire \
  wireplumber \
  pipewire-alsa \
  pipewire-pulse \
  pipewire-jack \
  snap-pac || {
    pause_script 'Install failed somewhere in pacstrap' "Installation failed"
    exit 1
  }

continue_script 'New fstab' 'Generating a new fstab.'
genfstab -U /mnt >> /mnt/etc/fstab || { pause_script '' "genfstab failed"; exit 1; }

continue_script 'Locales setup' 'Setting up hostname, locales, and keyboard layout'
echo "$hostname" > /mnt/etc/hostname
cat <<EOF > /mnt/etc/hosts
127.0.0.1    localhost
::1          localhost
127.0.1.1    "$hostname".localdomain    "$hostname"
EOF

cat <<EOF > /mnt/etc/locale.gen
$locale.UTF-8 UTF-8
en_GB.UTF-8 UTF-8
es_CO.UTF-8 UTF-8
EOF

echo "LANG=$locale.UTF-8" > /mnt/etc/locale.conf
echo "KEYMAP=$kblayout" > /mnt/etc/vconsole.conf
echo "FONT=ter-u20n" > /mnt/etc/vconsole.conf

continue_script 'Copy repo' 'Copying repo to machine'
cp -R --no-preserve=ownership /root/Archsetup /mnt/root/Archsetup

description="About to chroot into the machine
this automatically:
    1. Generates locales and configures time to UTC
    2. Enables NetworkManager
    3. Creates users and changes passwords
    4. Enable pacman color
    5. Sets up wheel group and adds the admin user to wheel
    6. Grub no timeout and splash quiet
    7. Creates initramfs with mkinitcpio -P
    8. Installs grub for the system with btrfs and snapper-rollback support"
    
pause_script 'Chroot description' "$description"
arch-chroot /mnt /bin/bash -e <<EOF

    echo '#### STARTING 1. #### ->> time and locales'
    ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
    hwclock --systohc
    locale-gen

    echo '#### STARTING 2. #### ->> Enabling NetworkManager'
    systemctl enable NetworkManager

    echo '#### STARTING 3. #### ->> user_setup'
    useradd -c "sysadmin" -m "sysadmin"
    useradd -c "$fullname" -m "$username"
    echo "root:$root_password" | chpasswd
    echo "sysadmin:$sysadmin_password" | chpasswd
    echo "$username:$user_password" | chpasswd

    echo '#### STARTING 4. #### ->> configure pacman color'
    sed -i 's/^#Color/Color/' /etc/pacman.conf

    echo '#### STARTING 5. #### ->> configure sudoers'
    sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
    usermod -aG wheel "sysadmin"

    echo '#### STARTING 6. #### ->> no  timeout grub and quiet splash'
    sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
    sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT=\)".*"/\1"quiet splash"/' /etc/default/grub
    
    echo '#### STARTING 7. #### ->> initramfs'
    mkinitcpio -P || { echo "mkinitcpio failed"; exit 1; }
    
    echo '#### STARTING 8. #### ->> grub-install'
    grub-install --target=x86_64-efi --efi-directory=/efi --boot-directory=/boot --bootloader-id=GRUB || { echo "grub-install failed"; exit 1; }
    grub-mkconfig -o /boot/grub/grub.cfg || { echo "grub-mkconfig failed"; exit 1; }
EOF

pause_script 'Finished' 'Done, you may now wish to reboot (further changes can be done by chrooting into /mnt).'