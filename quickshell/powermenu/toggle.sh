#!/usr/bin/env bash

# Se o quickshell já estiver aberto, fecha
if pgrep -x quickshell > /dev/null 2>&1; then
    pkill -x quickshell
else
    quickshell -p "$HOME/.config/quickshell/powermenu/shell.qml" &
fi
