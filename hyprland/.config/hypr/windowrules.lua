-- Window Rules
hl.window_rule({
    match = {
        class = "yazi-float",
    },
    float = true,
})
hl.window_rule({
    match = {
        class = "yazi-float",
    },
    size = "80% 80%",
})
hl.window_rule({
    match = {
        class = "yazi-float",
    },
    center = true,
})
hl.window_rule({
    match = {
        class = "Bitwarden",
    },
    float = true,
})
hl.window_rule({
    match = {
        class = "Bitwarden",
    },
    center = true,
})
hl.window_rule({
    match = {
        class = "chrome-nngceckbapebfimnlniiiahkandclblb-Default",
    },
    float = true,
})
hl.window_rule({
    match = {
        class = "chrome-nngceckbapebfimnlniiiahkandclblb-Default",
    },
    center = true,
})
hl.window_rule({
    match = {
        class = "chrome-nngceckbapebfimnlniiiahkandclblb-Default",
    },
    size = "600 800",
})
hl.window_rule({
    match = {
        class = "file_chooser",
    },
    float = true,
})
hl.window_rule({
    match = {
        class = "file_chooser",
    },
    size = "900 600",
})
hl.window_rule({
    match = {
        class = "file_chooser",
    },
    center = true,
})

-- Yazi File Chooser Popup Rules
hl.window_rule({
    match = {
        class = "^(file_chooser)$",
    },
    float = true,
})
hl.window_rule({
    match = {
        class = "^(file_chooser)$",
    },
    center = true,
})
hl.window_rule({
    match = {
        class = "^(file_chooser)$",
    },
    size = "1000 650",
})

-- Startup workspace assignments (Helium PWAs ignore exec workspace rules when browser is already running)
hl.window_rule({
    match = {
        class = "chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Default",
    },
    workspace = "5 silent",
})
hl.window_rule({
    match = {
        class = "chrome-kjbdgfilnfhdoflbpgamdcdgpehopbep-Default",
    },
    workspace = "7 silent",
})

-- Rofi blur
hl.layer_rule({
    match = {
        namespace = "rofi",
    },
    blur = true,
    ignore_alpha = 1,
})
