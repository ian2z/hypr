#!/usr/bin/env bash

# Determine if running on battery (0 = AC, 1 = Battery)
on_battery=0
if [ -f /sys/class/power_supply/AC/online ]; then
    if [ "$(cat /sys/class/power_supply/AC/online)" = "0" ]; then
        on_battery=1
    fi
else
    if grep -q "Discharging" /sys/class/power_supply/BAT*/status 2>/dev/null; then
        on_battery=1
    fi
fi

timeout_val=$1

if [ "$timeout_val" -eq 300 ]; then
    # On battery: lock after 5 minutes (300 seconds)
    if [ "$on_battery" -eq 1 ]; then
        loginctl lock-session
    fi
elif [ "$timeout_val" -eq 600 ]; then
    # On AC: lock after 10 minutes (600 seconds)
    if [ "$on_battery" -eq 0 ]; then
        loginctl lock-session
    fi
fi
