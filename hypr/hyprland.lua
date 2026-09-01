-- =============================================================================
-- HYPRLAND CONFIG - CACHYOS / IAN - 2026
-- Modular Lua Entry Point
-- =============================================================================

-- Assegura o caminho de busca para módulos em ~/.config/hypr
local config_dir = os.getenv("HOME") .. "/.config/hypr"
package.path = config_dir .. "/?.lua;" .. config_dir .. "/?/init.lua;" .. package.path

-- Carrega os módulos
require("configs.env")
require("configs.monitors")
require("configs.autostart")
require("configs.appearance")
require("configs.keybinds")
