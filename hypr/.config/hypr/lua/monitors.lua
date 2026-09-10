-- Default monitor layout.
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Hotplug workspace moves are Roku-gated in lua/roku-workspaces.lua
-- (+ roku-layout.sh). Other HDMI outputs use Hyprland defaults.

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

-- DP-4 Roku TV: scale <1 needed (1.0 is huge). <1 breaks Electron
-- via Chromium bug (#12608) -> shrunken content.
-- Workaround: wl-veil -f wp_fractional_scale_manager_v1 <app> (wl-proxy)
-- Patched: ~/.local/bin/{discord,slack,teams,steam} + desktop overrides
-- Fallback: ~/.config/electron-flags.conf
hl.monitor({
    output   = "DP-4",
    mode     = "1920x1080@60.00Hz",
    position = "auto",
    scale    = 0.75,
})

hl.monitor({
    output   = "DP-5",
    mode     = "1920x1080@60.00Hz",
    position = "auto",
    scale    = 0.75,
})

hl.monitor({
    output   = "desc:RKU Roku TV",
    mode     = "1920x1080@60.00Hz",
    position = "auto",
    scale    = 0.75,
})

hl.monitor({
    output   = "eDP-1",
    mode     = "2560x1600@165.00Hz",
    position = "0x0",
    scale    = 1.25,
})
