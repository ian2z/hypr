#!/usr/bin/env bash

# Prevent duplicate lock screen processes
if pidof hyprlock >/dev/null; then
    exit 0
fi

# Run the watchdog in the background
/home/ian/dotfiles/hypr/scripts/lock_watchdog.sh &

# Launch hyprlock in the foreground
hyprlock
