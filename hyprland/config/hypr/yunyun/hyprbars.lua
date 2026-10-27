-- Titlebars in the style of the Aurorae decoration (title on the left, buttons on the right).
-- hyprbars is built by hyprpm during install; the path lands in generated.lua.
-- If the plugin is missing or out of date the session still works, just without titlebars.

local function exists(path)
    local f = path and io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

if not exists(YY_HYPRBARS_SO) then
    return
end

local loaded = pcall(hl.plugin.load, YY_HYPRBARS_SO)
if not loaded or not hl.plugin.hyprbars then
    hl.on("hyprland.start", function()
        hl.exec_cmd("notify-send -a 'YunYun Syndrome' 'Titlebars unavailable' 'Run: hyprpm update'")
    end)
    return
end

hl.config({
    plugin = {
        hyprbars = {
            bar_height = 30,
            bar_color = YY_COL.titlebar,
            col = { text = YY_COL.white },
            bar_text_font = "Fira Sans SemiBold",
            bar_text_size = 10,
            bar_text_align = "left",
            bar_padding = 12,
            bar_button_padding = 6,
            bar_part_of_window = true,
            bar_precedence_over_border = false,
            inactive_button_color = YY_COL.titlebar,
            on_double_click = "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = 1 })'",
        },
    },
})

-- Buttons are listed right to left: close, maximize, minimize
local buttons = {
    { icon = "▲", action = "hyprctl dispatch 'hl.dsp.window.close()'" },
    { icon = "■", action = "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = 1 })'" },
    -- Hyprland has no minimize, so park the window on a special workspace (Super+N brings it back)
    { icon = "▬", action = "hyprctl dispatch 'hl.dsp.window.move({ workspace = \"special:minimized\", follow = false })'" },
}

for _, b in ipairs(buttons) do
    hl.plugin.hyprbars.add_button({
        bg_color = YY_COL.titlebar,
        fg_color = YY_COL.lavender,
        size = 16,
        icon = b.icon,
        action = b.action,
    })
end
