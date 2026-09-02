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
    run("hyprpm reload")
    -- Rebuild KDE's service DB at every login so Dolphin's "Open With" /
    -- file associations survive package updates, which otherwise rebuild the
    -- cache without XDG_MENU_PREFIX and leave it empty again.
    run("kbuildsycoca6 --noincremental")
    run("systemctl --user start graphical-session.target")
    run("waybar")
    run("swaync")
    run("swayosd-server --top-margin 0.95")
    -- hypridle now via systemd --user service (autostart duplicate caused "Is hypridle already running?")
    -- run("hypridle")
    run("hyprpaper")
    run("USE_LAYER_SHELL=0 vicinae server")
    --     -- run("wl-paste --primary --watch wl-copy")

    -- monitor-listener.sh sleeps 0.3s, then runs apply_layout and
    -- listens for monitor.added/removed events via the Hyprland IPC
    -- socket. This must run in the background (exec_cmd is async).
    run("~/.config/hypr/monitor-listener.sh")
end)
