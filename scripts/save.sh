
# ------------------
# MUST HAVE  
# ------------------
# sddm: configurar ele primeiro, precisa ativar o serviço
    # sudo systemctl enable sddm.service
# DUNST: Sistema de notificação : automatico
# xdg-desktop-portal-hyprland: aplicações se comunicarem : automatico
# hyprpolkitagent : polkit daemon para elevar privilegios : adicionar>  exec-once = systemctl --user start hyprpolkitagent (HYPRLAND)
# qt5-wayland E qt6-wayland : suporta a QT : automatico, bibliotecas
# allacrity: emulador de terminal muito bom : precisa trocar no hyprland.conf para usar ele no lugar do kitty
# duvida: se eu não rodar o hyprland, ele cria a pasta no .conf ? e se eu criar a pasta antes, ele vai sobrescrever?

# ------------------
# RECOMENDADOS
# ------------------
# ADICIONAR PERGUNTA PARA O USUÁRIO SE ELE QUER PASSAR POR ESSA PARTE
# WAYBAR: Barra padrão : exec-once = waybar
# hyprpaper: papel de parede : exec-once = hyprpaper
# ROFI-WAYLAND : abre programas, tem plugins (calculadora, seletor de emojis, clipboard, menu, etc), temas bons, usa .rasi : TROCAR $menu para rofi no hyprland.conf 
# Vesktop : discord que da pra trocar cor e É WAYLAND
# cliphist: é um clipboard, legal instalar o 'xdg-utils', ja instala o 'wl-clipboard' : exec-once OBS: Da pra usar com o rofi de algum jeito
# firefox: browser, mucho bom
# thunar: gerenciador de arquivos com extensões
    #extensões (Ações Personalizadas): O superpoder do Thunar é o "Custom Actions". Você pode criar scripts para fazer qualquer coisa (ex: clicar com botão direito e "Abrir no VSCode", "Converter imagem para WebP", "Enviar para o Discord") e adicionar no menu dele.
    #Arquivos de Configuração: Ele guarda as configurações em arquivos de texto (dentro de ~/.config/Thunar/), incluindo as suas Ações Personalizadas (no arquivo uca.xml), então dá para restaurar o seu setup facilmente, embora não seja tão "limpo" quanto o Yazi.
    #Plugins: Suporta plugins oficiais (como o thunar-archive-plugin para extrair zips e o thunar-volman para pendrives).
# Yazi: gerenciador de arquivos no terminal (talvez seja loucura) -> tem plugin pra poha
# vsCode: editor de código, ver como estilizar depois
# ZSH : shell, usar com starship zsh-autosuggestions zsh-syntax-highlighting fzf
# fastfetch : ver o sistema ()
# GRIM: Screenshot : cofigurar no hyprland
# SLURP: Screenshot in region : configurar no hyprland
# eog : visualizador de imagem : precisa setar ele como padrão
# mpv : visualizador de video : precisa setar ele como padrão 




# ------------------
# OUTRAS OPÇÕES (testar no futuro)
# ------------------
# nemo : gerenciador de arquivos (usa gvfs também, precisa instalar) (tem extensões, como o nautilus)
# nautilus: gerenciador de arquivos (também tem extensões uteis)
# Kitty: emulador de terminal que vem por padrão no hyprland
# network-manager-applet  ?
# ZEN-BROWSER: Browser : alterar no hyprland.conf



# ------------------
# LEMBRAR
# ------------------
# WIFI NO WAYABAR PELO AMOR DE DEUS
# configurar fonts
# configurar zsh
# configurar waybar
# configurar gtk, qt, etc -> darkmode
# hyprland .conf arquivo ver minhas modificações de monitor, binds, etc
# testar TUDO 1 por 1 
# configurar monitor
# configurar kitty (pasta kitty) (kitten themes)
# configurar gerenciador de arquivos nemo na .config/hypr/hyprland.conf
# configurar o browser na .config/hypr/hyprland.conf
# trocar engine padrão do browser para duckduckgo
# trocar shell para zsh 
# https://github.com/caiohperlin/arch

## Define o visualizador de imagens (exemplo usando o programa 'imv')
# xdg-mime default eog.desktop image/jpeg image/png image/gif image/webp

## Define o player de vídeo (exemplo usando o 'mpv')
# xdg-mime default mpv.desktop video/mp4 video/x-matroska video/webm

## Define o navegador padrão (importante para links funcionarem em outros apps)
# xdg-mime default firefox.desktop x-scheme-handler/http x-scheme-handler/https text/html

# chsh -s  /usr/bin/zsh
# deslogar para efetivar mudanças

# sudo pacman -S --needed --noconfirm zsh-autosuggestions zsh-syntax-highlighting fzf

# configurar font jetbrains-mono-nerd

# starship preset nerd-font-symbols -o ~/.config/starship/startship.toml

# alt + c : cd para pasta
# ctrl + p : escolher arquivo 
# ctrl + r : histórico

# configurar o settings.json do vscode 

# sudo pacman -S awd-gtk-theme xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-gtk qt6ct qt5ct breeze-icons


# CATPPUCCIN FRAPPE MAUVE
# TROCAR GOOGLE para DUCKDUCKGO no firefox
# INSTALAR O TEMA DO VSCODE PARA CATPPUCCIN MACCHIATO
# ADICIONAR O TODOIST para abrir automaticamente no firefox!!
# Para tema no firefox: https://github.com/catppuccin/firefox?tab=readme-ov-file
# congigurar SSD para github e depois só sucessooo

