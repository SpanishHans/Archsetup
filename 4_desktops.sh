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

source ./globals.sh

DM_selector()
{
    while true; do
        clear
        pause_script "" 'Select a Window Manager category:'
        output "" '1) Console-based'
        output "" '2) Graphical-based'
        output '0) Nothing'
        read -p 'Insert the number of your selection: ' -r category_choice
        case $category_choice in
            1)  DM_console
                break
                ;;
            2)  DM_graphical
                break
                ;;
            0)  output 'I dont want shit, get out of here'
                break
                ;;
            *)  output 'You did not enter a valid selection.'
        esac
    done

    output "Display Manager Setup complete!"
    pause_script
}

DM_console()
{
    commands_to_run=()
    all_dms=("ly.service" "lemurs.service" "gdm.service" "lightdm.service" "sddm.service" "greetd.service cosmic-greeter.service")

    for dm in "${all_dms[@]}"; do
        commands_to_run+=("systemctl disable $dm")
    done

    clear
    pause_script "root password" 'Provide system root password for installation'
    su -c "$(printf "%s\n" "${commands_to_run[@]}")" || { echo "Service(s) doesnt exist or already disabled"; }

    commands_to_run=()

    while true; do
        output 'Select a Console Window Manager:'
        output '1) Ly'
        output '2) Tbsm'
        output '3) Emptty'
        output '4) Lemurs'
        output '0) Nothing'
        read -p 'Insert the number of your selection: ' -r console_choice
        case $console_choice in
            1)  commands_to_run+=("pacman --noconfirm -S ly")
                commands_to_run+=("systemctl enable ly.service && systemctl start --now ly.service")
                break
                ;;
            2)  commands_to_run+=("echo'Not yet implemented, but shall "snp paru -S tbsm"'")
                break
                ;;
            3)  commands_to_run+=("echo'Not yet implemented, but shall "pacman --noconfirm -S emptty"'")
                break
                ;;
            4)  commands_to_run+=("pacman --noconfirm -S lemurs")
                commands_to_run+=("systemctl enable lemurs.service && systemctl start --now lemurs.service")
                break
                ;;
            0)  output 'I dont want shit, get out of here'
                break
                ;;
            *)  output 'You did not enter a valid selection.'
        esac
    done

    live_command_output "${commands_to_run[@]}"

    output "Display Manager Console Setup complete!"
    pause_script
}

DM_graphical()
{
    commands_to_run=()
    all_dms=("ly.service" "lemurs.service" "gdm.service" "lightdm.service" "sddm.service" "greetd.service cosmic-greeter.service")

    for dm in "${all_dms[@]}"; do
        commands_to_run+=("systemctl disable $dm")
    done

    clear
    pause_script "root password" 'Provide system root password for installation'
    su -c "$(printf "%s\n" "${commands_to_run[@]}")" || { echo "Service(s) doesnt exist or already disabled"; }

    commands_to_run=()

    while true; do
        clear
        output 'Select a Graphical Window Manager:'
        output '1) Gdm (Gnome)'
        output '2) Lightdm (generalist)'
        output '3) Sddm (KDE)'
        output '4) Greetd (generalist)'
        output '0) Nothing'
        read -p 'Insert the number of your selection: ' -r graphical_choice
        case $graphical_choice in
            1)  commands_to_run+=("pacman --noconfirm -S gdm")
                commands_to_run+=("systemctl enable gdm.service && systemctl start --now gdm.service")
                break
                ;;
            2)  commands_to_run+=("pacman --noconfirm -S lightdm")
                commands_to_run+=("systemctl enable lightdm.service && systemctl start --now lightdm.service")
                break
                ;;
            3)  commands_to_run+=("pacman --noconfirm -S sddm")
                commands_to_run+=("systemctl enable sddm.service && systemctl start --now sddm.service")
                break
                ;;
            4)  commands_to_run+=("pacman --noconfirm -S greetd")
                commands_to_run+=("systemctl enable greetd.service && systemctl start --now greetd.service")
                break
                ;;
            0)  output 'I dont want shit, get out of here'
                break
                ;;
            *)  output 'You did not enter a valid selection.'
        esac
    done

    live_command_output "${commands_to_run[@]}"

    output "Display Manager Graphical Setup complete!"
    pause_script
}


