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

################################################################################
# TTY DM
################################################################################


install_ly() {
    commands_to_run+=("pacman --noconfirm -S ly")
    commands_to_run+=("systemctl enable ly.service")
    live_command_output "" "" "Installing selected TTY DM: Ly" "${commands_to_run[@]}"
}

install_tbsm() {
    commands_to_run+=("echo'Not yet implemented, but shall "snp paru -S tbsm"'")
    live_command_output "" "" "Installing selected TTY DM: Tbsm" "${commands_to_run[@]}"
}

install_emptty() {
    commands_to_run+=("echo'Not yet implemented, but shall "pacman --noconfirm -S emptty"'")
    live_command_output "" "" "Installing selected TTY DM: Emptty" "${commands_to_run[@]}"
}

install_lemurs() {
    commands_to_run+=("pacman --noconfirm -S lemurs")
    commands_to_run+=("systemctl enable lemurs.service")
    live_command_output "" "" "Installing selected TTY DM: Lemurs" "${commands_to_run[@]}"
}

################################################################################
# GUI DM
################################################################################

install_gdm() {
    commands_to_run+=("pacman --noconfirm -S gdm")
    commands_to_run+=("systemctl enable gdm.service")
    live_command_output "" "" "Installing selected GUI DM: GDM" "${commands_to_run[@]}"
}

install_lightdm() {
    commands_to_run+=("pacman --noconfirm -S lightdm")
    commands_to_run+=("systemctl enable lightdm.service")
    live_command_output "" "" "Installing selected GUI DM: LightDM" "${commands_to_run[@]}"
}

install_sddm() {
    commands_to_run+=("pacman --noconfirm -S sddm")
    commands_to_run+=("systemctl enable sddm.service")
    live_command_output "" "" "Installing selected GUI DM: SDDM" "${commands_to_run[@]}"
}

install_greetd() {
    commands_to_run+=("pacman --noconfirm -S greetd")
    commands_to_run+=("systemctl enable greetd.service")
    live_command_output "" "" "Installing selected GUI DM: Greetd" "${commands_to_run[@]}"
}

################################################################################
# DE
################################################################################

install_budgie() {
    commands_to_run+=("pacman --noconfirm -S budgie lightdm-gtk-greeter budgie-desktop-view budgie-backgrounds network-manager-applet arc-gtk-theme papirus-icon-theme")
    live_command_output "" "" "installing selected Desktop Environment: Budgie" "${commands_to_run[@]}"
}

install_cinnamon() {
    commands_to_run+=("pacman --noconfirm -S cinnamon xed xreader metacity gnome-shell gnome-keyring")
    live_command_output "" "" "installing selected Desktop Environment: Cinnamon" "${commands_to_run[@]}"
}

install_cosmic() {
    commands_to_run+=("pacman --noconfirm -S cosmic cosmic-text-editor cosmic-files cosmic-terminal cosmic-wallpapers")
    live_command_output "" "" "installing selected Desktop Environment: Cosmic" "${commands_to_run[@]}"
}

install_cutefish() {
    commands_to_run+=("pacman --noconfirm -S cutefish sddm")
    live_command_output "" "" "installing selected Desktop Environment: Cutefish" "${commands_to_run[@]}"
}

install_deepin() {
    commands_to_run+=("pacman --noconfirm -S deepin deepin-kwin deepin-extra")
    live_command_output "" "" "installing selected Desktop Environment: Deepin" "${commands_to_run[@]}"
}

install_gnome() {
    commands_to_run+=("pacman --noconfirm -S gnome gdm")
    live_command_output "" "" "installing selected Desktop Environment: Gnome" "${commands_to_run[@]}"
}

install_gnome_flashback() {
    commands_to_run+=("pacman --noconfirm -S gnome-flashback gnome-applets sensors-applet gdm")
    live_command_output "" "" "installing selected Desktop Environment: Gnome flashback" "${commands_to_run[@]}"
}

install_kde_plasma() {
    commands_to_run+=("pacman --noconfirm -S plasma kde-applications-meta sddm")
    live_command_output "" "" "installing selected Desktop Environment: KDE-Plasma" "${commands_to_run[@]}"
}

install_lxde() {
    commands_to_run+=("echo'Not yet implemented because its x11 only for now, but shall "pacman --noconfirm -S lxde"'")
    live_command_output "" "" "installing selected Desktop Environment: LXDE" "${commands_to_run[@]}"
}

install_lxqt() {
    commands_to_run+=("echo'Not yet implemented because its x11 only for now, but shall "pacman --noconfirm -S lxqt"'")
    live_command_output "" "" "installing selected Desktop Environment: LXQT" "${commands_to_run[@]}"
}

install_mate() {
    commands_to_run+=("pacman --noconfirm -S mate mate-extra lightdm")
    live_command_output "" "" "installing selected Desktop Environment: Mate" "${commands_to_run[@]}"
}

install_pantheon() {
    commands_to_run+=("pacman --noconfirm -S pantheon lightdm")
    live_command_output "" "" "installing selected Desktop Environment: Pantheon" "${commands_to_run[@]}"
}

install_xfce() {
    commands_to_run+=("echo'Not yet implemented because its x11 only for now, but shall "pacman --noconfirm -S xfce"'")
    live_command_output "" "" "installing selected Desktop Environment: XFCE" "${commands_to_run[@]}"
}

################################################################################
# WM
################################################################################

install_sway() {
    commands_to_run+=("pacman --noconfirm -S sway kitty brightnessctl")
    live_command_output "" "" "Installing selected Window Manager: Sway" "${commands_to_run[@]}"
}

install_hyprland() {
    commands_to_run+=("pacman --noconfirm -S brightnessctlhyprland hypridle xdg-desktop-portal-hyprland brightnessctl kitty waybar rofi-wayland rofi-calc")
    live_command_output "" "" "Installing selected Window Manager: Hyprland" "${commands_to_run[@]}"
}

install_enlightenment() {
    commands_to_run+=("pacman --noconfirm -S enlightenment ecrire ephoto evisum rage terminology connman brightnessctl")
    live_command_output "" "" "Installing selected Window Manager: Enlightenment" "${commands_to_run[@]}"
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
            *)  continue_script "Not a valid choice!" 'You did not enter a valid selection.'
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
            *)  continue_script "Not a valid choice!" 'You did not enter a valid selection.'
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
            *)  continue_script "Not a valid choice!" 'You did not enter a valid selection.'
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
            *)  continue_script "Not a valid choice!" 'You did not enter a valid selection.'
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
            *)  continue_script "Not a valid choice!" 'You did not enter a valid selection.'
        esac
    done
}

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
            *)  continue_script "Not a valid choice!" "Invalid choice, please try again." ;;
        esac
    done
}