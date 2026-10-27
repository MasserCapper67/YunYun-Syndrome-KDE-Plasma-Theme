import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.services
import qs.theme

// Top panel, laid out like the KDE one: launcher + visualizer on the left,
// a two-row window list in the middle, tray + clock on the right.
PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight + Theme.barLine
    color: "transparent"
    WlrLayershell.namespace: "yunyun-bar"

    Frame {
        anchors.fill: parent
        anchors.bottomMargin: Theme.barLine
        kind: "panel"
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Theme.barLine
        color: Theme.magenta
    }

    FrameButton {
        id: launcherButton

        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -Theme.barLine / 2
        width: 36
        height: 36
        checked: ShellState.isOpen("launcher", bar.screen)
        onClicked: ShellState.toggle("launcher", bar.screen.name)

        Image {
            anchors.centerIn: parent
            width: 30
            height: 30
            sourceSize: Qt.size(60, 60)
            source: Theme.asset("icons/start.svg")
        }
    }

    Visualizer {
        anchors.left: launcherButton.right
        anchors.leftMargin: 14
        anchors.top: parent.top
        anchors.topMargin: 3
        width: Math.min(220, taskList.x - launcherButton.x - launcherButton.width - 34)
        height: Theme.barHeight - 8
    }

    TaskList {
        id: taskList

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 2
        height: Theme.barHeight - 4
        maxWidth: bar.width - 2 * 340
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -Theme.barLine / 2
        spacing: 12

        Tray {
            anchors.verticalCenter: parent.verticalCenter
            barWindow: bar
        }

        Clock {
            anchors.verticalCenter: parent.verticalCenter
            screen: bar.screen
        }
    }
}
