//@ pragma UseQApplication
//@ pragma ShellId yunyun-syndrome
//@ pragma IconTheme candy-icons
//@ pragma DataDir $BASE/yunyun-syndrome/quickshell
//@ pragma StateDir $BASE/yunyun-syndrome/quickshell
//@ pragma CacheDir $BASE/yunyun-syndrome/quickshell

// YunYun Syndrome shell for Hyprland: panel, launcher, calendar, notifications,
// wallpaper and lock screen, drawn with the frames of the KDE Plasma theme.

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.bar
import qs.modules.calendar
import qs.modules.desktop
import qs.modules.launcher
import qs.modules.lock
import qs.modules.notifications
import qs.services

ShellRoot {
    Variants {
        model: Quickshell.screens

        Scope {
            id: perScreen

            required property ShellScreen modelData

            Desktop {
                screen: perScreen.modelData
            }

            Bar {
                screen: perScreen.modelData
            }

            Launcher {
                screen: perScreen.modelData
            }

            Calendar {
                screen: perScreen.modelData
            }

            WallpaperPicker {
                screen: perScreen.modelData
            }
        }
    }

    NotificationPopups {}

    Lock {}

    // Used by the Hyprland keybinds: qs -p <shell> ipc call shell <function>
    IpcHandler {
        target: "shell"

        function toggleLauncher(): void {
            ShellState.toggle("launcher", "");
        }

        function toggleCalendar(): void {
            ShellState.toggle("calendar", "");
        }

        function toggleWallpaperPicker(): void {
            ShellState.toggle("wallpapers", "");
        }

        function lock(): void {
            ShellState.close();
            ShellState.locked = true;
        }

        function setWallpaper(path: string): void {
            Settings.wallpaper = path;
        }
    }
}
