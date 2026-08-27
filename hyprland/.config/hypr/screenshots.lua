-- Screenshots (grim + slurp + satty)

-- Region select -> copy straight to clipboard (no editor)
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))

-- Region select -> annotate in satty -> copy to clipboard only
hl.bind("CTRL + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | satty --filename - --early-exit --copy-command wl-copy"))
