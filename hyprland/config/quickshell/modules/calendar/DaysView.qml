import QtQuick
import qs.components
import qs.theme

// Month grid: weekday header + 6 weeks, today framed
Column {
    id: root

    property int year
    property int month
    property date today
    property int firstDay: 1 // 0 = Sunday

    readonly property date gridStart: {
        const first = new Date(year, month, 1);
        const offset = (first.getDay() - firstDay + 7) % 7;
        return new Date(year, month, 1 - offset);
    }
    readonly property real cellWidth: width / 7
    readonly property real cellHeight: (height - header.height) / 6

    Row {
        id: header

        height: 44

        Repeater {
            model: 7

            StyledText {
                required property int index

                width: root.cellWidth
                height: header.height
                horizontalAlignment: Text.AlignHCenter
                text: Theme.capitalize(Qt.locale().dayName((root.firstDay + index) % 7, Locale.ShortFormat))
                font.pixelSize: 16
            }
        }
    }

    Grid {
        columns: 7

        Repeater {
            model: 42

            Item {
                id: day

                required property int index
                readonly property date date: new Date(root.gridStart.getFullYear(), root.gridStart.getMonth(), root.gridStart.getDate() + index)
                readonly property bool inMonth: date.getMonth() === root.month
                readonly property bool isToday: date.toDateString() === root.today.toDateString()

                width: root.cellWidth
                height: root.cellHeight

                Frame {
                    anchors.fill: parent
                    anchors.margins: 1
                    kind: day.isToday ? "viewitem-hover" : hover.containsMouse ? "viewitem-selected" : ""
                    visible: kind !== ""
                }

                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                }

                StyledText {
                    anchors.centerIn: parent
                    text: day.date.getDate()
                    color: day.inMonth ? Theme.text : Theme.textOff
                    font.pixelSize: 17
                }
            }
        }
    }
}
