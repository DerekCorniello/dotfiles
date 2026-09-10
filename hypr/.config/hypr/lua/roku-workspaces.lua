-- Roku-only workspace auto-move (replaces monitor-listener.sh socat loop).
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Expanding-functionality/
--
-- Why this shape:
-- - Old monitor-listener.sh matched ANY HDMI-A-1. This only acts when the
--   monitor on HDMI-A-1 describes itself as "RKU Roku TV". Any other HDMI
--   is intentionally a no-op so Hyprland's default behavior applies.
-- - No static hl.workspace_rule with monitor="HDMI-A-1" on purpose: that
--   would bind workspaces to ANYTHING plugged into HDMI-A-1, not just Roku.
--   A desc: rule (monitor="desc:RKU Roku TV") would be Roku-specific, but an
--   imperative move on plug is what the user asked for ("move all workspaces
--   to one monitor"), and it avoids workspaces clinging to an absent monitor.
-- - Heavy lifting lives in ../roku-layout.sh, spawned async via hl.exec_cmd.
--   The shell script sleeps OUTSIDE the compositor thread. A previous pure-Lua
--   apply_layout caused boot-time hardlocks (see old autostart.lua note), so
--   do NOT move dispatch loops back into this file.

local LAYOUT = (os.getenv("HOME") .. "/.config/hypr/roku-layout.sh")

local function trigger(reason)
    -- Small settle delay so `hyprctl monitors -j` sees the new output.
    -- Quoted to survive spaces; logged to /tmp/roku-layout.log by the script.
    hl.exec_cmd("sleep 0.5; '" .. LAYOUT .. "' " .. reason .. " >>/tmp/roku-layout.log 2>&1")
end

hl.on("monitor.added", function(_mon)
    trigger("added")
end)

hl.on("monitor.removed", function(_mon)
    trigger("removed")
end)

hl.on("hyprland.start", function()
    trigger("start")
end)
