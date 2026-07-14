#!/usr/bin/env bash

# Time thresholds in seconds for staying on lock screen before suspend
THRESHOLD_AC=600     # 10 minutes
THRESHOLD_BAT=300    # 5 minutes

accumulated=0
last_time=$(date +%s)

# Turn off display after 10 seconds of locking to save energy,
# but skip if the system was suspended during the sleep.
(
    start_time=$(date +%s)
    sleep 10
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))
    if [ "$elapsed" -lt 14 ]; then
        if pidof hyprlock >/dev/null; then
            hyprctl dispatch dpms off
        fi
    fi
) &

# Give hyprlock a moment to fully initialize
sleep 2



while pidof hyprlock >/dev/null; do
    sleep 5
    current_time=$(date +%s)
    elapsed=$((current_time - last_time))
    
    # If the time difference is significantly larger than our sleep time (e.g. > 15s),
    # it indicates the system suspended and just resumed. We reset the timer.
    if [ "$elapsed" -gt 15 ]; then
        accumulated=0
    else
        accumulated=$((accumulated + elapsed))
    fi
    last_time=$current_time
    
    # Determine power status (AC vs Battery)
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
    
    # Select threshold based on power status
    if [ "$on_battery" -eq 1 ]; then
        limit=$THRESHOLD_BAT
    else
        limit=$THRESHOLD_AC
    fi
    
    # Suspend system if lock screen idle time exceeded limit
    if [ "$accumulated" -ge "$limit" ]; then
        systemctl suspend
        accumulated=0
        last_time=$(date +%s)
        # Sleep to prevent instant loop iteration on wakeup
        sleep 5
    fi
done
