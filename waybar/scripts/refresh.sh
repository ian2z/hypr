#!/usr/bin/env bash

# Recarrega se estiver rodando, ou inicia se não estiver
if pgrep -x "waybar" > /dev/null; then
    pkill waybar
    sleep 0.2
fi

hyprctl dispatch "hl.dsp.exec_cmd('waybar')"
