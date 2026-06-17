-- Key and mouse bindings.
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod = "SUPER"

-- Programs (formerly `$var` hyprlang variables).
local terminal    = "kitty"
local fileManager = "kitty yazi"
local menu        = "vicinae toggle"
local browser     = "zen-browser"

-- Basic app launches
hl.bind(mainMod .. " + return",        hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C",             hl.dsp.window.close())
hl.bind(mainMod .. " + F",             hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V",             hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + space",         hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + T",     hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + P",             hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + SHIFT + P",     hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("SHIFT + " .. mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + E",             hl.dsp.exec_cmd("~/.local/bin/hypremoji-keep"))
hl.bind(mainMod .. " + Z",             hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + D",             hl.dsp.exec_cmd("discord"))
hl.bind(mainMod .. " + T",             hl.dsp.exec_cmd("teams-for-linux"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

-- Switch workspaces with mainMod + [0-9]
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Move active window with ALT + vim arrows
hl.bind("ALT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind("ALT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind("ALT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind("ALT + j", hl.dsp.window.move({ direction = "d" }))

-- Resize active window with mainMod + SHIFT + arrow keys
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x =  10, y =   0 }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -10, y =   0 }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x =   0, y = -10 }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x =   0, y =  10 }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume raise"),       { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume lower"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness raise"),          { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"),          { locked = true, repeating = true })

-- Media keys (require playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Keyboard brightness controls
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("~/dotfiles/scripts/toggle_kb_bright.sh down"))
hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd("~/dotfiles/scripts/toggle_kb_bright.sh up"))

-- Keyboard fan profile controls
hl.bind("XF86Launch4", hl.dsp.exec_cmd("~/dotfiles/scripts/profile_switch.sh"))

-- hyprwhspr - Toggle speech-to-text
hl.bind(
    mainMod .. " + ALT + D",
    hl.dsp.exec_cmd("/usr/lib/hyprwhspr/config/hyprland/hyprwhspr-tray.sh record"),
    { description = "Speech-to-text" }
)

-- HyprEmoji (bind previously sourced from ~/.config/hypremoji/hypremoji.conf)
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("hypremoji"))

--[[ Mission Control-style overview (keyboard fallbacks)
pcall(function()
    hl.bind(mainMod .. " + TAB", hl.plugin.hymission.toggle)
    hl.bind(mainMod .. " + A", function()
        hl.plugin.hymission.toggle("forceall")
    end)
    hl.bind(mainMod .. " + Escape", hl.plugin.hymission.close)
end)
]]


