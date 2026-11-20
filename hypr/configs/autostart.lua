-- =============================================================================
-- Autostart Applications & Daemons
-- =============================================================================

hl.on("hyprland.start", function()
    -- Sincronização de ambiente para systemd e dbus (essencial para portais e telas)
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Daemons e personalizações
    hl.exec_cmd("quickshell -d")   -- Dynamic Island & Shell Principal (Substitui Waybar e Dunst)
    hl.exec_cmd("hyprpaper")
    -- hl.exec_cmd("hyprsunset -t 4500") -- Controlado com segurança pelo Quickshell (sunset_control.sh)
    hl.exec_cmd("hypridle")
    hl.exec_cmd("openrgb --profile branco")
    -- hl.exec_cmd("nm-applet --indicator")
end)
