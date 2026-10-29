#!/usr/bin/env bash
set -euo pipefail

# Dotfiles bootstrapper (bare repo method) for a fresh Omarchy install.
# Usage:
#   bootstrap.sh [options] [remote-url] [branch]
# Options:
#   --host <profile>   hypr/hosts/<profile>.conf to link as ~/.config/hypr/host.conf
#                      (default: keep an existing link, else "nvidia" when an NVIDIA GPU is present, else "default")
#   --no-packages      skip pacman/yay installs
#   --all-packages     also install every package from packages/*-all.txt (the rest of the workflow apps)
#   --no-extras        skip oh-my-zsh, powerlevel10k, sticky and the login shell change
#   --no-theme         skip installing/applying the Crimson Black theme
# Env: DOTFILES_REMOTE, DOTFILES_BRANCH

THEME_REPO="https://github.com/AspireVenom/omarchy-crimson-black-theme"
STICKY_REPO="AspireVenom/hypr-sticky"

HOST_PROFILE="" PACKAGES=1 ALL_PACKAGES=0 EXTRAS=1 THEME=1 positional=()
while (($#)); do
  case $1 in
    --host) HOST_PROFILE=${2:?--host needs a profile name}; shift ;;
    --no-packages) PACKAGES=0 ;;
    --all-packages) ALL_PACKAGES=1 ;;
    --no-extras) EXTRAS=0 ;;
    --no-theme) THEME=0 ;;
    -h|--help) sed -n '4,15p' "$0"; exit 0 ;;
    *) positional+=("$1") ;;
  esac
  shift
done

