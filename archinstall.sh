#!/bin/bash

# Habilita a parada imediata se algum comando falhar
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

# ==========================================
# 1. VERIFICAÇÕES INICIAIS (PRE-FLIGHT)
# ==========================================

echo "--------------------------------"
echo "  INSTALADOR ARCH LINUX (DRY)   "
echo "--------------------------------"

if [ "$(id -u)" -ne 0 ]; then
    echo "[ERRO] Execute o script como root."
    exit 1
fi

if [ ! -d /sys/firmware/efi ]; then
    echo "[ERRO] Sistema NÃO está em modo UEFI. Abortando."
    exit 1
fi

echo "Verificando conexão com a internet..."
if ! ping -c 1 archlinux.org &> /dev/null; then
    echo "[ERRO] Sem conexão com a internet. Conecte-se e tente novamente."
    exit 1
fi
echo "Internet OK!"

timedatectl set-ntp true

# ==========================================
# 2. DEFINIÇÃO DE FUNÇÕES GERAIS
# ==========================================

otimizar_pacman() {
    echo "--------------------------------"
    echo "  Otimizando Pacman e Mirrors   "
    echo "--------------------------------"
    sed -i 's/^#Color/Color/' /etc/pacman.conf
    sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
    sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
    sed -i 's/^#CheckSpace/CheckSpace/' /etc/pacman.conf
    sed -i 's/^#* *ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf
    sed -i '/^\#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf

    reflector --country Brazil --latest 5 --age 24 --protocol https --sort rate --verbose --save /etc/pacman.d/mirrorlist
}

