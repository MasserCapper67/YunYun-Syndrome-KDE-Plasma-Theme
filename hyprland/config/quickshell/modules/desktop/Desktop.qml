import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.theme

// Wallpaper plus the decorations around the screen edges seen in the KDE screenshots:
// checkered strips in the corners, purple/pink bars along the bottom and the side icons.
PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: Theme.night
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "yunyun-desktop"

    Wallpaper {
        anchors.fill: parent
        path: Settings.wallpaper
    }

    Item {
        anchors.fill: parent
        visible: Settings.desktopDecorations

        readonly property int stripY: Theme.barHeight + Theme.barLine + 10

        Checker {
            x: 0
            y: parent.stripY
        }

        Checker {
            x: parent.width - width
            y: parent.stripY
            mirrored: true
        }

        Checker {
            x: 0
            y: parent.height - height - 24
        }

        Checker {
            x: parent.width - width
            y: parent.height - height - 24
            mirrored: true
        }

        CornerBars {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

        SideIcons {
            x: 17
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 15
        }

        SideIcons {
            x: parent.width - width - 17
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 15
        }
    }
}
