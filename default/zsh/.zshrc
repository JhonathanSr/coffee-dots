# Fusion Zap + coffee-dots
# Optimized for CachyOS
# User: Jhonathan Ruiz

# Si no esta en modo interactivo, no hacemos nada
[[ $- != *i* ]] && return

# --- 1. ENTORNO Y VARIABLES GLOBALES ---
export VISUAL="code --wait"
export EDITOR="nvim"
export BROWSER="zen-browser"
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
export BAT_THEME="base16"

# Optimización para tu RX 6600 XT
export HSA_OVERRIDE_GFX_VERSION=10.3.0

# Path local
[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"

# --- 2. GESTIÓN DE PLUGINS CON ZAP ---
# Reemplazamos las instalaciones de pacman por gestión declarativa
source "$HOME/.local/share/zap/zap.zsh"

plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-history-substring-search"
plug "hlissner/zsh-autopair"
plug "zap-zsh/supercharge"
plug "Aloxaf/fzf-tab" # Para la funcionalidad de previsualización

# --- 3. CONFIGURACIÓN AVANZADA (ZSTYLE) ---
# Aquí mantenemos tu lógica de previsualización en el tabulador
#zstyle ':completion:*' menu select
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
#zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons=always --color=always -a $realpath'
#zstyle ':fzf-tab:complete:bat:*' fzf-preview 'bat --color=always --theme=base16 $realpath'
#
#
zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list \
		'm:{a-zA-Z}={A-Za-z}' \
		'+r:|[._-]=* r:|=*' \
		'+l:|=*'
zstyle ':vcs_info:*' formats ' %B%s-[%F{magenta}%f %F{yellow}%b%f]-'
zstyle ':fzf-tab:*' fzf-flags --style=full --height=90% --pointer '>' \
                --color 'pointer:green:bold,bg+:-1:,fg+:green:bold,info:blue:bold,marker:yellow:bold,hl:gray:bold,hl+:yellow:bold' \
                --input-label ' Search ' --color 'input-border:blue,input-label:blue:bold' \
                --list-label ' Results ' --color 'list-border:green,list-label:green:bold' \
                --preview-label ' Preview ' --color 'preview-border:magenta,preview-label:magenta:bold'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons=always --color=always -a $realpath'
zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza -1 --icons=always --color=always -a $realpath'
zstyle ':fzf-tab:complete:bat:*' fzf-preview 'bat --color=always --theme=base16 $realpath'
zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
zstyle ':fzf-tab:*' accept-line enter

# --- 4. OPTIMIZACIÓN DEL COMPLETADO (COMPINIT) ---
# Lógica para que la terminal abra instantáneamente
autoload -Uz compinit
local zcompdump="$HOME/.config/zsh/zcompdump"
if [[ -n "$zcompdump"(#qN.mh+24) ]]; then
    compinit -i -d "$zcompdump"
else
    compinit -C -d "$zcompdump"
fi

# --- 5. PROMPT Y ESTÉTICA ---
setopt PROMPT_SUBST  # <--- ESTO ES LO QUE FALTA: Activa la ejecución de funciones en el prompt
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats ' %B%s-[%F{magenta}%f %F{yellow}%b%f]-'
precmd() { vcs_info }

function dir_icon {
  [[ "$PWD" == "$HOME" ]] && echo "%B%F{cyan}%f%b" || echo "%B%F{cyan}%f%b"
}

PS1='%B%F{blue}%f%b  %B%F{magenta}%n%f%b $(dir_icon)  %B%F{red}%~%f%b${vcs_info_msg_0_} %(?.%B%F{green}.%F{red})%f%b '
# --- 6. ALIAS Y FUNCIONES (YAZI / EZA) ---
alias cat="bat --theme=base16"
alias ls='eza --icons=always --color=always -a'
alias ll='eza --icons=always --color=always -la'

# Tu función mágica para Yazi
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ "$cwd" != "$PWD" ]] && [[ -d "$cwd" ]] && builtin cd -- "$cwd"
    command rm -f -- "$tmp"
}

# --- 7. INICIALIZACIÓN DE HERRAMIENTAS ---
# Zoxide estático para evitar lag
eval "$(zoxide init zsh)"

# NVM y SDKMAN (Vital para Java/Spring Boot)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# --- 8. COMPORTAMIENTO DE HISTORIA Y NAVEGACIÓN ---
HISTFILE=~/.config/zsh/zhistory
HISTSIZE=5000
SAVEHIST=5000
setopt APPEND_HISTORY      # Adjunta al historial en lugar de sobrescribir
setopt SHARE_HISTORY       # Comparte historial entre diferentes terminales abiertas
setopt HIST_IGNORE_DUPS    # No guarda duplicados seguidos
setopt AUTOCD              # Si escribes una ruta sin 'cd', entra automáticamente

# --- 8. COMPORTAMIENTO DE HISTORIA Y NAVEGACIÓN ---
bindkey -e                   # <--- FUERZA EL MODO NORMAL (Emacs)
                             # Esto evita que la terminal se comporte como Vim.

# Bienvenido
fastfetch