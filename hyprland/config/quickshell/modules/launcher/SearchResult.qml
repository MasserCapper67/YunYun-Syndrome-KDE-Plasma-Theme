import QtQuick
import qs.components
import qs.theme

// Row in the search results, like KRunner: section label on the left, icon + name
MouseArea {
    id: root

    required property var entry
    property bool current: false
    property bool showSection: false
    readonly property bool hovered: containsMouse

    signal activated

    height: 34
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: activated()

    StyledText {
        id: section

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 180
        horizontalAlignment: Text.AlignRight
        text: root.showSection ? "Applications" : ""
        color: Theme.textDim
        font.pixelSize: 15
    }

    Frame {
        anchors.left: section.right
        anchors.leftMargin: 4
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        kind: root.current ? "viewitem-hover" : ""
        visible: kind !== ""
    }

    ThemedIcon {
        id: icon

        anchors.left: section.right
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        implicitSize: 22
        name: root.entry.icon
    }

    StyledText {
        anchors.left: icon.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.entry.name + (root.entry.genericName && root.entry.genericName !== root.entry.name ? "  ·  " + root.entry.genericName : "")
        color: root.current ? Theme.textBright : Theme.text
        font.pixelSize: 15
    }
}
