import QtQuick
import Quickshell
import qs.components
import qs.services
import qs.theme

// Launcher footer: Sleep / Restart / Shut Down / Session. Destructive actions need a second click.
Item {
    id: root

    property string armed: ""

    function run(action) {
        switch (action) {
        case "sleep":
            ShellState.close();
            Quickshell.execDetached(["systemctl", "suspend"]);
            break;
        case "restart":
            Quickshell.execDetached(["systemctl", "reboot"]);
            break;
        case "shutdown":
            Quickshell.execDetached(["systemctl", "poweroff"]);
            break;
        case "lock":
            ShellState.close();
            ShellState.locked = true;
            break;
        case "logout":
            Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.exit()"]);
            break;
        }
    }

    function press(action, confirm) {
        if (!confirm || armed === action) {
            armed = "";
            run(action);
        } else {
            armed = action;
            disarm.restart();
        }
    }

    Timer {
        id: disarm
        interval: 3000
        onTriggered: root.armed = ""
    }

    Frame {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 8
        kind: "heading-footer"
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        ThemedIcon {
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 20
            name: "view-app-grid"
            fallback: "view-grid"
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: root.armed ? "Click again to confirm" : "Applications"
            color: root.armed ? Theme.pink : Theme.text
            font.pixelSize: 16
        }
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: [
                { id: "sleep", label: "Sleep", icon: "system-suspend", confirm: false },
                { id: "restart", label: "Restart", icon: "system-reboot", confirm: true },
                { id: "shutdown", label: "Shut Down", icon: "system-shutdown", confirm: true },
            ]

            FrameButton {
                id: powerButton

                required property var modelData

                width: powerRow.implicitWidth + 14
                height: 34
                checked: root.armed === modelData.id
                onClicked: root.press(modelData.id, modelData.confirm)

                Row {
                    id: powerRow

                    anchors.centerIn: parent
                    spacing: 6

                    ThemedIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        implicitSize: 20
                        name: powerButton.modelData.icon
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: powerButton.modelData.label
                        font.pixelSize: 16
                    }
                }
            }
        }

        FrameButton {
            id: sessionButton

            width: sessionRow.implicitWidth + 14
            height: 34
            checked: sessionMenu.visible
            onClicked: sessionMenu.visible = !sessionMenu.visible

            Row {
                id: sessionRow

                anchors.centerIn: parent
                spacing: 6

                ThemedIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitSize: 20
                    name: "system-log-out"
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Session ▾"
                    font.pixelSize: 16
                }
            }
        }
    }

    // Small menu that opens above the Session button
    Frame {
        id: sessionMenu

        anchors.right: parent.right
        anchors.bottom: parent.top
        anchors.bottomMargin: 2
        width: 170
        height: sessionColumn.implicitHeight + padTop + padBottom
        kind: "dialog"
        visible: false

        Column {
            id: sessionColumn

            anchors.fill: parent
            anchors.leftMargin: sessionMenu.padLeft
            anchors.rightMargin: sessionMenu.padRight
            anchors.topMargin: sessionMenu.padTop

            Repeater {
                model: [
                    { id: "lock", label: "Lock", icon: "system-lock-screen", confirm: false },
                    { id: "logout", label: "Log Out", icon: "system-log-out", confirm: true },
                ]

                FrameButton {
                    id: sessionItem

                    required property var modelData

                    width: sessionColumn.width
                    height: 32
                    hoverFrame: "viewitem-hover"
                    checked: root.armed === modelData.id
                    pressedFrame: "viewitem-selected"
                    onClicked: root.press(modelData.id, modelData.confirm)

                    ThemedIcon {
                        id: sessionIcon

                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        implicitSize: 18
                        name: sessionItem.modelData.icon
                    }

                    StyledText {
                        anchors.left: sessionIcon.right
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: sessionItem.modelData.label
                    }
                }
            }
        }
    }
}
