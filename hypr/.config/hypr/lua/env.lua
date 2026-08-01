-- Environment variables and animation curves.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
-- See https://wiki.hypr.land/Configuring/Basics/Animations/

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "x11")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")

-- Snappier bezier: quicker start and end
hl.curve("myBezier", { type = "bezier", points = { { 0.3, 1 }, { 0.6, 1 } } })