instalar_base_e_chroot() {
    echo "--------------------------------"
    echo "  Instalando Sistema Base       "
    echo "--------------------------------"
    
    # Detectar microcode
    CPU_VENDOR=$(lscpu | grep Vendor | awk '{print $3}')
    if [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
        UCODE="amd-ucode"
    else
        UCODE="intel-ucode"
    fi

    # Pacstrap com pacotes essenciais (inclui os-prober e ntfs-3g para dual boot)
    pacstrap -K /mnt base linux linux-firmware linux-headers base-devel sudo nano networkmanager grub efibootmgr os-prober ntfs-3g $UCODE git man-db man-pages texinfo vim

    echo "Copiando pacman.conf otimizado..."
    cp /etc/pacman.conf /mnt/etc/pacman.conf

    echo "Gerando fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab

    echo "--------------------------------"
    echo "  Configuração Interna (Chroot) "
    echo "--------------------------------"
    
    # Chroot não interativo para configurações gerais
    arch-chroot /mnt /bin/bash <<EOF
    
    ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
    # Usando a variável CLOCK_OPTS definida nas funções de particionamento
    hwclock --systohc $CLOCK_OPTS

    sed -i 's/^#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen

    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    echo "KEYMAP=br-abnt2" > /etc/vconsole.conf
    echo archbtw > /etc/hostname

    echo "127.0.1.1 archbtw.localdomain archbtw" >> /etc/hosts

    useradd -m -G wheel -s /bin/bash thalles
    echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
    chmod 440 /etc/sudoers.d/wheel

    systemctl enable NetworkManager

    # Configuração do GRUB com suporte a outros sistemas (Dual Boot)
    echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
    
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
EOF
}

configurar_senhas() {
    echo "--------------------------------"
    echo "  Definição de Senhas           "
    echo "--------------------------------"
    
    # Desativa a parada por erro temporariamente
    set +e 

    echo "-> Senha do ROOT:"
    # O loop continua rodando enquanto o comando passwd falhar
    while ! arch-chroot /mnt passwd; do
        echo "[!] As senhas não coincidem ou ocorreu um erro. Tente novamente."
        sleep 1
    done

    echo "-> Senha do usuário THALLES:"
    while ! arch-chroot /mnt passwd thalles; do
        echo "[!] As senhas não coincidem ou ocorreu um erro. Tente novamente."
        sleep 1
    done

    # Reativa a parada por erro para o restante do script
    set -e
}

# ==========================================
# 3. FUNÇÕES DE PARTICIONAMENTO
# ==========================================

particionar_single_boot() {
    echo "--------------------------------"
    echo " MODO SINGLE BOOT (APAGA TUDO)  "
    echo "--------------------------------"
    lsblk -d -o NAME,SIZE,MODEL
    
    set +e
    read -p "Digite o dispositivo para APAGAR (ex: /dev/sda ou /dev/nvme0n1): " DEVICE
    read -p "Tem certeza absoluta? TODOS OS DADOS EM $DEVICE SERÃO PERDIDOS (yes/NO): " CONFIRM
    set -e

    if [[ "$CONFIRM" != "yes" ]] || [ ! -b "$DEVICE" ]; then
        echo "Operação cancelada ou dispositivo inválido."
        exit 1
    fi

    # Detectar sufixo (NVMe vs SATA)
    if [[ "$DEVICE" =~ [0-9]$ ]]; then PART_PREFIX="${DEVICE}p"; else PART_PREFIX="${DEVICE}"; fi

    wipefs -a "$DEVICE"
    parted -s "$DEVICE" mklabel gpt
    parted -s "$DEVICE" mkpart ESP fat32 1MiB 1025MiB
    parted -s "$DEVICE" set 1 esp on
    parted -s "$DEVICE" mkpart primary linux-swap 1025MiB 17409MiB
    parted -s "$DEVICE" mkpart primary ext4 17409MiB 100%

    mkfs.fat -F 32 "${PART_PREFIX}1"
    mkswap "${PART_PREFIX}2"
    mkfs.ext4 "${PART_PREFIX}3"

    mount "${PART_PREFIX}3" /mnt
    mount --mkdir "${PART_PREFIX}1" /mnt/boot
    swapon "${PART_PREFIX}2"
    
    # Linux puro usa UTC no relógio da placa mãe
    CLOCK_OPTS=""
}

particionar_dual_boot() {
    echo "--------------------------------"
    echo " MODO DUAL BOOT (PRESERVA DADOS)"
    echo "--------------------------------"
    
    # 1. Mostra os discos disponíveis primeiro
    echo "Discos disponíveis no sistema:"
    lsblk -d -o NAME,SIZE,MODEL
    echo "--------------------------------"
    
    set +e
    read -p "Voce precisa criar ou redimensionar partições agora? (s/N): " CRIAR_PART
    
    if [[ "${CRIAR_PART,,}" == "s" ]]; then
        read -p "Digite o disco que deseja particionar (ex: /dev/sda ou /dev/nvme0n1): " DISCO_ALVO
        if [ -b "$DISCO_ALVO" ]; then
            # Abre o cfdisk para o usuário gerenciar as partições
            cfdisk "$DISCO_ALVO"
            echo "Aguardando o sistema reconhecer as novas partições..."
            sleep 2
        else
            echo "[ERRO] Disco inválido ou não encontrado. Abortando."
            exit 1
        fi
    fi
    set -e

    echo "--------------------------------"
    echo " Lista atualizada de partições: "
    lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
    echo "--------------------------------"
    echo "[!] Digite os caminhos exatos das partições que você separou para o Arch."
    
    set +e
    read -p "Partição EFI existente (ex: /dev/sda1): " EFI_PART
    read -p "Nova partição ROOT p/ o Arch (ex: /dev/sda6): " ROOT_PART
    read -p "Nova partição SWAP (deixe em branco se não houver): " SWAP_PART
    set -e

    if [ ! -b "$EFI_PART" ] || [ ! -b "$ROOT_PART" ]; then
        echo "[ERRO] Partições obrigatórias (EFI ou ROOT) inválidas. Abortando."
        exit 1
    fi

    echo "Formatando apenas ROOT e SWAP..."
    mkfs.ext4 -F "$ROOT_PART"
    
    if [ -n "$SWAP_PART" ] && [ -b "$SWAP_PART" ]; then
        mkswap "$SWAP_PART"
        swapon "$SWAP_PART"
    fi

    mount "$ROOT_PART" /mnt
    # APENAS MONTA A EFI, NÃO FORMATA PARA NÃO QUEBRAR O WINDOWS!
    mount --mkdir "$EFI_PART" /mnt/boot 
    
    # Windows usa tempo local na placa-mãe. Isso evita bugs de hora no Dual Boot.
    CLOCK_OPTS="--localtime"
}

# ==========================================
# 4. LÓGICA PRINCIPAL (MENU DE ESCOLHA)
# ==========================================

# Tenta detectar se já existe um Windows ou EFI no PC para alertar o usuário
if fdisk -l | grep -qi "Microsoft basic data\|EFI"; then
    echo "[AVISO] Uma partição EFI ou do Windows foi detectada no sistema."
    SUGESTAO_DEFAULT="2"
else
    SUGESTAO_DEFAULT="1"
fi

echo "Escolha o modo de instalação:"
echo "1) Single Boot (Formatar e apagar um disco inteiro)"
echo "2) Dual Boot (Usar partições existentes ao lado do Windows)"

read -p "Digite sua opção (Padrão sugerido: $SUGESTAO_DEFAULT): " OPCAO
OPCAO=${OPCAO:-$SUGESTAO_DEFAULT}

otimizar_pacman

if [ "$OPCAO" == "1" ]; then
    particionar_single_boot
elif [ "$OPCAO" == "2" ]; then
    particionar_dual_boot
else
    echo "Opção inválida. Saindo."
    exit 1
fi

instalar_base_e_chroot
configurar_senhas

# Desmontagem final
echo "--------------------------------"
echo "  Finalizando...                "
echo "--------------------------------"
umount -R /mnt
swapoff -a || true

echo "Instalação concluída com sucesso! Digite 'reboot' para iniciar seu novo sistema."
