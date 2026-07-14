#!/usr/bin/env bash

# Prevent duplicate lock screen processes
if pidof hyprlock >/dev/null; then
    exit 0
fi

# Run the watchdog in the background
/home/ian/dotfiles/hypr/scripts/lock_watchdog.sh &

# Launch hyprlock in the foreground
hyprlock

# Force the display to turn back ON after unlocking (with a delay for compositor transition)
sleep 0.5
hyprctl dispatch dpms on

# Tell logind that the session is now unlocked
loginctl unlock-session



