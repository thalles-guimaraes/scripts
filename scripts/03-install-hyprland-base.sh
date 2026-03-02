#!/bin/bash

# Habilita parada por erro, mas desativaremos temporariamente quando necessário
set -e

echo "========================================="
echo "  SCRIPT DE PÓS-INSTALAÇÃO - HYPRLAND    "
echo "========================================="

# ---------------------------------------------------
# 1. INSTALANDO HYPRLAND (E ECOSSISTEMA)
# ---------------------------------------------------
echo "Instalando Hyprland..."
#sudo pacman -S --needed --noconfirm hyprland kitty firefox waybar hyprpolkitagent hyprpaper dunst nemo xdg-desktop-portal-hyprland wl-clipboard rofi-wayland
#sudo pacman -S --needed --noconfirm hyprland kitty firefox waybar hyprpolkitagent hyprpaper dunst nemo gvfs xdg-desktop-portal-hyprland wl-clipboard rofi-wayland qt5-wayland qt6-wayland grim slurp network-manager-applet #swaync
# configurar gub e deixar bonito no futuro


yay -S --needed --noconfirm hyprland kitty firefox fastfetch nemo gvfs rofi-wayland eog mpv visual-studio-code-bin zsh
# mudar monitor se necessário
# configurar kitty (pasta kitty) (kitten themes)
# configurar gerenciador de arquivos nemo na .config/hypr/hyprland.conf
# configurar o browser na .config/hypr/hyprland.conf
# trocar engine padrão do browser para duckduckgo
# configurar vscode (no futuro simplesmente usar o VIM)
# trocar shell para zsh 

echo "Configurando aplicativos padrão..."

## Define o visualizador de imagens (exemplo usando o programa 'imv')
#xdg-mime default eog.desktop image/jpeg image/png image/gif image/webp

## Define o player de vídeo (exemplo usando o 'mpv')
#xdg-mime default mpv.desktop video/mp4 video/x-matroska video/webm

## Define o navegador padrão (importante para links funcionarem em outros apps)
#xdg-mime default firefox.desktop x-scheme-handler/http x-scheme-handler/https text/html


chsh -s  /usr/bin/zsh
# deslogar para efetivar mudanças

sudo pacman -S --needed --noconfirm zsh-autosuggestions zsh-syntax-highlighting fzf

# configurar font jetbrains-mono-nerd

starship preset nerd-font-symbols -o ~/.config/starship/startship.toml

# alt + c : cd para pasta
# ctrl + p : escolher arquivo 
# ctrl + r : histórico

# configurar o settings.json do vscode 

sudo pacman -S awd-gtk-theme xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-gtk qt6ct qt5ct breeze-icons
# archinstall:  polkit-kdc-agent, xdg-desktop-portal-wayland

# configurar waybar]]

# sddm



# must have: dunst, xdg-desktop-portal-hyprland, hyprpolkitagent, qt5-wayland, qt6-wayland 

# OLHAR UM POR UM OS PACOTES PARA VER COISAS OPCIONAIS, POSSO DEMORAR PRA KRL PQP
# DUNST: Sistema de notificação
# WAYBAR: Barra padrão
# ROFI-WAYLAND : abre programas, tem plugins (calculadora, seletor de emojis, clipboard, menu, etc), temas bons, usa .rasi
# FIREFOX ou ZEN-BROWSER: acho que o zen é melhor
# Kitty: terminal
# GRIM: Screenshot
# SLURP: Screenshot in region
# hyprpaper: papel de parede
# nemo : gerenciador de arquivos (usa gvfs também ) (tem extensões, como o nautilus)
# nautilus: gerenciador de arquivos (também tem extensões uteis)
# thunar: gerenciador de arquivos com extensões
    #extensões (Ações Personalizadas): O superpoder do Thunar é o "Custom Actions". Você pode criar scripts para fazer qualquer coisa (ex: clicar com botão direito e "Abrir no VSCode", "Converter imagem para WebP", "Enviar para o Discord") e adicionar no menu dele.
    #Arquivos de Configuração: Ele guarda as configurações em arquivos de texto (dentro de ~/.config/Thunar/), incluindo as suas Ações Personalizadas (no arquivo uca.xml), então dá para restaurar o seu setup facilmente, embora não seja tão "limpo" quanto o Yazi.
    #Plugins: Suporta plugins oficiais (como o thunar-archive-plugin para extrair zips e o thunar-volman para pendrives).
# Yazi: gerenciador de arquivos no terminal (talvez seja loucura) -> tem plugin pra poha
# cliphist: é um clipboard, legal instalar o 'xdg-utils' para ter acesso ao 
# Code: vscode opensource, usar ele pois vou migrar depois para o nvim



# wl-clipboard  network-manager-applet 
