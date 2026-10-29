#!/usr/bin/env bash

# Simple helper to set or cycle the current Omarchy mode shown in the HUD.

STATE_FILE="$HOME/.local/state/omarchy/mode"
DEFAULTS=("coding" "gaming" "streaming" "focus")

mkdir -p "$(dirname "$STATE_FILE")"
[[ -f "$STATE_FILE" ]] || printf "%s\n" "coding" >"$STATE_FILE"

current="$(tr -d '\n\r' <"$STATE_FILE")"

next_mode() {
    local idx=0
    local i
    for i in "${!DEFAULTS[@]}"; do
        if [[ "${DEFAULTS[$i]}" == "$current" ]]; then
            idx=$i
            break
        fi
    done
    idx=$(((idx + 1) % ${#DEFAULTS[@]}))
    echo "${DEFAULTS[$idx]}"
}

case "$1" in
    set)
        [[ -n "$2" ]] || { echo "Usage: $0 set <mode>" >&2; exit 1; }
        printf "%s\n" "$2" >"$STATE_FILE"
        ;;
    cycle|"")
        printf "%s\n" "$(next_mode)" >"$STATE_FILE"
        ;;
    *)
        echo "Usage: $0 [set <mode>|cycle]" >&2
        exit 1
        ;;
esac

echo "Current mode: $(cat "$STATE_FILE")"