DE_selector()
{
    commands_to_run=()
    all_dms=("ly.service" "lemurs.service" "gdm.service" "lightdm.service" "sddm.service" "greetd.service cosmic-greeter.service")

    for dm in "${all_dms[@]}"; do
        commands_to_run+=("systemctl disable $dm")
    done

    clear
    pause_script "root password" 'Provide system root password for installation'
    su -c "$(printf "%s\n" "${commands_to_run[@]}")" || { echo "Service(s) doesnt exist or already disabled"; }

    commands_to_run=()

    while true; do
        clear
        output 'What Desktop Environment to install?'
        output '1) Budgie'
        output '2) Cinnamon '
        output '3) Cosmic'
        output '4) Cutefish'
        output '5) Deepin'
        output '6) Enlightenment'
        output '7) Gnome'
        output '8) Gnome Flashback'
        output '9) KDE Plasma'
        output '10) LXDE (Not implemented)'
        output '11) LXQt (Not implemented)'
        output '12) Mate'
        output '13) Pantheon'
        output '14) XFCE (Not implemented)'
        output '0) Nothing'
        read -p 'Insert the number of your selection: ' -r DE_choice
        case $DE_choice in
            1)  commands_to_run+=("pacman --noconfirm -S budgie lightdm-gtk-greeter budgie-desktop-view budgie-backgrounds network-manager-applet arc-gtk-theme papirus-icon-theme lightdm")
                commands_to_run+=("systemctl enable lightdm.service && systemctl start --now lightdm.service")
                break
                ;;
            2)  commands_to_run+=("pacman --noconfirm -S cinnamon xed xreader metacity gnome-shell gnome-keyring lightdm")
                commands_to_run+=("systemctl enable lightdm.service && systemctl start --now lightdm.service")
                break
                ;;
            3)  commands_to_run+=("pacman --noconfirm -S cosmic cosmic-text-editor cosmic-files cosmic-terminal cosmic-wallpapers")
                commands_to_run+=("systemctl enable cosmic-greeter.service && systemctl start --now cosmic-greeter.service")
                break
                ;;
            4)  commands_to_run+=("pacman --noconfirm -S cutefish sddm")
                commands_to_run+=("systemctl enable sddm.service && systemctl start --now sddm.service")
                break
                ;;
            5)  commands_to_run+=("pacman --noconfirm -S deepin deepin-kwin deepin-extra lightdm")
                commands_to_run+=("systemctl enable lightdm.service && systemctl start --now lightdm.service")
                break
                ;;
            6)  commands_to_run+=("pacman --noconfirm -S enlightenment ecrire ephoto evisum rage terminology connman lightdm")
                commands_to_run+=("systemctl enable lightdm.service && systemctl start --now lightdm.service")
                break
                ;;
            7)  commands_to_run+=("pacman --noconfirm -S gnome gdm")
                commands_to_run+=("systemctl enable gdm.service && systemctl start --now gdm.service")
                break
                ;;
            8)  commands_to_run+=("pacman --noconfirm -S gnome-flashback gnome-applets sensors-applet gdm")
                commands_to_run+=("systemctl enable gdm.service && systemctl start --now gdm.service")
                break
                ;;
            9)  commands_to_run+=("pacman --noconfirm -S plasma kde-applications-meta sddm")
                commands_to_run+=("systemctl enable sddm.service && systemctl start --now sddm.service")
                break
                ;;
            10) commands_to_run+=("echo'Not yet implemented because its x11 only for now, but shall "pacman --noconfirm -S lxde"'")
                break
                ;;
            11) commands_to_run+=("echo'Not yet implemented because its x11 only for now, but shall "pacman --noconfirm -S lxqt"'")
                break
                ;;
            12) commands_to_run+=("pacman --noconfirm -S mate mate-extra lightdm")
                commands_to_run+=("systemctl enable lightdm.service && systemctl start --now lightdm.service")
                break
                ;;
            13) commands_to_run+=("pacman --noconfirm -S pantheon lightdm")
                commands_to_run+=("systemctl enable lightdm.service && systemctl start --now lightdm.service")
                break
                ;;
            14) commands_to_run+=("echo'Not yet implemented because its x11 only for now, but shall "pacman --noconfirm -S xfce"'")
                break
                ;;
            0)  output 'I dont want shit, get out of here'
                break
                ;;
            *)  output 'You did not enter a valid selection.'
        esac
    done

    live_command_output "${commands_to_run[@]}"

    output "Desktop Environment Setup complete!"
    pause_script
}

WM_selector()
{
    commands_to_run=()
    all_dms=("ly.service" "lemurs.service" "gdm.service" "lightdm.service" "sddm.service" "greetd.service cosmic-greeter.service")

    for dm in "${all_dms[@]}"; do
        commands_to_run+=("systemctl disable $dm")
    done

    live_command_output "${commands_to_run[@]}"

    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S brightnessctl")

    while true; do
        clear
        output 'What Window Manager to install?'
        output '1) Sway'
        output '2) Hyprland'
        output '0) Nothing'
        read -p 'Insert the number of your selection: ' -r WM_choice
        case $WM_choice in
            
            1)  commands_to_run+=("pacman --noconfirm -S sway kitty wayland")
                commands_to_run+=("systemctl enable lightdm.service && systemctl start --now lightdm.service")
                break
                ;;
            2)  commands_to_run+=("pacman --noconfirm -S hyprland hypridle hyprpaper hyprlock xdg-desktop-portal-hyprland kitty wayland")
                commands_to_run+=("systemctl enable lightdm.service && systemctl start --now lightdm.service")
                break
                ;;
            0)  output 'I dont want shit, get out of here'
                break
                ;;
            *)  output 'You did not enter a valid selection.'
        esac
    done

    live_command_output "${commands_to_run[@]}"

    output "Window Manager Setup complete!"
    pause_script
}

while true; do
    clear
    output "Configuration Menu"
    output "-------------------"
    output "1) Configure Display Manager"
    output "2) Configure Desktop Environment"
    output "3) Configure Window Manager"
    output "0) Exit"
    read -p "Please select an option: " -r choice
    case $choice in
        1) DM_selector;;
        2) DE_selector;;
        3) WM_selector;;
        0) output 'I dont want shit, get out of here'; break ;;
        *) output "Invalid choice, please try again." ;;
    esac
done