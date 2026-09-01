-- =============================================================================
-- Keybindings & Mouse Controls
-- =============================================================================

local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = "nautilus"
local browser     = "zen-browser"

local home        = os.getenv("HOME")
local menu        = home .. "/.config/rofi/launchers/type-1/launcher.sh"
local volumemenu  = home .. "/.config/rofi/applets/bin/volume.sh"
local powermenu   = home .. "/.config/rofi/powermenu/type-1/powermenu.sh"
local waybar_ref  = home .. "/.config/waybar/scripts/refresh.sh"

--------------------------------------------------------------------------------
-- Aplicativos e Sistema
--------------------------------------------------------------------------------
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(powermenu))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(volumemenu))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(waybar_ref))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))

--------------------------------------------------------------------------------
-- Screenshots (Print)
--------------------------------------------------------------------------------
hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))

--------------------------------------------------------------------------------
-- Foco e Movimentação de Janelas
--------------------------------------------------------------------------------
-- Mover foco
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Mover janela dentro do layout
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

--------------------------------------------------------------------------------
-- Workspaces (1 a 5)
--------------------------------------------------------------------------------
for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

--------------------------------------------------------------------------------
-- Controle do Mouse
--------------------------------------------------------------------------------
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------------------------------------------------------------------
-- Teclas Multimídia (Áudio e Brilho)
--------------------------------------------------------------------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set 5%+"),                     { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 5%-"),                     { repeating = true, locked = true })
