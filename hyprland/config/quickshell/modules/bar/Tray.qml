import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.components

// System tray (not in the KDE screenshots, but apps like Discord or Steam need one)
Row {
    id: root

    required property var barWindow

    spacing: 4

    Repeater {
        model: SystemTray.items

        FrameButton {
            id: button

            required property SystemTrayItem modelData

            width: 26
            height: 26
            onClicked: mouse => {
                const item = modelData;
                if (mouse.button === Qt.LeftButton && !item.onlyMenu) {
                    item.activate();
                } else if (mouse.button === Qt.MiddleButton) {
                    item.secondaryActivate();
                } else if (item.hasMenu) {
                    const pos = button.mapToItem(null, 0, button.height);
                    item.display(root.barWindow, pos.x, pos.y + 4);
                }
            }
            onWheel: wheel => modelData.scroll(wheel.angleDelta.y / 120, false)

            ThemedIcon {
                anchors.centerIn: parent
                implicitSize: 18
                name: button.modelData.icon
            }
        }
    }
}
