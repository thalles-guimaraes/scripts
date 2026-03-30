#!/bin/bash

# Habilita parada por erro, mas desativaremos temporariamente quando necessário
set -e

echo "========================================="
echo "  SCRIPT DE PÓS-INSTALAÇÃO - UTILS    "
echo "========================================="

# ---------------------------------------------------
# 1. VERIFICAÇÃO DE INTERNET
# ---------------------------------------------------
echo "[1/6] Verificando conexão de rede..."

if ! ping -c 1 google.com &> /dev/null; then
    echo "[!] Sem internet detectada."
    
    set +e 
    read -p "Deseja conectar ao Wi-Fi agora? (s/n): " CONECTAR_WIFI
    
    if [[ "${CONECTAR_WIFI,,}" == "s" ]]; then
        nmcli device wifi list
        read -p "Digite o SSID (Nome exato da rede): " WIFI_SSID
        nmcli device wifi connect "$WIFI_SSID" --ask
    else
        echo "Conexão com a internet é obrigatória. Saindo..."
        exit 1
    fi
    set -e 
fi
echo "-> Internet OK!"

# ---------------------------------------------------
# 2. ATUALIZAÇÃO E SINCRONIZAÇÃO
# ---------------------------------------------------
echo "[2/6] Sincronizando repositórios..."
sudo pacman -Syyuu --noconfirm

# ---------------------------------------------------
# 3. PACOTES ESSENCIAIS E ÁUDIO
# ---------------------------------------------------
echo "[3/6] Instalando ferramentas base, fontes e PipeWire..."
sudo pacman -S --needed --noconfirm \
    base-devel git btop wget unzip zip bash-completion openssh python fuse2 cmake \
    reflector sof-firmware alsa-utils exfatprogs dosfstools smartmontools tmux \
    pipewire wireplumber pipewire-audio pipewire-alsa pipewire-jack pipewire-pulse \
    lib32-pipewire pavucontrol noto-fonts noto-fonts-emoji noto-fonts-cjk \
    ttf-liberation otf-font-awesome ttf-jetbrains-mono ttf-jetbrains-mono-nerd xdg-user-dirs \
    network-manager-applet foot thunar-archive-plugin

# ---------------------------------------------------
# 4. AUR HELPER (YAY) - MOVIDO PARA CIMA!
# ---------------------------------------------------
echo "[4/6] Instalando YAY (Necessário para drivers Legacy da NVIDIA)..."
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git yay-build
    cd yay-build
    makepkg -si --noconfirm
    cd ..
    rm -rf yay-build
else
    echo "-> YAY já está instalado!"
fi

# ---------------------------------------------------
# 5. DETECÇÃO DE HARDWARE (AGORA COM YAY DISPONÍVEL)
# ---------------------------------------------------
echo "[5/6] Detectando Hardware Específico..."

# Verifica GPU
if lspci | grep -iE 'vga|3d' | grep -iq 'nvidia'; then
    echo "-> Placa NVIDIA detectada (Desktop)."
    # Usando o YAY para baixar a versão 580xx do AUR
    yay -S --needed --noconfirm nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils egl-wayland
    
    echo "--------------------------------------------------------"
    echo "⚠️ ATENÇÃO USUÁRIO NVIDIA ⚠️"
    echo "Após o script, adicione 'nvidia_drm.modeset=1' na linha"
    echo "GRUB_CMDLINE_LINUX_DEFAULT do seu /etc/default/grub"
    echo "e rode: sudo grub-mkconfig -o /boot/grub/grub.cfg"
    echo "--------------------------------------------------------"
    sleep 3

elif lspci -vnn | grep -iE 'VGA|3D' | grep -iq 'Radeon\|AMD'; then
    echo "-> GPU AMD detectada (Notebook)."
    sudo pacman -S --needed --noconfirm mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
fi

# Verifica Bluetooth
if dmesg | grep -iq bluetooth || lsusb | grep -iq bluetooth || lspci | grep -iq bluetooth; then
    echo "-> Adaptador Bluetooth detectado (Instalando bluez)."
    sudo pacman -S --needed --noconfirm bluez bluez-utils blueman
    sudo systemctl enable bluetooth
else
    echo "-> Nenhum Bluetooth físico detectado. Pulando..."
fi


xdg-user-dirs-update

echo "========================================="
echo " INSTALAÇÃO CONCLUÍDA COM SUCESSO!       "
echo " Lembre-se de configurar o GRUB se for NVIDIA. "
echo "========================================="