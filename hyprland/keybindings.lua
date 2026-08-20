---------------------
---- KEYBINDINGS ----
---------------------
require("var") -- Load variables from a separate file (mainMod, terminal, etc.)

-- -- ───────── Mouse & Gestures ─────────
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
-- hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ───────── Window Management ─────────
-- NOTE: "drag windows".
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. "+ C", hl.dsp.window.close())

-- ───────── System & Hardware ─────────
-- hl.bind("ALT + SHIFT", hl.dsp.exec_cmd("hyprctl switchxkblayout main prev"))
-- hl.bind("SHIFT + ALT", hl.dsp.exec_cmd("hyprctl switchxkblayout main next"))

hl.bind("Caps_Lock", hl.dsp.exec_cmd("sleep 0.1 && swayosd-client --caps-lock"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true })

hl.bind("Print",                       hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh"), { locked = true })
hl.bind("SHIFT + Print",               hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh --edit"), { locked = true })
hl.bind(mainMod .. " + Print",         hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh --full"), { locked = true })
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh --full --edit"), { locked = true })

hl.bind("XF86PowerOff", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/lock.sh"), { locked = true })
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/lock.sh"), { locked = true, repeating = true })

-- ───────── Media & Audio ─────────
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioMute",    hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true, repeating = true })

-- ───────── Applications & Launchers ─────────
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu)) -- opens rofi
-- -- ───────── Quickshell Controls ─────────
-- hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/qs_manager.sh toggle monitors"))
-- hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/reload.sh"))
-- hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("~/.config/hypr/scripts/qs_manager.sh toggle applauncher"))
-- hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("~/.config/hypr/scripts/qs_manager.sh toggle clipboard"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/qs_manager.sh toggle settings"))
-- hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/qs_manager.sh toggle music"))
-- hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/qs_manager.sh toggle battery"))
-- hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/qs_manager.sh toggle wallpaper"))
-- hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/qs_manager.sh toggle calendar"))
-- hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/qs_manager.sh toggle network"))
-- hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/qs_manager.sh toggle focustime"))
-- hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/qs_manager.sh toggle volume"))
-- hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/qs_manager.sh toggle guide"))

-- ───────── Workspaces ─────────
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,          hl.dsp.exec_cmd("~/.config/hypr/scripts/qs_manager.sh " .. i))
    hl.bind(mainMod .. " + SHIFT + " .. key,  hl.dsp.exec_cmd("~/.config/hypr/scripts/qs_manager.sh " .. i .. " move"))
end