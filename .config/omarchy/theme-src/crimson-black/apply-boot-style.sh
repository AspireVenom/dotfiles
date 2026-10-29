#!/usr/bin/env bash
# Opt-in install of the Crimson Black boot chain (needs sudo). Safe to re-run.
#   1. Find this machine's Windows ESP (if any) and record it in /etc/default/aspire-limine.
#   2. Limine menu: install the post.d hook that styles /boot/limine.conf and keeps the Windows entry.
#   3. Plymouth LUKS prompt + SDDM: "Aspire" wordmark, crimson field (rebuilds the UKI, which also
#      runs the new hook once more through limine-entry-tool).
# Undo: sudo rm /etc/boot/hooks/post.d/85-aspire-limine-style /etc/default/aspire-limine
#       sudo cp /boot/limine.conf.pre-aspire /boot/limine.conf && omarchy plymouth reset
set -euo pipefail

src=~/.config/omarchy/theme-src/crimson-black
unlock=~/.config/omarchy/themes/crimson-black/unlock.png
hook=/etc/boot/hooks/post.d/85-aspire-limine-style
settings=/etc/default/aspire-limine
esp_type=c12a7328-f81f-11d2-ba4b-00a0c93ec93b
bootmgr=EFI/Microsoft/Boot/bootmgfw.efi

[[ -f $unlock ]] || { echo "Missing $unlock: install the theme first (omarchy theme install https://github.com/AspireVenom/omarchy-crimson-black-theme)" >&2; exit 1; }
[[ -d /etc/boot/hooks/post.d ]] || { echo "No /etc/boot/hooks/post.d: this script expects Omarchy's Limine setup" >&2; exit 1; }

# Prefer a Windows entry Limine already has; otherwise probe every EFI system partition read-only.
find_windows_esp() {
  local guid path mnt found=""
  guid=$(grep -i 'bootmgfw\.efi' /boot/limine.conf 2>/dev/null | sed -n 's/.*guid(\([0-9a-fA-F-]*\)).*/\1/p' | head -1)
  [[ -n $guid ]] && { echo "$guid"; return; }

  while read -r path guid parttype; do
    [[ ${parttype,,} == "$esp_type" && -n $guid ]] || continue
    mnt=$(findmnt -nro TARGET --source "$path" | head -1)
    if [[ -n $mnt ]]; then
      sudo test -f "$mnt/$bootmgr" && found=$guid
    else
      mnt=$(mktemp -d)
      if sudo mount -o ro "$path" "$mnt" 2>/dev/null; then
        sudo test -f "$mnt/$bootmgr" && found=$guid
        sudo umount "$mnt"
      fi
      rmdir "$mnt"
    fi
    [[ -n $found ]] && { echo "$found"; return; }
  done < <(lsblk -rpno PATH,PARTUUID,PARTTYPE)
}

windows=$(find_windows_esp || true)
if [[ -n $windows ]]; then
  echo "Windows boot manager found on PARTUUID $windows"
else
  echo "No Windows boot manager found: the menu gets no Windows entry"
fi
printf '# Written by apply-boot-style.sh. Empty = no Windows entry in the Limine menu.\nWINDOWS_ESP_PARTUUID=%s\n' "$windows" |
  sudo tee "$settings" >/dev/null

sudo install -o root -g root -m 755 "$src/limine/85-aspire-limine-style" "$hook"
sudo "$hook"

omarchy plymouth set '#000000' '#ef2a42' "$unlock"

echo
grep -E '^(interface_branding|term_foreground|term_background):' /boot/limine.conf
if [[ -n $windows ]]; then
  grep -q 'bootmgfw\.efi' /boot/limine.conf && echo "Windows entry: present" || echo "Windows entry: MISSING"
fi
cmp -s /usr/share/plymouth/themes/omarchy/logo.png "$unlock" &&
  echo "Plymouth logo: installed" || echo "Plymouth logo: NOT installed"
