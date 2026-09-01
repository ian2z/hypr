-- =============================================================================
-- Autostart Applications & Daemons
-- =============================================================================

hl.on("hyprland.start", function()
    -- Sincronização de ambiente para systemd e dbus
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Daemons e serviços em segundo plano
    hl.exec_cmd("bluetoothctl power off")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("dunst")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("hypridle")
end)
