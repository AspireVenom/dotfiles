#!/usr/bin/env bash

set -euo pipefail

EWW_BIN="${EWW:-eww}"
CFG_DIR="$HOME/.config/eww"
WINDOW_NAME="omarchy_hud"

$EWW_BIN -c "$CFG_DIR" ping >/dev/null 2>&1 || $EWW_BIN -c "$CFG_DIR" daemon

if $EWW_BIN -c "$CFG_DIR" active-windows | grep -q "$WINDOW_NAME"; then
    $EWW_BIN -c "$CFG_DIR" close "$WINDOW_NAME"
else
    $EWW_BIN -c "$CFG_DIR" open "$WINDOW_NAME"
fi

