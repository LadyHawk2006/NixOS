-- DMS user keybind overrides (edit via Control Center or dms; do not remove this header)

hl.unbind("SUPER + G")
hl.bind("SUPER + G", hl.dsp.exec_cmd("amberol"), { description = "Amberol" })
hl.unbind("SUPER + C")
hl.bind("SUPER + C", hl.dsp.exec_cmd("amberol"), { locked = true, description = "amberol" })
