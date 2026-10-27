-- Keybinds. Workspace digits are bound by keycode so they work on any keyboard layout.

local mod = "SUPER"

local function digit(d)
    return "code:" .. (d == 0 and 19 or (9 + d))
end

local function shell(call)
    return hl.dsp.exec_cmd(YY_IPC .. call)
end

-- Shell
hl.bind(mod .. " + SUPER_L", shell("toggleLauncher"), { release = true, desc = "Open the launcher" })
hl.bind(mod .. " + Space", shell("toggleLauncher"), { desc = "Open the launcher" })
hl.bind(mod .. " + C", shell("toggleCalendar"), { desc = "Show the calendar" })
hl.bind(mod .. " + SHIFT + W", shell("toggleWallpaperPicker"), { desc = "Pick a wallpaper" })
hl.bind(mod .. " + L", shell("lock"), { desc = "Lock the screen" })
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd(YY_SHELL .. " kill; " .. YY_SHELL .. " -d"), { desc = "Restart the shell" })

-- Apps
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(TERMINAL))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(FILE_MANAGER))
hl.bind("Print", hl.dsp.exec_cmd(SCREENSHOT .. " region"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(SCREENSHOT .. " screen"))

-- Windows
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + M", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + N", hl.dsp.workspace.toggle_special("minimized"), { desc = "Show minimized windows" })
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())

for _, dir in ipairs({ "Left", "Right", "Up", "Down" }) do
    local d = string.lower(dir)
    hl.bind(mod .. " + " .. dir, hl.dsp.focus({ direction = d }))
    hl.bind(mod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = string.sub(d, 1, 1) }))
end

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize())

-- Workspaces
for i = 1, 10 do
    local key = digit(i % 10)
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
end

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special())
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special" }))

-- Hardware keys
local sink = "@DEFAULT_AUDIO_SINK@"
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 " .. sink .. " 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume " .. sink .. " 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute " .. sink .. " toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
