# ~/.zshrc
# Orden: instant prompt, historial, teclas, completado, plugins, alias, funciones, prompt.

# ----------------------------------------------------------------------------
# Powerlevel10k instant prompt (tiene que ir arriba de todo)
# ----------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ----------------------------------------------------------------------------
# Historial
# ----------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt histignorealldups sharehistory

# ----------------------------------------------------------------------------
# Teclas
# ----------------------------------------------------------------------------
bindkey -e
bindkey '^[[H'    beginning-of-line   # Inicio
bindkey '^[[F'    end-of-line         # Fin
bindkey '^[[3~'   delete-char         # Supr
bindkey '^[[1;3C' forward-word        # Alt + derecha
bindkey '^[[1;3D' backward-word       # Alt + izquierda

# ----------------------------------------------------------------------------
# Completado (del .zshrc del curso)
# ----------------------------------------------------------------------------
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
export LS_COLORS=${LS_COLORS//=01;/=}   # sin negrita
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ----------------------------------------------------------------------------
# Plugins
# ----------------------------------------------------------------------------
source /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh                 # Esc Esc = sudo
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# ----------------------------------------------------------------------------
# Alias
# ----------------------------------------------------------------------------
alias ls='lsd --group-dirs=first'
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias cat='bat'
alias catn='bat --style=plain'
alias catnp='bat --style=plain --paging=never'

# ----------------------------------------------------------------------------
# Funciones: settarget / cleartarget para la polybar
# ----------------------------------------------------------------------------
source ~/.config/target.zsh
[ -f ~/.config/lab.zsh ] && source ~/.config/lab.zsh      # mkt, extractPorts, addhost

# zoxide: "z nombre" salta a una carpeta ya visitada, sin escribir la ruta
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# Ajustes solo de este equipo (alias propios, rutas): no los pisa el instalador
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# ----------------------------------------------------------------------------
# Prompt: Powerlevel10k (para cambiarlo: `p10k configure` o editar ~/.p10k.zsh)
# ----------------------------------------------------------------------------
source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ----------------------------------------------------------------------------
# fzf: Ctrl+R historial, Ctrl+T archivos, Alt+C cd
# ----------------------------------------------------------------------------
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# El resaltado de sintaxis tiene que cargarse al final
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
