import QtQuick
import qs.theme

// Flat tool button: nothing until hovered, then the theme's toolbutton frame.
// Set "checked" to keep the pressed look (e.g. while its popup is open).
MouseArea {
    id: root

    property bool checked: false
    property string normalFrame: ""
    property string hoverFrame: "toolbutton-hover"
    property string pressedFrame: "toolbutton-pressed"
    default property alias content: contentItem.data

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    Frame {
        anchors.fill: parent
        kind: root.pressed || root.checked ? root.pressedFrame : root.containsMouse ? root.hoverFrame : root.normalFrame
        visible: kind !== ""
    }

    Item {
        id: contentItem
        anchors.fill: parent
    }
}
