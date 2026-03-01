#!/bin/bash
set -e

#--------------
# SEM INTERNET (antes do script)
# - Setar teclado
# - Setar fonte 
# - Conectar internet
#--------------
# loadkeys br-abnt2 #ou 'us' para teclado americano 
# setfont ter-132b
# ping archlinux.org #verificar internet primeiro
# para wifi usar 'IWCTL' 

echo "--------------------------------"
echo "    Bem vindo ao SCRIPT "
echo "    De instalação do arch "
echo "--------------------------------"

# 1. Verificação de Root
if [ "$(id -u)" -ne 0 ]; then
    echo "Execute como root."
    exit 1
fi

# 2. Verificação de UEFI
if [ ! -d /sys/firmware/efi ]; then
    echo "Sistema NÃO está em modo UEFI. Abortando."
    exit 1
fi

# 3. Verificação de Internet (Nova Melhoria)
echo "Verificando conexão com a internet..."
if ! ping -c 1 archlinux.org &> /dev/null; then
    echo "Sem conexão com a internet. Conecte-se (via cabo ou wifi-menu/iwctl) e tente novamente."
    exit 1
fi
echo "Internet OK!"

timedatectl set-ntp true # para atualizar a hora

echo "--------------------------------"
echo "Dispositivos disponíveis:"
lsblk -d -o NAME,SIZE,MODEL
echo "--------------------------------"

# Desabilitar o 'set -e' temporariamente para o read não quebrar se o usuário der Ctrl+C de forma estranha
set +e
read -p "Digite o caminho do seu block device (ex: /dev/sda ou /dev/nvme0n1): " DEVICE
set -e

if [ ! -b "$DEVICE" ]; then
    echo "Device inválido."
    exit 1
fi

echo "Seu caminho é: '$DEVICE'"

# Detectar sufixo de partição (NVMe usa 'p')
if [[ "$DEVICE" =~ [0-9]$ ]]; then
    PART_PREFIX="${DEVICE}p"
else
    PART_PREFIX="${DEVICE}"
fi

echo "--------------------------------"
echo "    ATUALIZANDO PACMAN.CONF     "
echo "--------------------------------"

# Otimizações do pacman no sistema Live (Pendrive)
sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
sed -i 's/^#CheckSpace/CheckSpace/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = .*/ParallelDownloads = 10/' /etc/pacman.conf
sed -i '/^\#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf

echo "--------------------------------"
echo "  Atualizando mirrorlist...     "
echo "--------------------------------"
reflector --country Brazil --latest 5 --age 24 --protocol https --sort rate --verbose --save /etc/pacman.d/mirrorlist

# -- PARTICIONAMENTO --  
echo "---------------------------"
echo "   PARTICIONANDO DISCO"
echo " ATENÇÃO: TODOS OS DADOS"
echo "      SERÃO APAGADOS"
echo "---------------------------"

set +e
read -p "Confirma? (yes/NO): " CONFIRM
set -e

if [[ "$CONFIRM" != "yes" ]]; then
    echo "Abortando..."
    exit 1
fi

echo "Apagando disco e criando partições..."
wipefs -a "$DEVICE" # apagar assinaturas antigas do disco
parted -s "$DEVICE" mklabel gpt # cria tabela gpt
parted -s "$DEVICE" mkpart ESP fat32 1MiB 1025MiB # cria partição EFI (1G)
parted -s "$DEVICE" set 1 esp on # marca a partição como EFI
parted -s "$DEVICE" mkpart primary linux-swap 1025MiB 17409MiB # cria swap com 16G 
parted -s "$DEVICE" mkpart primary ext4 17409MiB 100% # usa o resto do hd para o /

echo "--------------------------------"
echo "  Formatando partições...       "
echo "--------------------------------"
mkfs.fat -F 32 "${PART_PREFIX}1" # formatar o efi com fat32
mkswap "${PART_PREFIX}2" # criar swap
mkfs.ext4 "${PART_PREFIX}3" # formatar o / com ext4

echo "--------------------------------"
echo "  Montando sistema...           "
echo "--------------------------------"
mount "${PART_PREFIX}3" /mnt #montando o /
mount --mkdir "${PART_PREFIX}1" /mnt/boot #montando /boot (EFI)
swapon "${PART_PREFIX}2" #ligar swap

# ------------------------
# Detectar microcode
# ------------------------
CPU_VENDOR=$(lscpu | grep Vendor | awk '{print $3}')
if [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
    UCODE="amd-ucode"
else
    UCODE="intel-ucode"
fi

echo "--------------------------------"
echo " Instalando sistema base...     "
echo "--------------------------------"
pacstrap -K /mnt base linux linux-firmware linux-headers base-devel sudo nano networkmanager grub efibootmgr os-prober $UCODE git man-db man-pages texinfo vim

# 4. Copiar o pacman.conf otimizado para o novo sistema (Nova Melhoria)
echo "Copiando pacman.conf otimizado para o novo sistema..."
cp /etc/pacman.conf /mnt/etc/pacman.conf

echo "Gerando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "--------------------------------"
echo " Configuração dentro do chroot  "
echo "--------------------------------"

# Entrando no chroot de forma não interativa para as configurações gerais
arch-chroot /mnt /bin/bash <<EOF

ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc

sed -i 's/^#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=br-abnt2" > /etc/vconsole.conf

echo archbtw > /etc/hostname

echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 archbtw.localdomain archbtw" >> /etc/hosts

useradd -m -G wheel -s /bin/bash thalles

# 5. Modo seguro de dar permissão ao grupo wheel (Nova Melhoria)
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

systemctl enable NetworkManager

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

EOF

# 6. Configuração de senhas (FORA DO Here-Doc - Correção do seu problema)
echo "--------------------------------"
echo " Defina a senha do ROOT:"
echo "--------------------------------"
arch-chroot /mnt passwd

echo "--------------------------------"
echo " Defina a senha do usuário thalles:"
echo "--------------------------------"
arch-chroot /mnt passwd thalles

echo "--------------------------------"
echo " Finalizando instalação...      "
echo "--------------------------------"
umount -R /mnt
swapoff -a
echo "Instalação concluída com sucesso! Você já pode reiniciar (digite 'reboot')."
