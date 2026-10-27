-- Paths and default apps shared by the other modules

YY_HOME   = os.getenv("HOME")
YY_CONFIG = os.getenv("YUNYUN_CONFIG_DIR") or (YY_HOME .. "/.config/yunyun-syndrome")

-- Quickshell runs straight from the theme folder, so ~/.config/quickshell is left alone
YY_SHELL = "qs -p '" .. YY_CONFIG .. "/quickshell'"
YY_IPC   = YY_SHELL .. " ipc call shell "

TERMINAL     = "kitty"
FILE_MANAGER = "xdg-open ~"
SCREENSHOT   = YY_CONFIG .. "/bin/yunyun-screenshot"

-- Written by install.sh: where hyprpm built the hyprbars plugin
pcall(require, "generated")
