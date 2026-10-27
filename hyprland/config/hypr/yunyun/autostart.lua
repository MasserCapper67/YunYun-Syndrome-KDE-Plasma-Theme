-- Started with the session

hl.on("hyprland.start", function()
    -- Only the variables portals need: the YunYun theming variables (GTK_THEME, DCONF_PROFILE, ...)
    -- must not leak into the systemd/D-Bus environment shared with your other sessions.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd(YY_SHELL .. " -d")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)
