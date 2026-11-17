-- =============================================================================
-- Look & Feel, Window Layout and Input Settings
-- =============================================================================

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(FFFDF9e6)", "rgba(EFE6DCe6)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
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
        kb_model   = "thinkpad",
        follow_mouse = 1,

        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,     -- Ativa o clique com um toque leve no touchpad
            disable_while_typing = true,     -- Evita cliques acidentais enquanto você digita
        },
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

-- =============================================================================
-- Regras de Janelas (Window Rules)
-- =============================================================================

-- Suprime solicitações de maximização automática de apps (ex: Kitty/Wayland abrindo em tela cheia)
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
