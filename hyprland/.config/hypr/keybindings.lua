var_mainMod = "ALT"

local var_terminal = "kitty"
local var_browser = "helium-browser"
local var_menu = "~/.config/rofi/launchers/type-2/launcher.sh"
local var_powermenu = "~/.config/rofi/powermenu/type-2/powermenu.sh"

hl.bind(var_mainMod .. " + Q", hl.dsp.exec_cmd(var_terminal))
hl.bind(var_mainMod .. " + B", hl.dsp.exec_cmd(var_browser))
hl.bind(var_mainMod .. " + C", hl.dsp.window.close())

-- bind = $mainMod, M, exec, command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit
hl.bind(var_mainMod .. " + E", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-yazi.sh"))
hl.bind(var_mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(var_mainMod .. " + R", hl.dsp.exec_cmd(var_menu))
hl.bind(var_mainMod .. " + Escape", hl.dsp.exec_cmd(var_powermenu))
hl.bind(var_mainMod .. " + F", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(var_mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(var_mainMod .. " + T", hl.dsp.layout("togglesplit"))

-- Move focus (vim keys + arrows)
hl.bind(var_mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(var_mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(var_mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(var_mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(var_mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(var_mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(var_mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(var_mainMod .. " + right", hl.dsp.focus({ direction = "right" }))

-- to switch between windows in a floating workspace
hl.bind("ALT + space", hl.dsp.exec_cmd("$(hyprctl activewindow -j | jq '.floating') && hyprctl dispatch 'hl.dsp.window.cycle_next({tiled=true})' || hyprctl dispatch 'hl.dsp.window.cycle_next({floating=true})'"))

-- Move window (vim keys + arrows)
hl.bind(var_mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(var_mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(var_mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(var_mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(var_mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(var_mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
hl.bind(var_mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(var_mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))

-- Resize window (vim keys + arrows)
hl.bind(var_mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), {
    repeating = true,
})
hl.bind(var_mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), {
    repeating = true,
})
hl.bind(var_mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), {
    repeating = true,
})
hl.bind(var_mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), {
    repeating = true,
})
hl.bind(var_mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), {
    repeating = true,
})
hl.bind(var_mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), {
    repeating = true,
})
hl.bind(var_mainMod .. " + CTRL + SHIFT + left", hl.dsp.window.move({ monitor = "l" }))
hl.bind(var_mainMod .. " + CTRL + SHIFT + right", hl.dsp.window.move({ monitor = "r" }))
hl.bind(var_mainMod .. " + CTRL + SHIFT + H", hl.dsp.window.move({ monitor = "l" }))
hl.bind(var_mainMod .. " + CTRL + SHIFT + L", hl.dsp.window.move({ monitor = "r" }))
hl.bind(var_mainMod .. " + SUPER + left", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(var_mainMod .. " + SUPER + right", hl.dsp.workspace.move({ monitor = "r" }))
hl.bind(var_mainMod .. " + SUPER + H", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(var_mainMod .. " + SUPER + L", hl.dsp.workspace.move({ monitor = "r" }))

-- Notification center (swaync)
hl.bind("CTRL + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind("CTRL + N", hl.dsp.exec_cmd("swaync-client -d -sw"))
hl.bind("CTRL + SHIFT + C", hl.dsp.exec_cmd("swaync-client -C -sw"))

-- NuPhy: swap left Alt<->Win so the Opt key

-- acts as the main modifier (SUPER), matching the laptop's Win key.

-- Per-device kb_options override the global ones, so caps:escape is repeated here.
hl.device({
    name = "nuphy-halo65-v2-2-keyboard",
    kb_options = "caps:escape,altwin:swap_lalt_lwin",
})
hl.device({
    name = "nuphy-air75-v2-1-keyboard",
    kb_options = "caps:escape,altwin:swap_lalt_lwin",
})
hl.device({
    name = "nordic-semiconductor-nuphy-halo65-v2-dongle",
    kb_options = "caps:escape,altwin:swap_lalt_lwin",
})
hl.device({
    name = "keychron-k2",
    kb_options = "caps:escape,altwin:swap_lalt_lwin",
})

-- Mouse/trackpad
hl.bind(var_mainMod .. " + mouse:272", hl.dsp.window.drag(), {
    mouse = true,
})
hl.bind(var_mainMod .. " + mouse:273", hl.dsp.window.resize(), {
    mouse = true,
})

-- Change scroll speed for Brave (factor < 1.0 = slower)
hl.window_rule({
    match = {
        class = "helium",
    },
    scroll_touchpad = 0.5,
})

-- ── Lid switch ────────────────────────────────────────────────────────────

-- logind (lid.conf) handles suspend-then-hibernate when undocked.

-- When docked (HandleLidSwitchDocked=ignore), Hyprland disables/re-enables eDP-1.
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprctl eval 'hl.monitor({output=\"eDP-1\", disabled=true})'"), {
    locked = true,
})
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprctl eval 'hl.monitor({output=\"eDP-1\", mode=\"1920x1080\", position=\"auto\", scale=1, bitdepth=8})'"), {
    locked = true,
})

-- ── Hotkeys ───────────────────────────────────────────────────────────────
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), {
    locked = true,
})
hl.bind("XF86Calculator", hl.dsp.exec_cmd(var_terminal))
hl.bind("XF86SelectiveScreenshot", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("swayosd-client --playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("swayosd-client --playerctl previous"))

-- Increase Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), {
    repeating = true,
    locked = true,
})

-- Decrease Volume
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), {
    repeating = true,
    locked = true,
})

-- Mute/Unmute Audio
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), {
    locked = true,
})

-- Increase Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"), {
    repeating = true,
    locked = true,
})

-- Decrease Brightness
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), {
    repeating = true,
    locked = true,
})
