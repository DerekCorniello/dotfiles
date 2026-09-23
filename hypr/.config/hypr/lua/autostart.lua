-- Autostart: processes spawned on Hyprland start.
-- Monitor hotplug layout is handled natively by lua/roku-workspaces.lua
-- (hl.on monitor.added/removed -> roku-layout.sh, Roku-gated).
-- The old monitor-listener.sh socat loop is retired; do NOT re-enable it
-- or you will get duplicate moves fighting the Lua triggers.
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
    --     -- run("wl-paste --primary --watch wl-copy")
end)
