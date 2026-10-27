pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

// Which popup is open, and on which screen. Only one popup is open at a time.
Singleton {
    id: root

    // "launcher", "calendar", "wallpapers" or ""
    property string popup: ""
    property string popupScreen: ""
    property bool locked: false

    function focusedScreen() {
        return Hyprland.focusedMonitor?.name ?? Quickshell.screens[0]?.name ?? "";
    }

    function screenByName(name) {
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++) {
            if (screens[i].name === name)
                return screens[i];
        }
        return screens[0] ?? null;
    }

    function isOpen(name, screen) {
        return popup === name && popupScreen === screen.name;
    }

    function toggle(name, screenName) {
        const target = screenName || focusedScreen();
        if (popup === name && popupScreen === target) {
            close();
        } else {
            popup = name;
            popupScreen = target;
        }
    }

    function close() {
        popup = "";
    }
}
