#!/usr/bin/env bash
# Crash-isolated stand-in for waybar's built-in "mpris" module. On waybar 0.15.0 that module
# segfaults inside libplayerctl signal handlers (3 crashes 2026-09-13/14, Waybar #2747 #4450),
# and nothing restarts the bar. Here playerctl runs in this child process instead: if a player
# glitches, only this script dies and waybar re-runs it (restart-interval).
#
# Cleanup: waybar signals only this PID (we lead our own process group), and `omarchy restart
# waybar` uses kill -9 (config launches us via `setpriv --pdeathsig TERM`). Either way the trap
# takes playerctl down with us instead of leaving it orphaned.
declare -A icon=([Playing]=$'\xef\x81\x8b' [Paused]=$'\xef\x81\x8c' [Stopped]=$'\xef\x81\x8d') # U+F04B/C/D

trap 'trap - TERM INT EXIT; kill -- -$$ 2>/dev/null' TERM INT EXIT

while IFS=$'\t' read -r status player title; do
  if [[ -z $status ]]; then
    echo '{"text": ""}'
  else
    jq -cn --arg text "${icon[$status]}" --arg tooltip "$player — $title" --arg class "${status,,}" \
      '{text: $text, tooltip: $tooltip, class: $class, alt: $class}'
  fi
done < <(playerctl --follow metadata --format $'{{status}}\t{{playerName}}\t{{title}}' 2>/dev/null)
