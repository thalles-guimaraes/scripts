#!/bin/bash

# Habilita parada por erro, mas desativaremos temporariamente quando necessário
set -e

echo "========================================="
echo "  SCRIPT DE PÓS-INSTALAÇÃO - HYPRLAND    "
echo "========================================="

# ---------------------------------------------------
# 6. INSTALANDO HYPRLAND (E ECOSSISTEMA)
# ---------------------------------------------------
echo "Instalando Hyprland..."
sudo pacman -S --needed --noconfirm hyprland kitty firefox waybar hyprpolkitagent hyprpaper dunst hyprlauncher nemo xdg-desktop-portal-hyprland wl-clipboard #rofi-wayland polkit-kde-agent

