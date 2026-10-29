-- =============================================================================
-- Monitor Configuration
-- =============================================================================

-- Monitor principal (AOC 24G2W1G4 144Hz via DisplayPort - Paisagem invertido 180°)
hl.monitor({
    output    = "DP-1",
    mode      = "1920x1080@144",
    position  = "0x0",
    scale     = 1.0,
    transform = 2,
})

-- Monitor secundário (AOC 24G2W1G3 144Hz via HDMI - Retrato)
hl.monitor({
    output    = "HDMI-A-1",
    mode      = "1920x1080@144",
    position  = "1920x0",
    scale     = 1.0,
    transform = 1,
})

-- Fallback para qualquer outro monitor conectado dinamicamente
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1.0,
})

-- 2. Forçando a Workspace 1 (e as principais)l
hl.workspace_rule({
    workspace = "1",
    monitor = "DP-1",
    default = true
})