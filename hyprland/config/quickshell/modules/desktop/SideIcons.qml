import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.theme

// The three pastel icons on each side of the screen
Column {
    id: root

    spacing: 9

    Repeater {
        model: [
            { icon: "desktop-image", action: "wallpaper" },
            { icon: "desktop-fullscreen", action: "fullscreen" },
            { icon: "desktop-download", action: "downloads" },
        ]

        MouseArea {
            id: button

            required property var modelData

            width: 28
            height: 28
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                switch (modelData.action) {
                case "wallpaper":
                    ShellState.toggle("wallpapers");
                    break;
                case "fullscreen": {
                    const window = ToplevelManager.activeToplevel;
                    if (window)
                        window.fullscreen = !window.fullscreen;
                    break;
                }
                case "downloads":
                    Quickshell.execDetached(["sh", "-c", "xdg-open \"$(xdg-user-dir DOWNLOAD 2>/dev/null || echo \"$HOME/Downloads\")\""]);
                    break;
                }
            }

            Image {
                anchors.fill: parent
                source: Theme.asset("icons/" + button.modelData.icon + ".svg")
                sourceSize: Qt.size(56, 56)
                opacity: button.pressed ? 0.7 : 1
                scale: button.containsMouse ? 1.08 : 1
            }
        }
    }
}
