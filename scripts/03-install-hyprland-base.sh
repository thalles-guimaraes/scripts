#!/bin/bash

set -e

echo "========================================="
echo "  SCRIPT DE PÓS-INSTALAÇÃO - HYPRLAND    "
echo "========================================="
echo "Atualizando repositórios..."
sudo pacman -Syu --noconfirm
# ------------------
# MUST HAVE  
# ------------------
echo "Instalando Hyprland, software essenciais e habilitando serviços..."
sudo pacman -S --noconfirm hyprland sddm dunst xdg-desktop-portal-hyprland hyprpolkitagent \
 qt5-wayland qt6-wayland alacritty qt6-svg qt6-declarative qt5-quickcontrols2 unzip
sudo systemctl enable sddm.service


# ------------------
# RECOMENDADOS
# ------------------
echo "Instalando software uteis e configurando..."
sudo pacman -S --noconfirm waybar hyprpaper rofi-wayland xdg-utils \
 cliphist thunar  grim slurp yazi fastfetch firefox eog mpv \
 starship zsh-autosuggestions zsh-syntax-highlighting fzf \
 adw-gtk-theme qt6ct qt5ct kvantum breeze-icons obsidian hypridle hyprlock

yay -S --noconfirm visual-studio-code-bin vesktop-bin systemd-numlockontty rofi-wifi

sudo systemctl enable numLockOnTty

# ------------------
# CONFIGURANDO TUDO
# ------------------
echo "Configurando dotfiles..."

mkdir -p ~/.config
mkdir -p ~/.config/Code/User
mkdir -p ~/Pictures

rm -rf ~/.config/hypr ~/.config/waybar ~/.config/rofi ~/.config/yazi ~/.config/alacritty

ln -sfn ~/dotfiles/.config/hypr ~/.config/hypr
ln -sfn ~/dotfiles/.config/alacritty ~/.config/alacritty
ln -sf ~/dotfiles/.config/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.config/starship.toml ~/.config/starship.toml
ln -sf ~/dotfiles/.config/Code/User/settings.json ~/.config/Code/User/settings.json
ln -sfn ~/dotfiles/.config/waybar ~/.config/waybar
ln -sfn ~/dotfiles/wallpaper ~/Pictures/wallpaper
ln -sfn ~/dotfiles/.config/rofi ~/.config/rofi
ln -sfn ~/dotfiles/.config/yazi ~/.config/yazi

sudo unzip ~/dotfiles/usr/share/sddm/themes/catppuccin-frappe-mauve-sddm.zip -d /usr/share/sddm/themes/
sudo ln -sf ~/dotfiles/etc/sddm.conf /etc/sddm.conf

code --install-extension Catppuccin.catppuccin-vsc || true

echo "========================================="
echo " INSTALAÇÃO CONCLUÍDA COM SUCESSO!       "
echo " Digite 'start-hyprland' para iniciar.   "
echo " Ou reinicie o computador                "
echo "========================================="


# TROCAR GOOGLE para DUCKDUCKGO no firefox
# ADICIONAR O TODOIST para abrir automaticamente no firefox!! --> duck duck go
# Para tema no firefox: https://github.com/catppuccin/firefox?tab=readme-ov-file
# congigurar SSD para github para que eu possa baixar o obsidian
# Tema: catppuccin frappê pink: para o firefox
# arrumar vesktop tema