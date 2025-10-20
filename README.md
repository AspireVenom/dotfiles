# Aspire's Dotfiles (OMARCHY)

Bare-repo dotfiles to keep my Arch/Omarchy setup identical across machines.

## Quick Start (new machine)

```bash
# 1) Install git
# 2) Bootstrap dotfiles
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AspireVenom/dotfiles/main/.config/dotfiles/bootstrap.sh)" || \
~/.config/dotfiles/bootstrap.sh https://github.com/AspireVenom/dotfiles.git main
```

## Daily usage

```bash
# helper wrapper
config status -u
config add -f .config/hypr .config/waybar .config/nvim .config/mako .config/alacritty .config/fastfetch .config/starship.toml
config commit -m "chore: update configs"
config push
```

## Notes
- Uses a bare repo at `~/.cfg` and checks out to `$HOME`.
- Conflicting files are backed up to `~/.config/dotfiles-backup/<timestamp>/`.
- `config` helper lives at `~/.local/bin/config`.
