-- Hyprland Configuration

-- https://wiki.hypr.land/Configuring/

-- ==================

-- MONITOR CONFIG

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1.0,
})

hl.env("GDK_BACKEND", "wayland,x11")
-- ==================

-- STARTUP APPS

-- ==================

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user start hyprland-session.target")
    hl.exec_cmd("qs -c overview")
    hl.exec_cmd("hyprctl setcursor Adwaita 24")

end)



-- ==================

-- INPUT CONFIG

-- ==================

hl.config({
    input = {
        kb_layout = "us",
        numlock_by_default = true,
    },
})

-- ==================

-- DECORATION

-- ==================

hl.config({
    decoration = {
        rounding = 12,
        active_opacity = 1.0,
        inactive_opacity = 0.85,
        shadow = {
            enabled = true,
            range = 30,
            render_power = 5,
            offset = "0 5",
            color = "rgba(00000070)",
        },
    },
})

-- ==================

-- ANIMATIONS

-- ==================

hl.config({
    animations = {
        enabled = true,
    },
})

-- ==================

-- LAYOUTS

-- ==================

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        mfact = 0.5,
    },
})

-- ==================

-- MISC

-- ==================

hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})

-- ==================
-- WINDOW RULES
-- ==================

hl.window_rule({
    match = { class = "^(org.wezfurlong.wezterm)$" },
    tile = true,
})

hl.window_rule({
    match = { class = "^(org.gnome.)$" },
    rounding = 12,
})

hl.window_rule({
    match = { class = "^(gnome-control-center)$" },
    tile = true,
})

hl.window_rule({
    match = { class = "^(pavucontrol)$" },
    float = true,
})

hl.window_rule({
    match = { class = "^(nm-connection-editor)$" },
    tile = true,
})

hl.window_rule({
    match = { class = "^(org.gnome.Calculator)$" },
    float = true,
})

hl.window_rule({
    match = { class = "^(gnome-calculator)$" },
    float = true,
})

hl.window_rule({
    match = { class = "^(galculator)$" },
    float = true,
})

hl.window_rule({
    match = { class = "^(blueman-manager)$" },
    float = true,
})

hl.window_rule({
    match = { class = "^(xdg-desktop-portal)$" },
    float = true,
})

hl.window_rule({
    match = { title = "^(notificationtoasts)" },
    no_initial_focus = true,
    pin = true, -- Combines both rules for notificationtoasts into one clean rule block
})

hl.window_rule({
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
})

hl.window_rule({
    match = { class = "^(zoom)$" },
    float = true,
})

-- DMS windows floating by default

-- ! Hyprland doesn't size these windows correctly so disabling by default here

hl.window_rule({
    match = { class = "^(org.quickshell)$" },
    float = true,
})

hl.layer_rule({
    match = {
        namespace = "match:namespace ^(quickshell)$",
    },
    no_anim = false,
})

hl.layer_rule({
    match = {
        namespace = "match:namespace ^dms:.*",
    },
    no_anim = false,
})

-- Load your modular configuration files
require("dms.colors")
require("dms.outputs")
require("dms.layout")
require("dms.cursor")
require("dms.binds")
require("dms.windowrules")
-- =========

-- GESTURES

-- =========

hl.gesture({
  fingers = 4,
  direction = "horizontal",
  action = "workspace"
})

hl.gesture({
  fingers = 3,
  direction = "vertical",
  action = "float",
})

hl.gesture({
  fingers = 4,
  direction = "vertical",
  action = "fullscreen",
})
