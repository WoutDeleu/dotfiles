require("keybindings")
require("monitors.arrangement")
require("decoration")
require("monitors.workspaces")
require("screenshots")
require("windowrules")
require("waybar-floats")
require("touchpad")

-- HyprMod managed settings
require("hyprland-gui")

-- Layout
hl.config({
    general = {
        layout = "dwindle",
    },
    dwindle = {
        preserve_split = true,
    },
})

-- System config
hl.config({
    input = {
        follow_mouse = 2,
        kb_layout = "us",
        kb_options = "caps:escape",
        touchpad = {
            natural_scroll = true,
        },
    },
    cursor = {
        no_warps = false,
    },
})

-- env vars
hl.env("GTK_USE_PORTAL", "1")
hl.env("GDK_DEBUG", "portals")
