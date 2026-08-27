hl.config({
    decoration = {
        rounding = 10,
    },
})

-- Inactive windows fade back a little
hl.config({
    decoration = {
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        blur = {
            enabled = true,
            size = 2,
            passes = 1,
        },
    },
    general = {
        border_size = 5,
        col = {
            active_border = {
                colors = {"rgba(5ea1ffff)"},
                angle = 1,
            },
        },
    },
    animations = {
        enabled = true,
    },
})

hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Amber")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Amber")
hl.env("XCURSOR_SIZE", "24")

-- Syntax: animation = NAME, ONOFF, SPEED, CURVE [, STYLE]
hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 3,
    bezier = "default",
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 3,
    bezier = "default",
})
hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 3,
    bezier = "default",
})
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 4,
    bezier = "default",
})
