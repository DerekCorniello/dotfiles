-- Autostart: processes spawned on Hyprland start.
-- Monitor hotplug layout is handled by the bash monitor-listener.sh
-- (the proven-working script from the original .conf). A pure-Lua
-- apply_layout caused boot-time hardlocks (race + recursion risk),
-- so the bash script is invoked as a fallback per the migration plan.
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- hl.exec_cmd() spawns asynchronously; no & or disown needed.

local function run(cmd)
    hl.exec_cmd(cmd)
end

hl.on("hyprland.start", function()
    run("waybar")
    run("swaync")
    run("swayosd-server --top-margin 0.95")
    run("hypridle")
    run("hyprpaper")
    run("USE_LAYER_SHELL=0 vicinae server")

    -- monitor-listener.sh sleeps 0.3s, then runs apply_layout and
    -- listens for monitor.added/removed events via the Hyprland IPC
    -- socket. This must run in the background (exec_cmd is async).
    run("~/.config/hypr/monitor-listener.sh")
end)
