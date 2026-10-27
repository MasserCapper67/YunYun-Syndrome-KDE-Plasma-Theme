-- YunYun Syndrome!? Rhythm Psychosis - Hyprland session
--
-- Hyprland adaptation of the "YunYun Syndrome" KDE Plasma theme by Miyuki Denpa.
-- This config is only used by the "Hyprland (YunYun Syndrome)" login session,
-- your regular ~/.config/hypr config is never read or modified.

require("yunyun.variables")
require("yunyun.colors")
require("yunyun.look")
require("yunyun.animations")
require("yunyun.hyprbars")
require("yunyun.binds")
require("yunyun.rules")
require("yunyun.autostart")

-- Monitors, keyboard layout and your own tweaks. Loaded last so it wins.
require("user")
