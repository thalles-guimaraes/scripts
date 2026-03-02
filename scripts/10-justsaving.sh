#!/bin/bash

# Habilita parada por erro
set -e

echo "========================================="
echo "  SCRIPT DE PÓS-INSTALAÇÃO - HYPRLAND    "
echo "========================================="

# ---------------------------------------------------
# 1. INSTALANDO HYPRLAND (E ECOSSISTEMA)
# ---------------------------------------------------
echo "[1/4] Instalando ambiente gráfico e ferramentas..."

# É boa prática usar o pacman para os repositórios oficiais:
sudo pacman -S --needed --noconfirm hyprland kitty firefox waybar hyprpolkitagent hyprpaper dunst nemo gvfs xdg-desktop-portal-hyprland wl-clipboard rofi-wayland qt5-wayland qt6-wayland eog mpv zsh fastfetch

# E usar o YAY apenas para o que for do AUR:
yay -S --needed --noconfirm visual-studio-code-bin

# ---------------------------------------------------
# 2. CONFIGURANDO DOTFILES (LINKS SIMBÓLICOS)
# ---------------------------------------------------
echo "[2/4] Aplicando suas configurações (Dotfiles)..."

# Garante que a pasta config existe
mkdir -p ~/.config

# Exclui as pastas padrão caso existam, para não dar conflito com os links
rm -rf ~/.config/kitty ~/.config/hypr ~/.config/waybar ~/.config/rofi ~/.zshrc

# Cria os links simbólicos apontando para o seu repositório local
# (Substitua "~/suas-dotfiles" pelo caminho real da pasta do seu repositório clone)
DOTFILES_DIR="$HOME/suas-dotfiles"

ln -sf "$DOTFILES_DIR/hypr" ~/.config/hypr
ln -sf "$DOTFILES_DIR/kitty" ~/.config/kitty
ln -sf "$DOTFILES_DIR/waybar" ~/.config/waybar
ln -sf "$DOTFILES_DIR/rofi" ~/.config/rofi
ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc

# ---------------------------------------------------
# 3. APLICATIVOS PADRÃO
# ---------------------------------------------------
echo "[3/4] Configurando aplicativos padrão..."

xdg-mime default eog.desktop image/jpeg image/png image/gif image/webp
xdg-mime default mpv.desktop video/mp4 video/x-matroska video/webm
xdg-mime default firefox.desktop x-scheme-handler/http x-scheme-handler/https text/html

# ---------------------------------------------------
# 4. TROCANDO SHELL PARA ZSH
# ---------------------------------------------------
echo "[4/4] Alterando shell padrão para o ZSH..."
sudo usermod -s /usr/bin/zsh "$USER"

echo "========================================="
echo " HYPRLAND INSTALADO E CONFIGURADO!       "
echo " Por favor, reinicie o computador para   "
echo " aplicar a mudança para o ZSH.           "
echo "========================================="