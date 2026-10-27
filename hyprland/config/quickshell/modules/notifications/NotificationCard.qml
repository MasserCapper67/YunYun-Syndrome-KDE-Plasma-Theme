import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.components
import qs.theme

// One notification, in a dialog frame. Click to run the default action (or dismiss).
Frame {
    id: root

    required property Notification notification
    readonly property var defaultAction: notification.actions.find(a => a.identifier === "default") ?? null
    readonly property var buttons: notification.actions.filter(a => a.identifier !== "default")

    kind: "dialog"
    height: content.implicitHeight + padTop + padBottom + 16

    Timer {
        running: root.notification.urgency !== NotificationUrgency.Critical && !area.containsMouse
        interval: root.notification.expireTimeout > 0 ? root.notification.expireTimeout : 6000
        onTriggered: root.notification.expire()
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton && root.defaultAction)
                root.defaultAction.invoke();
            else
                root.notification.dismiss();
        }
    }

    Column {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: root.padLeft + 10
        anchors.rightMargin: root.padRight + 10
        anchors.topMargin: root.padTop + 8
        spacing: 6

        // Header: app icon, app name, close
        Item {
            width: parent.width
            height: 18

            ThemedIcon {
                id: appIcon

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                implicitSize: 16
                name: root.notification.appIcon || root.notification.desktopEntry
                fallback: "dialog-information"
            }

            StyledText {
                anchors.left: appIcon.right
                anchors.leftMargin: 6
                anchors.right: close.left
                anchors.verticalCenter: parent.verticalCenter
                text: (root.notification.appName || "Notification").toUpperCase()
                color: Theme.text
                font.pixelSize: 11
                font.letterSpacing: 1
            }

            FrameButton {
                id: close

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                height: 18
                onClicked: root.notification.dismiss()

                StyledText {
                    anchors.centerIn: parent
                    text: "×"
                    color: Theme.pink
                    font.pixelSize: 16
                }
            }
        }

        Row {
            width: parent.width
            spacing: 10

            Image {
                id: image

                visible: root.notification.image !== ""
                width: visible ? 48 : 0
                height: 48
                source: root.notification.image
                sourceSize: Qt.size(96, 96)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Column {
                width: parent.width - (image.visible ? image.width + parent.spacing : 0)
                spacing: 4

                StyledText {
                    width: parent.width
                    text: root.notification.summary
                    color: Theme.textBright
                    font.pixelSize: 15
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                }

                StyledText {
                    width: parent.width
                    visible: text !== ""
                    text: root.notification.body
                    textFormat: Text.StyledText
                    color: Theme.text
                    font.pixelSize: 13
                    wrapMode: Text.Wrap
                    maximumLineCount: 5
                    onLinkActivated: link => Qt.openUrlExternally(link)
                }
            }
        }

        Row {
            visible: root.buttons.length > 0
            spacing: 6

            Repeater {
                model: root.buttons

                FrameButton {
                    id: actionButton

                    required property var modelData

                    width: actionLabel.implicitWidth + 20
                    height: 28
                    normalFrame: "button-normal"
                    hoverFrame: "button-hover"
                    pressedFrame: "button-pressed"
                    onClicked: modelData.invoke()

                    StyledText {
                        id: actionLabel

                        anchors.centerIn: parent
                        text: actionButton.modelData.text
                        color: Theme.textBright
                        font.pixelSize: 13
                    }
                }
            }
        }
    }
}
