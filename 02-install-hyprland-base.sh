#!/bin/bash

set -e

timedatectl set-ntp true

# Conectar wifi
nmcli device wifi list

nmcli device wifi connect NOME --ask

# Ping google.com

sudo pacman -Syyu

# Nvidia
# sudo pacman -S nvidia nvidia-utils lib32-nvidia-utils
# configurar esse antes ou depois do hyprland ?

# AMD
sudo pacman -S xf86-video-amdgpu mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon

# pacotes essenciais 
sudo pacman -S btop wget unzip zip bash-completion openssh python fuse2 cmake reflector sof-firmware alsa-utils exfatprogs dosfstools smartmontools tmux 

# Instalando AUR helper
git clone https://aur.archlinux.org/yay.git yay
cd yay
makepkg -si 
cd .. 
rm -rf yay

# Instalar fontes uteis
sudo pacman -S noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-liberation otf-font-awesome ttf-jetbrains-mono ttf-jetbrains-mono-nerd

# Drivers de audio
sudo pacman -S pipewire wireplumber pipewire-audio pipewire-alsa pipewire-jack pipewire-pulse lib32-pipewire pavucontrol

# Bluetooth (se houver)
sudo pacman -S bluez bluez-utils
sudo systemctl enable bluetooth

# Essenciais
sudo pacman -S hyprland kitty firefox


