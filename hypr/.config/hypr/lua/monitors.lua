-- Default monitor layout.
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- These run on Hyprland start; the hotplug listener in autostart.lua rebalances
-- workspaces when monitors are added or removed.

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "preferred",
    position = "-2560x-20",
    scale    = 0.75,
})

hl.monitor({
    output   = "DP-3",
    mode     = "1920x1080@60.00Hz",
    position = "auto-left",
    scale    = 1,
})

hl.monitor({
    output   = "DP-1",
    mode     = "1920x1080@60.00Hz",
    position = "auto-left",
    scale    = 1,
})

hl.monitor({
    output   = "eDP-1",
    mode     = "2560x1600@165.00Hz",
    position = "0x0",
    scale    = 1.25,
})
