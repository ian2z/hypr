-- =============================================================================
-- Environment Variables & Dark Mode Settings
-- =============================================================================

-- GTK Dark Theme via gsettings
hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"')
hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')

-- Desktop / Session Info
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- GTK Backend
hl.env("GDK_BACKEND", "wayland,x11,*")

-- Qt Configuration
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_STYLE_OVERRIDE", "kvantum")

-- GTK / Libadwaita Preference
hl.env("GTK_APPLICATION_PREFER_DARK_THEME", "1")
hl.env("GTK_APPEARANCE_PREFERENCE", "dark")
