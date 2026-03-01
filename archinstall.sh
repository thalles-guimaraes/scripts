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


#--------------
# COM INTERNET
#--------------
# timedatectl > verificar se hora está correta no UTC
echo "--------------------------------"
echo "     Bem vindo ao SCRIPT "
echo "     De instalação do arch "
echo "--------------------------------"

if [ "$(id -u)" -ne 0 ]; then
    echo "Execute como root."
    exit 1
fi

if [ ! -d /sys/firmware/efi ]; then
    echo "Sistema NÃO está em modo UEFI. Abortando."
    exit 1
fi


timedatectl set-ntp true # para atualizar
echo "Dispositivos disponíveis:"
lsblk -d -o NAME,SIZE,MODEL

read -p "Digite o caminho do seu block device (ex: /dev/sda ou /dev/nvme0n1): " DEVICE
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
echo "     ATUALIZANDO PACMAN.CONF    "
echo "--------------------------------"

sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
sed -i 's/^#CheckSpace/CheckSpace/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = .*/ParallelDownloads = 10/' /etc/pacman.conf
sed -i '/^\#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf

echo "--------------------------------"
echo "   Atualizando mirrorlist...   "
echo "--------------------------------"
reflector --country Brazil --latest 5 --age  24 --protocol https --sort rate --verbose --save /etc/pacman.d/mirrorlist

# -- PARTICIONAMENTO --  
# config recomendada (fdisk -l /dev/sda): 
# /dev/seuDisco1 para EFI
# /dev/seuDisco2 para SWAP
# /dev/seuDisco3 para o /




echo "---------------------------"
echo "   PARTICIONANDO DISCO"
echo " ATENÇÃO: TODOS OS DADOS"
echo "      SERÃO APAGADOS"
echo "---------------------------"
read -p "Confirma? (yes/NO): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Abortando..."
    exit 1
fi
wipefs -a "$DEVICE" # apagar disco
parted -s "$DEVICE" mklabel gpt # cria tabela gpt
parted -s "$DEVICE" mkpart ESP fat32 1MiB 1025MiB # cria partição EFI (ESP é o nome) com inicio em 1MiB e fim em 1024Mib (1G)
parted -s "$DEVICE" set 1 esp on # marca a partição como EFI
parted -s "$DEVICE" mkpart primary linux-swap 1025MiB 17409MiB # cria swap com 16G 
parted -s "$DEVICE" mkpart primary ext4 17409MiB 100% # usa o resto do hd para o /


echo "--------------------------------"
echo "   Formatando partições...   "
echo "--------------------------------"
mkfs.fat -F 32 "${PART_PREFIX}1" # formatar o efi com fat32
mkswap "${PART_PREFIX}2" # criar swap
mkfs.ext4 "${PART_PREFIX}3" # formatar o / com ext4
# se quiser checar basta rodar lsblk -f

echo "--------------------------------"
echo "   Montando sistema...   "
echo "--------------------------------"
mount "${PART_PREFIX}3" /mnt #montando o /
mount --mkdir "${PART_PREFIX}1" /mnt/boot #montando /boot e efi
swapon "${PART_PREFIX}2" #ligar swarp
# se quiser checar, lsblk vai mostrar


# ------------------------
# Detectar microcode
# ------------------------
CPU_VENDOR=$(lscpu | grep Vendor | awk '{print $3}')
if [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
    UCODE="amd-ucode"
else
    UCODE="intel-ucode"
fi

# ------------------------
# Instalar sistema base
# ------------------------
pacstrap -K /mnt base linux linux-firmware linux-headers base-devel sudo nano networkmanager grub efibootmgr os-prober $UCODE git man-db man-pages texinfo vim
genfstab -U /mnt >> /mnt/etc/fstab

# ------------------------
# Configuração dentro do chroot
# ------------------------

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

echo "Defina senha do root:"
passwd

echo "Defina senha do usuário thalles:"
passwd thalles

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

systemctl enable NetworkManager

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

EOF

umount -R /mnt
echo "Instalação concluída. Reinicie."



# -- PARTICIONAMENTO MANUAL (Tentar não usar isso) --
# Começe com G para criar a tabela gpt
# 1G de ESP (EFI): n, number default, first default, last +1G, t 'uefi'
# 16G de Swap: n, number default, first default, last +16G, t, 2 'swap'
# Resto com / : n, enter, enter, enter
# Salve com W, tudo feito


# fdisk -l #verificar nome do meu block device, provavelmente /dev/sda ou /dev/nvme0n1

# editar o pacman.conf para ser mais rapido, lembrando que tudo feito aqui vai para o sistema original também
# /etc/pacman.conf
# adicionar:
#Color
#ILoveCandy
#ParallelDownloads = 10
#VerbosePkgLists
#CheckSpace
# -- IMPORTANTE: Descomentar 2 linhas do multilib