-- Environment variables and animation curves.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
-- See https://wiki.hypr.land/Configuring/Basics/Animations/

hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. os.getenv("PATH"))
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
-- kbuildsycoca (KDE's service DB, used by Dolphin's "Open With" and file
-- associations) only discovers apps through the *_applications.menu named by
-- this prefix. Not set (or meant for a Plasma session), it builds an empty
-- service DB and Dolphin shows no apps. This system ships gnome-applications.menu.
hl.env("XDG_MENU_PREFIX", "gnome-")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
-- PRIME render offload: heavy GL/VK apps (games) default to NVIDIA dGPU,
-- compositor keeps driving outputs on Intel iGPU. Buffers shared via DMA-BUF.
hl.env("__NV_PRIME_RENDER_OFFLOAD", "1")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")

-- Snappier bezier: quicker start and end
hl.curve("myBezier", { type = "bezier", points = { { 0.3, 1 }, { 0.6, 1 } } })
