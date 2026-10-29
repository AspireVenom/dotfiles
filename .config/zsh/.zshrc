# ~/.config/zsh/.zshrc  (ZDOTDIR set in ~/.zshenv)

# ── p10k instant prompt: keep at top; nothing that reads input above ──
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── PATH (deduped) ──
typeset -U path
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
path=(
  "$HOME/.local/bin"
  "$HOME/.venvs/platformio/bin"
  "$ANDROID_HOME/platform-tools"
  "$ANDROID_HOME/emulator"
  $path
)

# ── history (must precede oh-my-zsh, which sets fallbacks) ──
export HISTFILE="$ZDOTDIR/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000

# ── oh-my-zsh ──
export ZSH="$HOME/.config/oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
HYPHEN_INSENSITIVE="true"
zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 14
# git: aliases (gst, gco, gp…). sudo: Esc-Esc prefixes sudo. extract: `extract file.tar.xz`
plugins=(git sudo extract)
source "$ZSH/oh-my-zsh.sh"

setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY INC_APPEND_HISTORY
unsetopt SHARE_HISTORY   # per-shell history; up-arrow stays local to this pane

# ── environment ──
export EDITOR="nvim"
export VISUAL="$EDITOR"
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi
# vitest defaults to (threads - 1) = 31 jsdom workers on the 14900K (~650MB each) -> OOM freeze. Integer only.
export VITEST_MAX_WORKERS=6
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ── tool init ──
# mise: PATH activation (not shims) for interactive shells
command -v mise >/dev/null && eval "$(mise activate zsh)"

# fzf: Ctrl-T files, Ctrl-R history, Alt-C cd
if command -v fzf >/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --info=inline'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :300 {}'"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons=auto {}'"
  source <(fzf --zsh)
fi

# zoxide: `cd foo` jumps by frecency; real dirs still work. Must follow compinit (omz did it).
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"

# ── aliases / functions ──
[[ -f "$ZDOTDIR/aliases.zsh" ]] && source "$ZDOTDIR/aliases.zsh"

# claude: run inside claude.slice (~/.config/systemd/user/claude.slice) so every session and the
# tests/builds it spawns share one memory cap; runaway workers get OOM-killed there instead of
# freezing the desktop. Falls back to plain claude when there's no user systemd bus (e.g. TTY/SSH).
claude() {
  if [[ -S "${XDG_RUNTIME_DIR:-/run/user/$UID}/bus" ]]; then
    systemd-run --user --scope --quiet --slice=claude.slice -- "${commands[claude]:-claude}" "$@"
  else
    command claude "$@"
  fi
}

# ── inline suggestions (ghost text from history/completion) ──
# Accept: → or End. Accept one word: Ctrl-→ / Alt-F. Dismiss: keep typing.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'   # color 8 is near-black on the OLED theme
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^y' autosuggest-accept   # Ctrl-Y also accepts (Ctrl-Space is the tmux prefix)

# ── syntax highlighting: must be sourced after everything that wraps widgets ──
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── ↑/↓ search history by typed prefix (loads after syntax-highlighting by design) ──
source "$ZSH/plugins/history-substring-search/history-substring-search.plugin.zsh"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# ── prompt ──
[[ ! -f "$ZDOTDIR/.p10k.zsh" ]] || source "$ZDOTDIR/.p10k.zsh"
