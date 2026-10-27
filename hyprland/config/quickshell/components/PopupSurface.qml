import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Transparent full-screen layer (below the panel) hosting one popup.
// Clicking outside the popup or pressing Escape closes it.
PanelWindow {
    id: root

    required property string popupName
    default property alias content: holder.data

    visible: ShellState.isOpen(popupName, screen)
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "yunyun-" + popupName

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.close()
    }

    FocusScope {
        id: holder

        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: ShellState.close()
    }
}
