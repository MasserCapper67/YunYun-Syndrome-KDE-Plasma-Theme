import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.theme

// Window list in two rows, filled column by column like the Plasma task manager.
// Like Plasma's default, every screen lists all windows.
Item {
    id: root

    property int maxWidth: 600
    readonly property int rows: 2
    readonly property int rowSpacing: 4
    readonly property int maxButtonWidth: 306
    readonly property var windows: ToplevelManager.toplevels.values
    readonly property int columns: Math.max(1, Math.ceil(windows.length / rows))
    readonly property int buttonWidth: Math.min(maxButtonWidth, Math.floor((maxWidth - (columns - 1) * 4) / columns))

    width: columns * buttonWidth + (columns - 1) * 4

    Grid {
        anchors.fill: parent
        flow: Grid.TopToBottom
        rows: root.rows
        rowSpacing: root.rowSpacing
        columnSpacing: 4

        Repeater {
            model: root.windows

            TaskButton {
                required property Toplevel modelData

                toplevel: modelData
                width: root.buttonWidth
                height: Math.floor((root.height - root.rowSpacing) / root.rows)
            }
        }
    }
}
