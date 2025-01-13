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
        options=(\
            "1) Console-based" \
            "2) Graphical-based" \
        )
        
        menu_prompt category_choice category_choice_status "$titulo" "$descripcion" "${options[@]}"

        case $category_choice in
            1)  DM_console
                break
                ;;
            2)  DM_graphical
                break
                ;;
            0)  exit
                ;;
            *)  pause_script "" 'You did not enter a valid selection.'
        esac
    done

    pause_script "" "Display Manager Setup complete!"
}

DM_console()
{
    commands_to_run=()
    all_dms=("ly.service" "lemurs.service" "gdm.service" "lightdm.service" "sddm.service" "greetd.service cosmic-greeter.service")

    for dm in "${all_dms[@]}"; do
        commands_to_run+=("systemctl disable $dm")
    done
    live_command_output "" "${commands_to_run[@]}"
    
    commands_to_run=()

    while true; do
        options=(\
            "1) Ly" \
            "2) Tbsm" \
            "3) Emptty" \
            "4) Lemurs" \
        )
        
        menu_prompt console_choice console_choice_status "$titulo" "$descripcion" "${options[@]}"

        case $console_choice in
            1)  commands_to_run+=("pacman --noconfirm -S ly")
                commands_to_run+=("systemctl enable ly.service")
                commands_to_run+=("systemctl start --now ly.service")
                break
                ;;
            2)  commands_to_run+=("echo'Not yet implemented, but shall "snp paru -S tbsm"'")
                break
                ;;
            3)  commands_to_run+=("echo'Not yet implemented, but shall "pacman --noconfirm -S emptty"'")
                break
                ;;
            4)  commands_to_run+=("pacman --noconfirm -S lemurs")
                commands_to_run+=("systemctl enable lemurs.service")
                commands_to_run+=("systemctl start --now lemurs.service")
                break
                ;;
            0)  exit
                ;;
            *)  pause_script "" 'You did not enter a valid selection.'
        esac
    done
    commands_to_run+=("echo -e ================================================\n\
    >>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\n\
    ================================================\n'")

    live_command_output "" "${commands_to_run[@]}"
    pause_script "" "Display Manager Console Setup complete!"
}

DM_graphical()
{
    commands_to_run=()
    all_dms=("ly.service" "lemurs.service" "gdm.service" "lightdm.service" "sddm.service" "greetd.service cosmic-greeter.service")

    for dm in "${all_dms[@]}"; do
        commands_to_run+=("systemctl disable $dm")
    done
    live_command_output "" "${commands_to_run[@]}"
    
    commands_to_run=()

    while true; do
        options=(\
            "1) Gdm (Gnome)" \
            "2) Lightdm (generalist)" \
            "3) Sddm (KDE)" \
            "4) Greetd (generalist)" \
        )
        
        menu_prompt graphical_choice graphical_choice_status "$titulo" "$descripcion" "${options[@]}"

        case $graphical_choice in
            1)  commands_to_run+=("pacman --noconfirm -S gdm")
                commands_to_run+=("systemctl enable gdm.service")
                commands_to_run+=("systemctl start --now gdm.service")
                break
                ;;
            2)  commands_to_run+=("pacman --noconfirm -S lightdm")
                commands_to_run+=("systemctl enable ly.service")
                commands_to_run+=("systemctl start --now ly.service")
                break
                ;;
            3)  commands_to_run+=("pacman --noconfirm -S sddm")
                commands_to_run+=("systemctl enable sddm.service")
                commands_to_run+=("systemctl start --now sddm.service")
                break
                ;;
            4)  commands_to_run+=("pacman --noconfirm -S greetd")
                commands_to_run+=("systemctl enable greetd.service")
                commands_to_run+=("systemctl start --now greetd.service")
                break
                ;;
            0)  exit
                ;;
            *)  pause_script "" 'You did not enter a valid selection.'
        esac
    done
    commands_to_run+=("echo -e ================================================\n\
    >>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\n\
    ================================================\n'")

    live_command_output "" "${commands_to_run[@]}"
    pause_script "" "Display Manager Graphical Setup complete!"
}


