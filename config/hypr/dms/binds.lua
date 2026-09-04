---@diagnostic disable: undefined-global
-- ==========================================
-- HYPRLAND KEYBINDS (dms/binds.lua)
-- ==========================================

-- System & Window Core Operations
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + END", hl.dsp.window.kill())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + SHIFT + T", hl.dsp.window.float())
--hl.bind("SUPER + W", hl.dsp.group.toggle())
hl.bind("SUPER + R", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exit())
hl.bind("SUPER + SHIFT + P", hl.dsp.dpms("toggle"))
hl.bind("SUPER + bracketleft", hl.dsp.layout("preselect l"))
hl.bind("SUPER + bracketright", hl.dsp.layout("preselect r"))
hl.bind("ALT + space", hl.dsp.exec_cmd("dms ipc call spotlight-bar toggle"))
--hl.bind("SUPER + TAB", hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"))

-- Application Launchers
hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus"))
hl.bind("SUPER + G", hl.dsp.exec_cmd("spotify"))
hl.bind("SUPER + H", hl.dsp.exec_cmd("glava"))
hl.bind("SUPER + W", hl.dsp.exec_cmd("waydroid session stop"))
hl.bind("SUPER + Z", hl.dsp.exec_cmd("sh -c 'waydroid session stop && waydroid show-full-ui'"))
hl.bind("ALT + N", hl.dsp.exec_cmd("playerctl next"))
hl.bind("ALT + B", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("ALT + M", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("google-chrome-stable"))
hl.bind("SUPER + T", hl.dsp.exec_cmd("ghostty"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("g4music"))
hl.bind("ALT + Z", hl.dsp.exec_cmd("code"))
hl.bind("ALT + C", hl.dsp.exec_cmd("/home/shadrack/.local/bin/chorus"))
--hl.bind("CTRL + End", hl.dsp.exec_cmd("nixedit"))

-- Screenshots & DMS Integration
hl.bind("Print", hl.dsp.exec_cmd("dms screenshot full"))
hl.bind("ALT + Print", hl.dsp.exec_cmd("dms screenshot window"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("dms screenshot"))
hl.bind("CTRL + SHIFT + Delete", hl.dsp.exec_cmd("dms ipc call processlist focusOrToggle"))
hl.bind("CTRL + SHIFT + R", hl.dsp.exec_cmd("dms ipc call workspace-rename open"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("dms ipc call lock lock"))
--hl.bind("SUPER + M", hl.dsp.exec_cmd("dms ipc call processlist focusOrToggle"))
hl.bind("SUPER + N", hl.dsp.exec_cmd("dms ipc call notifications toggle"))
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("dms ipc call notepad toggle"))
hl.bind("SUPER + SHIFT + Slash", hl.dsp.exec_cmd("dms ipc call keybinds toggle hyprland"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("dms ipc call window-rules toggle"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
hl.bind("SUPER + X", hl.dsp.exec_cmd("dms ipc call powermenu toggle"))
hl.bind("SUPER + Y", hl.dsp.exec_cmd("dms ipc call dankdash wallpaper"))
hl.bind("SUPER + comma", hl.dsp.exec_cmd("dms ipc call settings focusOrToggle"))
hl.bind("SUPER + space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
hl.bind("Menu", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))

-- Hardware & Media Controls (Locked)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("dms ipc call audio micmute"), { repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-"), { repeating = true })
hl.bind("CTRL + XF86AudioRaiseVolume", hl.dsp.exec_cmd("dms ipc call mpris increment 2"), { repeating = true })
hl.bind("CTRL + XF86AudioLowerVolume", hl.dsp.exec_cmd("dms ipc call mpris decrement 2"), { repeating = true })
--hl.bind("F2", hl.dsp.exec_cmd("dms ipc call mpris previous"), { repeating = true })
--hl.bind("F7", hl.dsp.exec_cmd("dms ipc call mpris next"), { repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("dms ipc call mpris playPause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("dms ipc call mpris playPause"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true })

-- Workspaces 1-9
for i = 1, 9 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad Settings
hl.bind("ALT + H", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Relative Workspace Navigation (E-1 / E+1)
hl.bind("SUPER + I", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + U", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + Page_Up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + Page_Down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + CTRL + I", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + U", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind("SUPER + CTRL + up", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + down", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind("SUPER + CTRL + mouse_up", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + down", hl.dsp.window.move({ workspace = "e+1" }))
--hl.bind("F2", hl.dsp.focus({ workspace = "e+1" }))
--hl.bind("F2", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("Home", hl.dsp.window.close())
hl.bind("Home", hl.dsp.focus({ workspace = "e+1" }))

-- Global Window Focus Traversal
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
--hl.bind("SUPER + L", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + Home", hl.dsp.focus({ window = "first" }))
--hl.bind("SUPER + End", hl.dsp.focus({ window = "last" }))

-- Layout Group Specific Focus Traversal
hl.bind("SUPER + CTRL + H", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + CTRL + J", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + CTRL + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + CTRL + L", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + CTRL + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + CTRL + right", hl.dsp.focus({ direction = "right" }))

-- Moving Window Vectors
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Mouse Direct Manipulation Interactions
hl.config({
    binds = {
        drag_threshold = 10  -- Fire a drag event only after dragging for more than 10px
    }
})
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
