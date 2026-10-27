-- Window and layer rules

-- Dialogs and small utility windows float
local floating = {
    { title = "^(Open|Save As|Open File|Choose Files|Authentication Required|File Operation Progress)(.*)$" },
    { class = "^(xdg-desktop-portal-gtk|org\\.freedesktop\\.impl\\.portal\\..*)$" },
    { class = "^(org\\.pulseaudio\\.pavucontrol|blueman-manager|nm-connection-editor|qt6ct|nwg-look)$" },
    { class = "^(hyprland-share-picker|hyprpolkitagent)$" },
}
for _, m in ipairs(floating) do
    hl.window_rule({ match = m, float = true })
end

hl.window_rule({
    name = "picture-in-picture",
    match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
})

-- Apps asking to be maximized would cover the desktop decorations
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- The shell draws its own pixel-art frames: no blur or slide-in on its surfaces
hl.layer_rule({
    name = "yunyun-shell",
    match = { namespace = "^yunyun-(bar|desktop|launcher|calendar|wallpapers|notifications)$" },
    no_anim = true,
})
