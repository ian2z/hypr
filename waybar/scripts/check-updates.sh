#!/usr/bin/env bash

# =============================================================================
# CHECK UPDATES - WAYBAR MODULE
# Verifica pacotes oficiais (checkupdates) e AUR (yay)
# =============================================================================

# Atualizações dos repositórios oficiais
updates_arch=$(checkupdates 2>/dev/null)
if [ -n "$updates_arch" ]; then
    count_arch=$(echo "$updates_arch" | wc -l)
else
    count_arch=0
fi

# Atualizações do AUR
count_aur=0
updates_aur=""
if command -v yay >/dev/null 2>&1; then
    updates_aur=$(yay -Qum 2>/dev/null)
    if [ -n "$updates_aur" ]; then
        count_aur=$(echo "$updates_aur" | wc -l)
    fi
fi

total=$((count_arch + count_aur))

if [ "$total" -eq 0 ]; then
    printf '{"text": "0", "tooltip": "Sistema atualizado", "class": "updated"}\n'
else
    tooltip_list=""
    if [ "$count_arch" -gt 0 ]; then
        tooltip_list="$updates_arch"
    fi
    if [ "$count_aur" -gt 0 ]; then
        if [ -n "$tooltip_list" ]; then
            tooltip_list="${tooltip_list}"$'\n\n[AUR]\n'"${updates_aur}"
        else
            tooltip_list="[AUR]"$'\n'"${updates_aur}"
        fi
    fi

    jq -c -n --unbuffered \
        --arg text "$total" \
        --arg tooltip "$tooltip_list" \
        --arg class "has-updates" \
        '{text: $text, tooltip: $tooltip, class: $class}'
fi
