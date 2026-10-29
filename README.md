# Aspire's Dotfiles (Omarchy)

My Omarchy setup: the **Crimson Black** look (OLED black, warm white, one crimson signal) plus my daily workflow (zsh, nvim, tmux, eww HUD, sticky notes). Bare git repo checked out over `$HOME`.

The theme itself lives in its own repo: [omarchy-crimson-black-theme](https://github.com/AspireVenom/omarchy-crimson-black-theme).

## Restore on a fresh Omarchy install

```bash
gh auth login        # optional: needed for the private sticky-notes repo
bash <(curl -fsSL https://raw.githubusercontent.com/AspireVenom/dotfiles/main/.config/dotfiles/bootstrap.sh)
# on the 3-monitor RTX desktop, append: --host aspire-desktop
```

What it does, in order:

1. Clones this repo into `~/.cfg` and checks it out over `$HOME`. Files it would overwrite are moved to `~/.config/dotfiles-backup/<timestamp>/`.
2. Picks a Hyprland host profile: `~/.config/hypr/host.conf` links to `hypr/hosts/<profile>.conf` (`aspire-desktop`, `nvidia` or `default`; auto-detects NVIDIA). Override it with `--host <profile>`.
3. Installs packages from `.config/dotfiles/packages/` (`pacman.txt` and `aur.txt`; add `--all-packages` for every other app I use).
4. Installs oh-my-zsh + powerlevel10k, switches the login shell to zsh, and clones sticky notes.
5. Runs `omarchy theme install` for Crimson Black. Its theme-set hooks then style Chromium, Spotify and the live wallpaper.

Flags: `--no-packages`, `--no-extras`, `--no-theme`, `--host <profile>`.

### Optional, after restore

| What | Command |
|------|---------|
| Spotify theme | install [spicetify](https://spicetify.app), open Spotify once, then `spicetify config current_theme omarchy color_scheme base inject_theme_js 0 && spicetify backup apply` |
| Boot screens (Limine menu + "Aspire" unlock screen) | `~/.config/omarchy/theme-src/crimson-black/apply-boot-style.sh` (sudo). Adds a Windows entry only if a Windows boot manager is found. |
| Chromium theme | restart Chromium once |
| Claude Code | `/theme` → `crimson-black` |

## Layout

| Path | What |
|------|------|
| `.config/hypr/` | Hyprland. `hosts/*.conf` holds per-machine GPU env; `monitors.conf` matches monitors by model, so it is a no-op on other hardware |
| `.config/omarchy/themed/*.tpl` | per-theme templates (waybar/hyprlock tokens, Chromium, Spotify) rendered on every `omarchy theme set` |
| `.config/omarchy/hooks/theme-set.d/` | Chromium, Spotify and live-wallpaper hooks |
| `.config/omarchy/theme-src/crimson-black/` | wallpaper/unlock generators, Limine boot hook, `apply-boot-style.sh` |
| `.config/waybar`, `walker`, `alacritty`, `eww`, `spicetify/Themes/omarchy` | app styling |
| `.config/zsh`, `nvim`, `tmux`, `.zshenv` | workflow |
| `.local/bin/` | `omarchy-livewall`, screensaver and idle helpers |
| `.claude/themes/crimson-black.json` | Claude Code theme |

## Daily use

```bash
config status                     # untracked files are hidden on purpose
config add <path>                 # add explicit paths only; never 'config add -A'
config commit -m "..." && config push
```

Never tracked: shell history, caches, app data, `omarchy/current`, installed themes, `*.bak*` (see `.gitignore`). Run `mise exec gitleaks@latest -- gitleaks git ~/.cfg` before pushing.
