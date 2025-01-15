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

if [ "$LIVE_ENV" = false ]; then
    if [ "$(id -u)" -ne 0 ]; then
        pause_script "" "The install script must be run from arch.iso as root user."
        exit 1
    fi
fi

installation_date=$(date "+%Y-%m-%d %H:%M:%S")

locale=en_US
kblayout=us

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

hostname_prompt
pause_script 'Hostname' "Hostname:    ${hostname}"

select_disk_prompt
confirmation="You picked disk $disk for Arch installation, ergo it will be fully wiped and repartitioned.

THIS IS YOUR LAST CHANCE TO CANCEL BEFORE FULL DISK DATA LOSS."
pause_script "Selected Disk $disk" "$confirmation"

continue_script 'Formatting' "Proceeding to formatting of:    ${disk}."
sgdisk --zap-all "${disk}"
continue_script 'Partition scheme' "Creating new partition scheme on ${disk}."
continue_script 'Partition table' "Creating new gpt table ${disk}."
sgdisk -g "${disk}"
continue_script 'Partition name: ESP' "Creating new partition with name ESP ${disk}."
sgdisk -I -n 1:0:+1G -t 1:ef00 -c 1:'ESP' "${disk}"
continue_script 'Partition name: Arch' "Creating new partition with name Arch ${disk}."
sgdisk -I -n 2:0:0 -c 2:'Arch' "${disk}"

export ESP='/dev/disk/by-partlabel/ESP'
export BTRFS='/dev/disk/by-partlabel/Arch'

continue_script 'Inform disk changes' 'Informing the Kernel about the disk changes.'
partprobe "${disk}"
continue_script 'Format partition ESP: FAT32' 'Formatting the EFI partition as FAT32.'
mkfs.fat -F 32 "${ESP}"
continue_script 'Format partition Arch: BTRFS' 'Formatting the Arch partition as BTRFS.'
mkfs.btrfs -f "${BTRFS}"

continue_script 'BTRFS subvolumes' 'Creating BTRFS subvolumes.'
mount "${BTRFS}" /mnt

btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@snapshots
btrfs su cr /mnt/@var_cache
btrfs su cr /mnt/@var_spool
btrfs su cr /mnt/@var_tmp
btrfs su cr /mnt/@var_log
btrfs su cr /mnt/@var_crash
btrfs su cr /mnt/@var_lib_libvirt_images
btrfs su cr /mnt/@var_lib_machines
btrfs su cr /mnt/@flatpak
btrfs su cr /mnt/@docker
btrfs su cr /mnt/@distrobox
btrfs su cr /mnt/@gdm
btrfs su cr /mnt/@var_lib_AccountsService

continue_script 'Disable CoW' 'Disabling CoW on subvols we are not taking snapshots of.'
chattr +C /mnt/@home
chattr +C /mnt/@snapshots
chattr +C /mnt/@var_cache
chattr +C /mnt/@var_spool
chattr +C /mnt/@var_tmp
chattr +C /mnt/@var_log
chattr +C /mnt/@var_crash
chattr +C /mnt/@var_lib_libvirt_images
chattr +C /mnt/@var_lib_machines
chattr +C /mnt/@flatpak
chattr +C /mnt/@docker
chattr +C /mnt/@distrobox
chattr +C /mnt/@gdm
chattr +C /mnt/@var_lib_AccountsService

continue_script 'Dismounting Btrfs root' 'Dismount btrfs root from /mnt'
umount /mnt

continue_script 'Mounting @' 'Mounting btrfs subvol @ in /mnt'
mount -o ssd,noatime,compress=zstd,subvol=@ "${BTRFS}" /mnt

continue_script 'Creating directories' 'Creating directories for other subvolumes'
mkdir -p /mnt/efi

mkdir -p /mnt/var/cache
mkdir -p /mnt/var/spool
mkdir -p /mnt/var/tmp
mkdir -p /mnt/var/log
mkdir -p /mnt/var/crash
mkdir -p /mnt/var/lib/libvirt/images
mkdir -p /mnt/var/lib/machines
mkdir -p /mnt/var/lib/flatpak
mkdir -p /mnt/var/lib/docker
mkdir -p /mnt/var/lib/distrobox
mkdir -p /mnt/var/lib/gdm
mkdir -p /mnt/var/lib/AccountsService

continue_script 'Mount subvolumes' 'Mounting the newly created subvolumes.'
mount -o ssd,noatime,compress=zstd,subvolid=5 "${BTRFS}" /mnt/.btrfsroot
mount -o ssd,noatime,compress=zstd,subvol=@home "${BTRFS}" /mnt/home
mount -o ssd,noatime,compress=zstd,subvol=@snapshots "${BTRFS}" /mnt/.snapshots
mount -o ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec,subvol=@var_log "${BTRFS}" /mnt/var/log
mount -o ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec,subvol=@var_crash "${BTRFS}" /mnt/var/crash
mount -o ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec,subvol=@var_cache "${BTRFS}" /mnt/var/cache
mount -o ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec,subvol=@var_tmp "${BTRFS}" /mnt/var/tmp
mount -o ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec,subvol=@var_spool "${BTRFS}" /mnt/var/spool
mount -o ssd,noatime,nodatacow,nodev,nosuid,noexec,subvol=@var_lib_libvirt_images "${BTRFS}" /mnt/var/lib/libvirt/images
mount -o ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec,subvol=@var_lib_machines "${BTRFS}" /mnt/var/lib/machines
mount -o ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec,subvol=@flatpak $BTRFS /mnt/var/lib/flatpak
mount -o ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec,subvol=@docker $BTRFS /mnt/var/lib/docker
mount -o ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec,subvol=@distrobox $BTRFS /mnt/var/lib/distrobox
mount -o ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec,subvol=@gdm $BTRFS /mnt/var/lib/gdm
mount -o ssd,noatime,compress=zstd,nodatacow,nodev,nosuid,noexec,subvol=@var_lib_AccountsService $BTRFS /mnt/var/lib/AccountsService

mount -o nodev,nosuid,noexec "${ESP}" /mnt/efi

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
cp -R --no-preserve=ownership /root/ArchSetup /mnt/root/ArchSetup

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