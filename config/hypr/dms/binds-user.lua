---@diagnostic disable: undefined-global

-- DMS user keybind overrides (edit via Control Center or dms; do not remove this header)

hl.unbind("SUPER + C")
hl.bind("SUPER + C", hl.dsp.exec_cmd("amberol"), { locked = true, description = "amberol" })
hl.unbind("SUPER + G")
hl.bind("SUPER + G", hl.dsp.exec_cmd("amberol"), { description = "Amberol" })
hl.unbind("XF86AudioLowerVolume")
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), { repeating = true, description = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-" })
