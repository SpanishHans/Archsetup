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
source ./post/0_users/users.sh
source ./post/4_software/pacman.sh

desktops_menu () {
    local title="Desktop UI Configuration"
    local description="Welcome to the system configuration menu. Here you can set up your display manager, choose a desktop environment, or configure your window manager to get your system up and running."

    while true; do
        local options=(\
            "Display Manager               (GDM, LY, LIGHTDM)"\
            "Desktop Environment           (Gnome, Kde, Cosmic, Mate, Cinnamon...)"\
            "Window Manager                (Sway, Hyprland)"\
            "Back"
        )
        
        menu_prompt des_choice "$title" "$description" "${options[@]}"

        case $des_choice in
            0)  DM_selector;;
            1)  DE_selector;;
            2)  WM_selector;;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}

################################################################################
# TTY DM
################################################################################

install_ly() {
    install_pacman_packages ly
    commands_to_run=("systemctl enable ly.service")
    live_command_output "" "" "yes" "Installing selected TTY DM: Ly" "${commands_to_run[@]}"
    continue_script 2 "Installed ly DM" "Installed the ly DM."
}

install_tbsm() {
    continue_script 2 "Not implemented" 'Not yet implemented, but shall "snp paru -S tbsm"'
}

install_emptty() {
    continue_script 2 "Not implemented" 'Not yet implemented, but shall "pacman --noconfirm -S emptty"'
}

install_lemurs() {
    install_pacman_packages lemurs
    commands_to_run=("systemctl enable lemurs.service")
    live_command_output "" "" "yes" "Installing selected TTY DM: Lemurs" "${commands_to_run[@]}"
    continue_script 2 "Installed lemurs DM" "Installed the lemurs DM."
}

################################################################################
# GUI DM
################################################################################

install_gdm() {
    install_pacman_packages gdm
    commands_to_run=("systemctl enable gdm.service")
    live_command_output "" "" "yes" "Installing selected GUI DM: GDM" "${commands_to_run[@]}"
    continue_script 2 "Installed gdm DM" "Installed the gdm DM."
}

install_lightdm() {
    install_pacman_packages lightdm
    commands_to_run=("systemctl enable lightdm.service")
    live_command_output "" "" "yes" "Installing selected GUI DM: LightDM" "${commands_to_run[@]}"
    continue_script 2 "Installed lightdm DM" "Installed the lightdm DM."
}

install_sddm() {
    install_pacman_packages sddm
    commands_to_run=("systemctl enable sddm.service")
    live_command_output "" "" "yes" "Installing selected GUI DM: SDDM" "${commands_to_run[@]}"
    continue_script 2 "Installed sddm DM" "Installed the sddm DM."
}

install_greetd() {
    install_pacman_packages greetd
    commands_to_run=("systemctl enable greetd.service")
    live_command_output "" "" "yes" "Installing selected GUI DM: Greetd" "${commands_to_run[@]}"
    continue_script 2 "Installed greetd DM" "Installed the greetd DM."
}

################################################################################
# DE
################################################################################

install_budgie() {
    install_pacman_packages budgie lightdm-gtk-greeter budgie-desktop-view budgie-backgrounds network-manager-applet arc-gtk-theme papirus-icon-theme
    continue_script 2 "Installed budgie" "Installed the budgie DE."
}

install_cinnamon() {
    install_pacman_packages cinnamon xed xreader metacity gnome-shell gnome-keyring
    continue_script 2 "Installed v  " "Installed the cinnamon DE."
}

install_cosmic() {
    install_pacman_packages cosmic cosmic-text-editor cosmic-files cosmic-terminal cosmic-wallpapers
    continue_script 2 "Installed cosmic" "Installed the cosmic DE."
}

install_cutefish() {
    install_pacman_packages cutefish sddm
    continue_script 2 "Installed cutefish" "Installed the cutefish DE."
}

install_deepin() {
    install_pacman_packages deepin deepin-kwin deepin-extra
    continue_script 2 "Installed deepin" "Installed the deepin DE."
}

install_gnome() {
    install_pacman_packages gnome gdm
    continue_script 2 "Installed gnome" "Installed the gnome DE."
}

install_gnome_flashback() {
    install_pacman_packages gnome-flashback gnome-applets sensors-applet gdm
    continue_script 2 "Installed gnome flashback" "Installed the gnome flashback DE."
}

install_kde_plasma() {
    install_pacman_packages plasma kde-applications-meta sddm
    continue_script 2 "Installed kde plasma" "Installed the kde plasma DE."
}

install_lxde() {
    continue_script 2 "Not implemented" 'Not yet implemented because its x11 only for now, but shall "pacman --noconfirm -S lxde"'
}

install_lxqt() {
    continue_script 2 "Not implemented" 'Not yet implemented because its x11 only for now, but shall "pacman --noconfirm -S lxqt"'
}

install_mate() {
    install_pacman_packages mate mate-extra lightdm
    continue_script 2 "Installed mate" "Installed the mate DE."
}

