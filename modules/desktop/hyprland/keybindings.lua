---------------------
---- KEYBINDINGS ----
---------------------
require("var") -- Load variables from a separate file (mainMod, terminal, etc.)

local ipc = "noctalia msg "

-- Core binds
hl.bind(mainMod .. "+r", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mainMod .. "+S", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mainMod .. "+comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher"))
hl.bind("PRINT", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(ipc .. "screenshot-region"))

-- ───────── Window Management ─────────
-- NOTE: "drag windows".
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. "+ C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))

-- Media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"))

-- Noctalia Settings
hl.window_rule({
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    size = { 1080, 920 },
})

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))


-- ───────── Applications & Launchers ─────────
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))


-- ───────── Media & Audio ─────────
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioMute",    hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true, repeating = true })

for i = 1, 10 do
local key = i % 10 -- 10 maps to key 0
hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

