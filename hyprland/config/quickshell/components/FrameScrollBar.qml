import QtQuick
import QtQuick.Controls.Basic as Controls

// Vertical scrollbar drawn with the theme's scrollbar frames
Controls.ScrollBar {
    id: root

    implicitWidth: 12
    padding: 1
    policy: size < 1 ? Controls.ScrollBar.AlwaysOn : Controls.ScrollBar.AlwaysOff

    background: Frame {
        kind: "scrollbar-groove"
    }

    contentItem: Frame {
        implicitWidth: 10
        implicitHeight: 24
        kind: root.pressed || root.hovered ? "scrollbar-slider-hover" : "scrollbar-slider"
    }
}
