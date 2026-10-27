-- Your settings for the YunYun Syndrome session. install.sh keeps this file on reinstall.
-- Monitor wiki: https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

hl.config({
    input = {
        kb_layout = "@KB_LAYOUT@",
        kb_variant = "@KB_VARIANT@",
        follow_mouse = 1,
        sensitivity = 0,
    },
})
