import QtQuick
import Quickshell
import qs.components
import qs.services
import qs.theme

// Big clock on the right of the panel; opens the calendar
FrameButton {
    id: root

    required property ShellScreen screen

    width: label.implicitWidth + 12
    height: 36
    checked: ShellState.isOpen("calendar", screen)
    onClicked: ShellState.toggle("calendar", screen.name)

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    StyledText {
        id: label

        anchors.centerIn: parent
        text: Qt.formatTime(clock.date, Settings.clock24h ? "HH:mm" : "h:mm AP")
        font.pixelSize: 28
        font.weight: Font.Medium
    }
}
