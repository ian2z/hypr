#!/usr/bin/env bash

# Toggle para expandir/recolher a Dynamic Island via IPC do Quickshell
if pgrep -f "quickshell.*shell.qml" >/dev/null 2>&1 || pgrep -x quickshell >/dev/null 2>&1; then
    quickshell ipc -p "$HOME/.config/quickshell/shell.qml" call island toggle >/dev/null 2>&1
else
    quickshell -d
fi
