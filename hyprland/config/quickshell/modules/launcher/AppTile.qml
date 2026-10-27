import QtQuick
import qs.components
import qs.theme

// App in the launcher grid. Right click toggles it as a favorite.
MouseArea {
    id: root

    required property var entry
    property bool current: false
    property bool favorite: false
    readonly property bool hovered: containsMouse

    signal activated
    signal toggleFavorite

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onClicked: mouse => mouse.button === Qt.RightButton ? toggleFavorite() : activated()

    Frame {
        anchors.fill: parent
        anchors.margins: 3
        kind: root.pressed ? "viewitem-selected" : root.current ? "viewitem-selected-hover" : ""
        visible: kind !== ""
    }

    ThemedIcon {
        id: icon

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 14
        implicitSize: 48
        name: root.entry.icon
    }

    ThemedIcon {
        anchors.right: icon.right
        anchors.bottom: icon.bottom
        anchors.margins: -4
        implicitSize: 14
        name: "starred"
        fallback: "emblem-favorite"
        visible: root.favorite && root.hovered
    }

    StyledText {
        anchors.top: icon.bottom
        anchors.topMargin: 6
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 6
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.Wrap
        maximumLineCount: 2
        text: root.entry.name
        color: root.current ? Theme.textBright : Theme.text
        font.pixelSize: 14
    }
}
