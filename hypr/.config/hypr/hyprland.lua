-- Hyprland configuration (Hyprland 0.55+ Lua schema).
-- Refer to https://wiki.hypr.land/Configuring/Start/
-- This file is modular: configuration is split into the lua/ directory and
-- loaded below in the order they are evaluated.

local config_dir = (os.getenv("HYPRLAND_CONFIG") or (os.getenv("HOME") .. "/.config/hypr"))

dofile(config_dir .. "/lua/env.lua")
dofile(config_dir .. "/lua/monitors.lua")
dofile(config_dir .. "/lua/devices.lua")
dofile(config_dir .. "/lua/windowrules.lua")
dofile(config_dir .. "/lua/binds.lua")
dofile(config_dir .. "/lua/autostart.lua")

-- Top-level config blocks. These are split into separate hl.config() calls
-- because they are independent sections in the original hyprlang.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    general = {
        gaps_in          = 0,
        gaps_out         = 0,
        border_size      = 2,
        col              = {
            active_border   = "rgba(33ccffff)",
            inactive_border = "rgba(000000ff)",
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 0,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        blur             = {
            enabled  = false,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    input = {
        kb_layout    = "us",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "",
        kb_rules     = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad     = {
            natural_scroll       = false,
            scroll_factor        = 0.5,
            clickfinger_behavior = true,
        },
    },

    cursor = {
        no_hardware_cursors = false,
    },

    gestures = {},

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        focus_on_activate       = true,
    },
})

-- Animations (uses the bezier defined in env.lua).
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.config({ animations = { enabled = false } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "myBezier", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 4, bezier = "myBezier" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "myBezier" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "myBezier" })

-- Layouts.
-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

-- hymission plugin configuration (Mission Control-style overview).
hl.config({
    plugin = {
        hymission = {
            outer_padding_top = 92,
            outer_padding_right = 32,
            outer_padding_bottom = 32,
            outer_padding_left = 32,
            layout_engine = "grid",
            expand_selected_window = 1,
            overview_focus_follows_mouse = 1,
            workspace_strip_anchor = "left",
            workspace_strip_empty_mode = "existing",
            workspace_strip_thickness = 160,
            hide_bar_when_strip = 1,
        },
    },
})

-- MacBook-style gestures
-- 3-finger vertical: toggle Mission Control overview
hl.plugin.hymission.gesture({
    fingers = 3,
    direction = "vertical",
    action = "toggle",
})

-- 3-finger horizontal: switch workspaces
hl.plugin.hymission.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