install_pantheon() {
    install_pacman_packages pantheon lightdm
    continue_script 2 "Installed pantheon" "Installed the pantheon DE."
}

install_xfce() {
    continue_script 2 "Not implemented" 'Not yet implemented because its x11 only for now, but shall "pacman --noconfirm -S xfce"'
}

################################################################################
# WM
################################################################################

install_sway() {
    install_pacman_packages sway kitty brightnessctl
}

install_hyprland() {
    install_pacman_packages hyprland hypridle xdg-desktop-portal-hyprland brightnessctl kitty waybar rofi-wayland rofi-calc
}

install_enlightenment() {
    install_pacman_packages enlightenment ecrire ephoto evisum rage terminology connman brightnessctl
}

purge_dm() {
    commands_to_run=()
    all_dms=("ly.service" "lemurs.service" "gdm.service" "lightdm.service" "sddm.service" "greetd.service cosmic-greeter.service")

    for dm in "${all_dms[@]}"; do
        systemctl disable "$dm"
    done
}

DM_selector() {
    local title="Display manager selection"
    local description="Display managers are basically the login screen. Pick between terminal and GUI based."
    while true; do
        local options=(\
            "Console-based"\
            "Graphical-based"\
            "Back"\
        )
        menu_prompt category_choice "$title" "$description" "${options[@]}"
        case $category_choice in
            0)  DM_console;;
            1)  DM_graphical;;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" 'You did not enter a valid selection.'
        esac
    done
}

DM_console() {
    commands_to_run=()

    local title="Display manager selection"
    local description="Display managers are basically the login screen. This ones are terminal based, so no fancy icons."

    while true; do
        local options=(\
            "Ly"\
            "Tbsm"\
            "Emptty"\
            "Lemurs"\
            "Back"\
        )
        menu_prompt console_choice "$title" "$description" "${options[@]}"
        case $console_choice in
            0)  purge_dm;install_ly;;
            1)  purge_dm;install_tbsm;;
            2)  purge_dm;install_emptty;;
            3)  purge_dm;install_lemurs;;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" 'You did not enter a valid selection.'
        esac
    done
}

DM_graphical() {
    commands_to_run=()

    local title="Display manager selection"
    local description="Display managers are basically the login screen. This ones are not terminal based, but have actual GUIs"

    while true; do
        local options=(\
            "Gdm"\
            "Lightdm"\
            "Sddm"\
            "Greetd"\
            "Back"\
        )
        menu_prompt graphical_choice "$title" "$description" "${options[@]}"
        case $graphical_choice in
            0)  purge_dm;install_gdm;;
            1)  purge_dm;install_lightdm;;
            2)  purge_dm;install_sddm;;
            3)  purge_dm;install_greetd;;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" 'You did not enter a valid selection.'
        esac
    done
}


DE_selector() {
    commands_to_run=()

    local title="Desktop environment selection"
    local description="This menu help you install any of the desktop environments supported by arch!"

    while true; do
        local options=(\
            "Budgie                      (Red Hat)" \
            "Cinnamon                    (Linux Mint)" \
            "Cosmic                      (Pop Os)" \
            "Cutefish                    (Mac Os)" \
            "Deepin                      (Mac Os)" \
            "Gnome                       (Classic linux feel)" \
            "Gnome Flashback             (Gnome 2)" \
            "KDE Plasma                  (Windows feel)" \
            "LXDE                        (Not implemented)" \
            "LXQt                        (Not implemented)" \
            "Mate                        (Gnome 2)" \
            "Pantheon                    (Old school Mac os?)" \
            "XFCE                        (Not implemented)" \
            "Back" \
        )
        menu_prompt DE_choice "$title" "$description" "${options[@]}"
        case $DE_choice in
            0)  install_budgie;;
            1)  install_cinnamon;;
            2)  install_cosmic;;
            3)  install_cutefish;;
            4)  install_deepin;;
            5)  install_gnome;;
            6)  install_gnome_flashback;;
            7)  install_kde_plasma;;
            8)  install_lxde;;
            9)  install_lxqt;;
            10) install_mate;;
            11) install_pantheon;;
            12) install_xfce;;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" 'You did not enter a valid selection.'
        esac
    done
}

WM_selector() {
    commands_to_run=()

    local title="Window manager selection"
    local description="This menu help you install any of 2 very popular Window Managers. Sway and Hyprland. No configs are provided. Sync some with chezmoi if you want later!"

    while true; do
        local options=(\
            "Sway" \
            "Hyprland" \
            "Enlightenment               (Red Hat developed)" \
            "Back" \
        )
        menu_prompt WM_choice "$title" "$description" "${options[@]}"
        case $WM_choice in
            0)  install_sway;;
            1)  install_hyprland;;
            2)  install_enlightenment;;
            b)  break;;
            *)  continue_script 1 "Not a valid choice!" 'You did not enter a valid selection.'
        esac
    done
}
