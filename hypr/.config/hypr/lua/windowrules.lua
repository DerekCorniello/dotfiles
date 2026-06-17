-- Window rules, including those inlined from ~/.config/hypremoji/hypremoji.conf.
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Pseudotile code editors (disabled: interferes with VSCode fullscreen)
-- hl.window_rule({
--     name   = "pseudo-code",
--     match  = { class = "^(code|Code|jetbrains-.*)$" },
--     pseudo = true,
-- })

-- Suppress maximize events from all apps (disabled: breaks VSCode fullscreen)
-- hl.window_rule({
--     name            = "suppress-maximize",
--     match           = { class = ".*" },
--     suppress_event  = "maximize",
-- })

-- Fix XWayland floating/no focus
hl.window_rule({
    name  = "xwayland-fix",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- HyprEmoji: float, place at cursor, fixed size (inlined from hypremoji.conf)
hl.window_rule({
    name  = "hypremoji-float",
    match = { title = "^(HyprEmoji)$" },
    float = true,
})

hl.window_rule({
    name  = "hypremoji-place",
    match = { title = "^(HyprEmoji)$" },
    move  = {
        "cursor_x-(window_w*0.5)",
        "cursor_y-(window_h*0.95)",
    },
    size = { 307, 340 },
})

hl.window_rule({
    name  = "swaync-float",
    match = { title = "swaync" },
    float = true,
})
