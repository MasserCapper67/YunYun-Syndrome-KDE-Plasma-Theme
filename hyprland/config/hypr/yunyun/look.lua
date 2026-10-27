-- Look and feel: square pixel-art frames like the Aurorae decoration

hl.config({
    general = {
        gaps_in = 6,
        -- Leave room for the desktop decorations (checker strips, side icons, bottom bars)
        gaps_out = { top = 30, right = 62, bottom = 44, left = 62 },
        border_size = 2,
        resize_on_border = true,
        extend_border_grab_area = 10,
        layout = "dwindle",
        col = {
            active_border = { colors = { YY_COL.magenta, YY_COL.blue }, angle = 45 },
            inactive_border = YY_COL.titlebar,
        },
    },
    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = { enabled = false },
        -- Only visible behind translucent windows such as kitty
        blur = { enabled = true, size = 4, passes = 2 },
    },
    group = {
        col = {
            border_active = YY_COL.pink,
            border_inactive = YY_COL.titlebar,
        },
        groupbar = {
            font_family = "Fira Sans SemiBold",
            text_color = YY_COL.white,
            col = {
                active = YY_COL.magenta,
                inactive = YY_COL.titlebar,
            },
        },
    },
    dwindle = {
        preserve_split = true,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        background_color = YY_COL.night,
        font_family = "Fira Sans",
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
})
