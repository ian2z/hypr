#!/usr/bin/env bash

# Procura processo onde o binário é quickshell e contém powermenu na linha de comando
pid=""
for p in $(pgrep -x quickshell 2>/dev/null); do
    cmd=$(tr '\0' ' ' < "/proc/$p/cmdline" 2>/dev/null)
    if [[ "$cmd" == *"powermenu"* ]]; then
        pid="$p"
        break
    fi
done

if [ -n "$pid" ]; then
    kill "$pid"
else
    quickshell -p "$HOME/.config/quickshell/powermenu/shell.qml" &
fi
