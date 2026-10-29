-- =============================================================================
-- Look & Feel, Window Layout and Input Settings
-- =============================================================================

hl.config({
    general = {
        gaps_in  = 3,
        gaps_out = 5,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(FFFDF9e6)", "rgba(EFE6DCe6)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        layout = "dwindle",
    },

    decoration = {
        rounding = 0,
        blur = {
            enabled = true,
            size    = 3,
            passes  = 1,
        },
    },

    misc = {
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,
    },

    input = {
        kb_layout  = "br",
        kb_variant = "",
        kb_model   = "",
        follow_mouse = 1,

        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
        },
    },

    cursor = {
        no_hardware_cursors = true,
    },
})

-- Ignora solicitações de maximização automáticas das aplicações (evita abrir em fullscreen/maximized)
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Janelas flutuantes utilitárias
hl.window_rule({
    name  = "pavucontrol-float",
    match = { class = "org.pulseaudio.pavucontrol" },
    float = true,
})

