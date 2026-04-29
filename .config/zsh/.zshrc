# Binds
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey "^H" backward-kill-word
bindkey "^[[3;5~" kill-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

# Aliases
alias ls='ls --color=auto -a'
alias startSiteCdcc=' (cd "/home/thalles/Documents/programação/cdcc/backend" && ./mvnw spring-boot:run) & (cd "/home/thalles/Documents/programação/cdcc/frontend" && npm start) & wait '
alias update-waybar='killall -SIGUSR2 waybar'
alias update-wifi='nmcli radio wifi off && nmcli radio wifi on'
alias update-monitor='hyprctl dispatch togglespecialworkspace magic'

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# FZF
source <(fzf --zsh)

# Starship
eval "$(starship init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/share/nvm/init-nvm.sh" ] && . "/usr/share/nvm/init-nvm.sh"


# Load Angular CLI autocompletion.
source <(ng completion script)

# Arquivo de histórico
HISTFILE=~/.zsh_history

# Tamanho do histórico
HISTSIZE=10000
SAVEHIST=10000

# Opções importantes
setopt appendhistory        # adiciona ao histórico, não sobrescreve
setopt sharehistory         # compartilha histórico entre sessões
setopt incappendhistory     # salva imediatamente cada comando

# (Opcional, mas recomendado)
setopt hist_ignore_dups     # evita duplicados
setopt hist_ignore_space    # ignora comandos com espaço no início
