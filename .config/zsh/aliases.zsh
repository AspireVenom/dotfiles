# ~/.config/zsh/aliases.zsh — sourced from .zshrc

# files (mirrors omarchy bash defaults)
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias cat='bat --paging=never --style=plain'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# fuzzy: pick file with preview; edit picked file
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias eff='$EDITOR "$(ff)"'

# tools
alias v='nvim'
alias lg='lazygit'
alias d='docker'
alias t='tmux attach || tmux new -s Work'
alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'
alias pio="$HOME/.venvs/platformio/bin/pio"
alias zshrc='$EDITOR "$ZDOTDIR/.zshrc"'
alias zshreload='exec zsh'

# nvim on . when no args
n() { if (( $# == 0 )); then command nvim .; else command nvim "$@"; fi; }

# detach GUI open
open() ( xdg-open "$@" >/dev/null 2>&1 & )

# mkdir + cd
mkcd() { mkdir -p "$1" && cd "$1"; }
