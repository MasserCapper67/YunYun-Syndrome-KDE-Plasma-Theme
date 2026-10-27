import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Stack of notification popups in the top right corner of the focused screen
PanelWindow {
    id: root

    screen: ShellState.screenByName(ShellState.focusedScreen())
    // Both live in the top right corner: wait until the calendar is closed
    visible: Notifications.list.length > 0 && ShellState.popup !== "calendar"
    anchors {
        top: true
        right: true
    }
    margins {
        top: 10
        right: 10
    }
    implicitWidth: 380
    implicitHeight: Math.max(1, column.implicitHeight)
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "yunyun-notifications"

    Column {
        id: column

        width: root.implicitWidth
        spacing: 8

        Repeater {
            // Newest on top, at most five at once
            model: Notifications.list.slice(-5).reverse()

            NotificationCard {
                required property var modelData

                width: column.width
                notification: modelData
            }
        }
    }
}
