#!/usr/bin/env bash

# Toggle script for Quickshell Dynamic Island
qs ipc call island toggle 2>/dev/null || quickshell -d
