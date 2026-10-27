import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.theme

// One window in the task list. Left click focuses, middle click closes.
MouseArea {
    id: root

    required property Toplevel toplevel
    readonly property var entry: DesktopEntries.heuristicLookup(toplevel.appId)

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton)
            toplevel.close();
        else
            toplevel.activate();
    }

    Frame {
        anchors.fill: parent
        kind: root.toplevel.activated ? "task-focus" : root.containsMouse ? "task-hover" : "task-normal"
    }

    ThemedIcon {
        id: icon

        anchors.left: parent.left
        anchors.leftMargin: 7
        anchors.verticalCenter: parent.verticalCenter
        implicitSize: Math.min(16, root.height - 4)
        name: root.entry?.icon ?? root.toplevel.appId
    }

    StyledText {
        anchors.left: icon.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        text: root.toplevel.title || root.entry?.name || root.toplevel.appId
        color: root.toplevel.activated ? Theme.textBright : Theme.lavender
        font.pixelSize: 12
    }
}