DE_selector()
{
    commands_to_run=()
    all_dms=("ly.service" "lemurs.service" "gdm.service" "lightdm.service" "sddm.service" "greetd.service cosmic-greeter.service")

    for dm in "${all_dms[@]}"; do
        commands_to_run+=("systemctl disable $dm")
    done
    live_command_output "" "${commands_to_run[@]}"

    commands_to_run=()

    while true; do
        options=(\
            "1) Budgie" \
            "2) Cinnamon " \
            "3) Cosmic" \
            "4) Cutefish" \
            "5) Deepin" \
            "6) Enlightenment" \
            "7) Gnome" \
            "8) Gnome Flashback" \
            "9) KDE Plasma" \
            "10) LXDE (Not implemented)" \
            "11) LXQt (Not implemented)" \
            "12) Mate" \
            "13) Pantheon" \
            "14) XFCE (Not implemented)" \
        )
        
        menu_prompt DE_choice DE_choice_status "$titulo" "$descripcion" "${options[@]}"
        
        case $DE_choice in
            1)  commands_to_run+=("pacman --noconfirm -S budgie lightdm-gtk-greeter budgie-desktop-view budgie-backgrounds network-manager-applet arc-gtk-theme papirus-icon-theme")
                commands_to_run+=("systemctl enable ly.service")
                commands_to_run+=("systemctl start --now ly.service")
                break
                ;;
            2)  commands_to_run+=("pacman --noconfirm -S cinnamon xed xreader metacity gnome-shell gnome-keyring")
                commands_to_run+=("systemctl enable ly.service")
                commands_to_run+=("systemctl start --now ly.service")
                break
                ;;
            3)  commands_to_run+=("pacman --noconfirm -S cosmic cosmic-text-editor cosmic-files cosmic-terminal cosmic-wallpapers")
                commands_to_run+=("systemctl enable cosmic-greeter.service")
                commands_to_run+=("systemctl start --now cosmic-greeter.service")
                break
                ;;
            4)  commands_to_run+=("pacman --noconfirm -S cutefish sddm")
                commands_to_run+=("systemctl enable sddm.service")
                commands_to_run+=("systemctl start --now sddm.service")
                break
                ;;
            5)  commands_to_run+=("pacman --noconfirm -S deepin deepin-kwin deepin-extra")
                commands_to_run+=("systemctl enable ly.service")
                commands_to_run+=("systemctl start --now ly.service")
                break
                ;;
            6)  commands_to_run+=("pacman --noconfirm -S enlightenment ecrire ephoto evisum rage terminology connman")
                commands_to_run+=("systemctl enable ly.service")
                commands_to_run+=("systemctl start --now ly.service")
                break
                ;;
            7)  commands_to_run+=("pacman --noconfirm -S gnome gdm")
                commands_to_run+=("systemctl enable gdm.service")
                commands_to_run+=("systemctl start --now gdm.service")
                break
                ;;
            8)  commands_to_run+=("pacman --noconfirm -S gnome-flashback gnome-applets sensors-applet gdm")
                commands_to_run+=("systemctl enable gdm.service")
                commands_to_run+=("systemctl start --now gdm.service")
                break
                ;;
            9)  commands_to_run+=("pacman --noconfirm -S plasma kde-applications-meta sddm")
                commands_to_run+=("systemctl enable sddm.service")
                commands_to_run+=("systemctl start --now sddm.service")
                break
                ;;
            10) commands_to_run+=("echo'Not yet implemented because its x11 only for now, but shall "pacman --noconfirm -S lxde"'")
                break
                ;;
            11) commands_to_run+=("echo'Not yet implemented because its x11 only for now, but shall "pacman --noconfirm -S lxqt"'")
                break
                ;;
            12) commands_to_run+=("pacman --noconfirm -S mate mate-extra lightdm")
                commands_to_run+=("systemctl enable ly.service")
                commands_to_run+=("systemctl start --now ly.service")
                break
                ;;
            13) commands_to_run+=("pacman --noconfirm -S pantheon lightdm")
                commands_to_run+=("systemctl enable ly.service")
                commands_to_run+=("systemctl start --now ly.service")
                break
                ;;
            14) commands_to_run+=("echo'Not yet implemented because its x11 only for now, but shall "pacman --noconfirm -S xfce"'")
                break
                ;;
            0)  exit
                ;;
            *)  pause_script "" 'You did not enter a valid selection.'
        esac
    done
    commands_to_run+=("echo -e ================================================\n\
    >>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\n\
    ================================================\n'")

    live_command_output "" "${commands_to_run[@]}"
    pause_script "" "Desktop Environment Setup complete!"
}

WM_selector()
{
    commands_to_run=()
    all_dms=("ly.service" "lemurs.service" "gdm.service" "lightdm.service" "sddm.service" "greetd.service cosmic-greeter.service")

    for dm in "${all_dms[@]}"; do
        commands_to_run+=("systemctl disable $dm")
    done
    live_command_output "" "${commands_to_run[@]}"

    commands_to_run=()
    commands_to_run+=("pacman --noconfirm -S brightnessctl")

    while true; do
        options=(\
            "1) Sway" \
            "2) Hyprland" \
        )

        menu_prompt WM_choice WM_choice_status "$titulo" "$descripcion" "${options[@]}"

        case $WM_choice in
            
            1)  commands_to_run+=("pacman --noconfirm -S sway kitty wayland")
                commands_to_run+=("systemctl enable ly.service")
                commands_to_run+=("systemctl start --now ly.service")
                break
                ;;
            2)  commands_to_run+=("pacman --noconfirm -S hyprland hypridle hyprpaper hyprlock xdg-desktop-portal-hyprland kitty wayland")
                commands_to_run+=("systemctl enable ly.service")
                commands_to_run+=("systemctl start --now ly.service")
                break
                ;;
            0)  exit
                ;;
            *)  output 'You did not enter a valid selection.'
        esac
    done
    commands_to_run+=("echo -e ================================================\n\
    >>> SUCCESS: COMMANDS EXECUTED SUCCESSFULLY! <<<\n\
    ================================================\n'")

    live_command_output "" "${commands_to_run[@]}"
    pause_script "" "Window Manager Setup complete!"
}

while true; do
    options=(\
        "1) Configure Display Manager" \
        "2) Configure Desktop Environment" \
        "3) Configure Window Manager" \
    )
    
    menu_prompt choice choice_status "$titulo" "$descripcion" "${options[@]}"

    case $choice in
        1) DM_selector;;
        2) DE_selector;;
        3) WM_selector;;
        0) exit;;
        *) output "Invalid choice, please try again." ;;
    esac
done