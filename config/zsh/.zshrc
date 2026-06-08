#!/bin/zs#!/bin/zsh

# ==============================================================================
# SCRIPT: Zsh Configuration (Fusion Zap + Coffee-Dots)
# DESCRIPCIÓN: Configuración avanzada de la shell optimizada para CachyOS. 
#              Incluye gestión declarativa de plugins, previsualización en el 
#              tabulador mediante fzf-tab y atajos para desarrollo.
# DEPENDENCIAS: zsh, zap-zsh, fzf, eza, bat, yazi, zoxide.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 26/05/2026
# ==============================================================================

# --- Verificación de Interactividad ---
[[ $- != *i* ]] && return

# --- 1. Entorno, Variables Globales e Historial ---
export VISUAL="code --wait"
export EDITOR="nvim"
export BROWSER="zen-browser"
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
export BAT_THEME="base16"
export PATH=$HOME/.config/coffee:$PATH
export PATH=$HOME/.config/rofi/scripts:$PATH

# Optimización para Radeon RX 6600 XT (RDNA 2)
export HSA_OVERRIDE_GFX_VERSION=10.3.0

# Extensión del PATH local del usuario
[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"

# Configuración del Historial 
HISTFILE=~/.config/zsh/zhistory
HISTSIZE=10000        
SAVEHIST=10000

setopt APPEND_HISTORY     
setopt SHARE_HISTORY      
setopt HIST_IGNORE_DUPS   
setopt HIST_REDUCE_BLANKS 
setopt AUTOCD             

# --- 2. Optimización de Carga (Compinit - PRIMERO) ---
autoload -Uz compinit
local zcompdump="$HOME/.config/zsh/zcompdump"
if [[ -n "$zcompdump"(#qN.mh+24) ]]; then
    compinit -i -d "$zcompdump"
else
    compinit -C -d "$zcompdump"
fi

# --- Automatización de SSH Agent para Zsh ---
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
fi

# --- 3. Gestión de Plugins (ZAP) ---
source "$HOME/.local/share/zap/zap.zsh"

# El orden aquí importa: fzf-tab debe interceptar el sistema de completado antes de los highlights
plug "Aloxaf/fzf-tab"                          # Reemplazo del menú de completado por FZF.
plug "zsh-users/zsh-autosuggestions"           # Sugerencias basadas en historial.
plug "zsh-users/zsh-history-substring-search"  # Búsqueda inteligente en el historial.
plug "hlissner/zsh-autopair"                   # Cierre automático de paréntesis/comillas.
plug "zap-zsh/supercharge"                     # Colección de mejoras base de Zap.
plug "zsh-users/zsh-syntax-highlighting"       # SIEMPRE AL FINAL para evitar bugs de dibujado.

# --- 4. Configuración del Completado (ZStyle) ---
zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list \
        'm:{a-zA-Z}={A-Za-z}' \
        '+r:|[._-]=* r:|=*' \
        '+l:|=*'

# Estética avanzada para fzf-tab (Colores y bordes)
zstyle ':fzf-tab:*' fzf-flags --style=full --height=90% --pointer '>' \
                --color 'pointer:green:bold,bg+:-1:,fg+:green:bold,info:blue:bold,marker:yellow:bold,hl:gray:bold,hl+:yellow:bold' \
                --input-label ' Search ' --color 'input-border:blue,input-label:blue:bold' \
                --list-label ' Results ' --color 'list-border:green,list-label:green:bold' \
                --preview-label ' Preview ' --color 'preview-border:magenta,preview-label:magenta:bold'

# Previsualizaciones dinámicas
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons=always --color=always -a $realpath'
zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza -1 --icons=always --color=always -a $realpath'
zstyle ':fzf-tab:complete:bat:*' fzf-preview 'bat --color=always --theme=base16 $realpath'
zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
zstyle ':fzf-tab:*' accept-line enter

# --- 5. Prompt Estético (Powerline Style) ---
setopt PROMPT_SUBST  
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats ' %B%s-[%F{magenta}%f %F{yellow}%b%f]-'
precmd() { vcs_info }

function dir_icon {
    [[ "$PWD" == "$HOME" ]] && echo "%B%F{cyan}%f%b" || echo "%B%F{cyan}%f%b"
}

PS1='%B%F{blue}%f%b  %B%F{magenta}%n%f%b $(dir_icon)  %B%F{red}%~%f%b${vcs_info_msg_0_} %(?.%B%F{green}.%F{red})%f%b '

# --- 6. Aliases y Funciones Modernas ---
alias cat="bat --theme=base16"
alias ls='eza --icons=always --color=always -a'
alias ll='eza --icons=always --color=always -la'
alias tf='cd ~/Work/Repositorio/Frontend/'
alias tb='cd ~/Work/Repositorio/Backend/'

alias -s md="bat"
alias -s js="$EDITOR"
alias -s ts="$EDITOR"
alias -s yaml="$EDITOR"

alias -g NE='2>/dev/null'
alias -g ND='>/dev/null'
alias -g NUL='>/dev/null 2>1'
alias -g JQ='| jq'
alias -g C='| wl-copy'
alias -g L='| less'

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ "$cwd" != "$PWD" ]] && [[ -d "$cwd" ]] && builtin cd -- "$cwd"
    command rm -f -- "$tmp"
}

# --- 7. Inicialización de Herramientas de Dev ---
eval "$(zoxide init zsh --cmd j)"
eval "$(mise activate zsh)"

# --- 8. Comportamiento del Teclado y Mapeo del Historial ---
bindkey -e  

# Configuración estricta de teclas para zsh-history-substring-search
# Funciona nativamente en Ghostty / Alacritty / Kitty
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Mapeo alternativo para modo Vi o compatibilidad EMACS si usas terminales específicas
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# --- Lanzamiento ---
fastfetch