REMOTE_URL=${positional[0]:-${DOTFILES_REMOTE:-https://github.com/AspireVenom/dotfiles.git}}
BRANCH=${positional[1]:-${DOTFILES_BRANCH:-main}}

GIT_DIR="$HOME/.cfg"
WORK_TREE="$HOME"
CONFIG=(git --git-dir="$GIT_DIR" --work-tree="$WORK_TREE")
DOTDIR="$HOME/.config/dotfiles"

info() { printf "\033[1;31m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[err ]\033[0m %s\n" "$*"; }

command -v git >/dev/null || { err "git is required"; exit 1; }

# Create handy wrapper: ~/.local/bin/config
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/config" <<'WRAP'
#!/usr/bin/env bash
exec git --git-dir="$HOME/.cfg" --work-tree="$HOME" "$@"
WRAP
chmod +x "$HOME/.local/bin/config"

checkout_with_backup() {
  "${CONFIG[@]}" checkout 2>/dev/null && return
  warn "Existing files conflict with the repo; backing them up and retrying"
  local ts backup_dir path
  ts=$(date +%Y%m%d-%H%M%S)
  backup_dir="$HOME/.config/dotfiles-backup/$ts"
  mkdir -p "$backup_dir"
  while read -r path; do
    [ -z "$path" ] && continue
    [ -e "$HOME/$path" ] || [ -L "$HOME/$path" ] || continue
    mkdir -p "$backup_dir/$(dirname "$path")"
    mv "$HOME/$path" "$backup_dir/$path"
  done < <("${CONFIG[@]}" ls-tree -r --name-only HEAD)
  "${CONFIG[@]}" checkout
  info "Backed up conflicting files to $backup_dir"
}

# 1. Dotfiles
if [ -d "$GIT_DIR" ]; then
  info "Existing dotfiles repo detected at $GIT_DIR"
  "${CONFIG[@]}" config status.showUntrackedFiles no
  "${CONFIG[@]}" remote get-url origin >/dev/null 2>&1 || "${CONFIG[@]}" remote add origin "$REMOTE_URL"
  checkout_with_backup
else
  info "Cloning bare repo from ${REMOTE_URL} (branch ${BRANCH})"
  git clone --bare --branch "$BRANCH" "$REMOTE_URL" "$GIT_DIR"
  "${CONFIG[@]}" config status.showUntrackedFiles no
  checkout_with_backup
fi

# 2. Machine profile: GPU env and anything else that must not leak onto other hardware
hypr="$HOME/.config/hypr"
if [[ -n $HOST_PROFILE || ! -e $hypr/host.conf ]]; then
  if [[ -z $HOST_PROFILE ]]; then
    if command -v lspci >/dev/null && lspci | grep -qiE '(vga|3d).*nvidia'; then HOST_PROFILE=nvidia; else HOST_PROFILE=default; fi
  fi
  [[ -f $hypr/hosts/$HOST_PROFILE.conf ]] || { err "No profile $hypr/hosts/$HOST_PROFILE.conf"; exit 1; }
  ln -sfn "hosts/$HOST_PROFILE.conf" "$hypr/host.conf"
  info "Hyprland host profile: $HOST_PROFILE"
else
  info "Keeping Hyprland host profile: $(readlink "$hypr/host.conf" || echo "$hypr/host.conf")"
fi

# 3. Packages
install_list() {
  local tool=$1 list=$2
  [[ -s $list ]] || return 0
  grep -v -E '^\s*(#|$)' "$list" | $tool -S --needed --noconfirm - || warn "Some packages from $(basename "$list") failed; continuing"
}
if ((PACKAGES)); then
  info "Installing packages (sudo may prompt)"
  install_list "sudo pacman" "$DOTDIR/packages/pacman.txt"
  install_list yay "$DOTDIR/packages/aur.txt"
  if ((ALL_PACKAGES)); then
    install_list "sudo pacman" "$DOTDIR/packages/pacman-all.txt"
    install_list yay "$DOTDIR/packages/aur-all.txt"
  fi
fi

# 4. Shell and tools that live outside the repo
if ((EXTRAS)); then
  zsh_dir="$HOME/.config/oh-my-zsh"
  if [[ ! -d $zsh_dir ]]; then
    info "Installing oh-my-zsh"
    git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$zsh_dir"
  fi
  p10k="$zsh_dir/custom/themes/powerlevel10k"
  [[ -d $p10k ]] || git clone --depth 1 https://github.com/romkatv/powerlevel10k.git "$p10k"

  if command -v zsh >/dev/null && [[ $(getent passwd "$USER" | cut -d: -f7) != */zsh ]]; then
    info "Switching login shell to zsh (asks for your password)"
    chsh -s "$(command -v zsh)" || warn "chsh failed; run: chsh -s $(command -v zsh)"
  fi

  sticky_src="$HOME/.local/src/hypr-sticky"
  if [[ ! -d $sticky_src ]]; then
    if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
      info "Installing sticky notes ($STICKY_REPO, private)"
      gh repo clone "$STICKY_REPO" "$sticky_src" || warn "Could not clone $STICKY_REPO"
    else
      warn "Sticky notes skipped: run 'gh auth login', then re-run this script"
    fi
  fi
  [[ -x $sticky_src/sticky ]] && ln -sfn "$sticky_src/sticky" "$HOME/.local/bin/sticky"
fi

# 5. Theme (its own repo; theme-set hooks then style Chromium, Spotify and the live wallpaper)
if ((THEME)); then
  if command -v omarchy >/dev/null; then
    info "Installing Crimson Black"
    omarchy theme install "$THEME_REPO"
  else
    warn "omarchy not found; install the theme later: omarchy theme install $THEME_REPO"
  fi
fi

cat <<EOF

Done. Optional follow-ups:
  Spotify:   curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
             (open Spotify once first), then:
             spicetify config current_theme omarchy color_scheme base inject_theme_js 0
             spicetify backup apply
  Boot:      ~/.config/omarchy/theme-src/crimson-black/apply-boot-style.sh   (sudo; Limine menu + unlock screen)
  Chromium:  restart it once to load the theme extension
  Claude:    /theme in Claude Code, pick crimson-black
  Manage:    config status | config add <path> | config commit | config push
EOF
