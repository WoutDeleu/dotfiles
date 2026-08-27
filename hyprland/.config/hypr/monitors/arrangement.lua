-- Monitor arrangement is orchestrated dynamically by

-- ~/.config/hypr/monitors/monitor-workspaces.sh

-- which detects the connected monitors and applies the matching profile from

-- ~/.config/hypr/monitors/layouts/ (positions + workspace assignment).

--

-- This file only holds the base fallback — used until the orchestrator runs and

-- for any monitor no profile arranges — plus global display settings.
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

hl.monitor({
    output = "",
    disabled = false,
    mode = "preferred",
    position = "auto",
    scale = 1,
})
