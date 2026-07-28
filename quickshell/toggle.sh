#!/usr/bin/env bash

# Toggle script for Quickshell Spotify widget
if pgrep -x quickshell >/dev/null 2>&1; then
    pkill -x quickshell
else
    quickshell -d
fi
