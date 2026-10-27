import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.modules.desktop
import qs.services
import qs.theme

// What each screen shows while locked: dimmed wallpaper, big clock, password box
Item {
    id: root

    required property var lock

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Wallpaper {
        anchors.fill: parent
        path: Settings.wallpaper
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.night
        opacity: 0.55
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -40
        spacing: 6

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(clock.date, Settings.clock24h ? "HH:mm" : "h:mm AP")
            color: Theme.text
            font.pixelSize: 110
            font.weight: Font.Medium
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Theme.capitalize(Qt.locale().toString(clock.date, "dddd, d MMMM"))
            color: Theme.textBright
            font.pixelSize: 20
        }

        Item {
            width: 1
            height: 30
        }

        Frame {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 380
            height: 150
            kind: "dialog"

            ClippingRectangle {
                id: avatar

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 16
                width: 44
                height: 44
                radius: 22
                color: Theme.panel

                Image {
                    anchors.fill: parent
                    source: "file://" + Quickshell.env("HOME") + "/.face"
                    sourceSize: Qt.size(88, 88)
                    fillMode: Image.PreserveAspectCrop
                    onStatusChanged: if (status === Image.Error) source = Theme.asset("icons/start.svg")
                }
            }

            Frame {
                id: field

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: avatar.bottom
                anchors.topMargin: 14
                width: 300
                height: 34
                kind: "lineedit"

                TextInput {
                    id: input

                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "●"
                    color: Theme.textBright
                    font.family: Theme.font
                    font.pixelSize: 16
                    focus: true
                    enabled: !root.lock.busy
                    text: root.lock.password
                    onTextChanged: root.lock.password = text
                    onAccepted: root.lock.tryUnlock()
                    Component.onCompleted: forceActiveFocus()

                    StyledText {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        visible: input.text === ""
                        text: root.lock.failed ? "Wrong password" : root.lock.busy ? "Checking…" : "Password"
                        color: root.lock.failed ? Theme.pink : Theme.textDim
                        font.pixelSize: 15
                    }
                }
            }

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: field.bottom
                anchors.topMargin: 10
                text: Quickshell.env("USER")
                color: Theme.text
                font.pixelSize: 13
            }
        }
    }
}
