import QtQuick
import Quickshell
import qs.components
import qs.services
import qs.theme

// Calendar under the clock, with the Days / Months / Years tabs of the KDE one
PopupSurface {
    id: root

    popupName: "calendar"

    property string view: "days"
    property int year: today.getFullYear()
    property int month: today.getMonth()
    readonly property date today: clock.date
    readonly property int firstDay: Qt.locale().firstDayOfWeek % 7 // 0 = Sunday

    function shift(delta) {
        if (view === "days") {
            const d = new Date(year, month + delta, 1);
            year = d.getFullYear();
            month = d.getMonth();
        } else if (view === "months") {
            year += delta;
        } else {
            year += 12 * delta;
        }
    }

    function goToday() {
        year = today.getFullYear();
        month = today.getMonth();
        view = "days";
    }

    onVisibleChanged: if (visible) goToday()

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Frame {
        id: panel

        anchors.right: parent.right
        width: 574
        height: 503
        kind: "dialog"

        MouseArea {
            anchors.fill: parent
            onWheel: wheel => root.shift(wheel.angleDelta.y > 0 ? -1 : 1)
        }

        StyledText {
            id: title

            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.top: parent.top
            anchors.topMargin: 12
            text: root.view === "days" ? Theme.capitalize(Qt.locale().standaloneMonthName(root.month)) + (root.year !== root.today.getFullYear() ? " " + root.year : "")
                : root.view === "months" ? root.year
                : (root.year - root.year % 12) + " – " + (root.year - root.year % 12 + 11)
            font.pixelSize: 16
        }

        // Tabs + navigation
        Item {
            id: tabs

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: title.bottom
            anchors.topMargin: 10
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            height: 38

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    model: [
                        { id: "days", label: "Days" },
                        { id: "months", label: "Months" },
                        { id: "years", label: "Years" },
                    ]

                    FrameButton {
                        id: tab

                        required property var modelData

                        width: 144
                        height: 36
                        checked: root.view === modelData.id
                        hoverFrame: ""
                        pressedFrame: "tab-active"
                        onClicked: root.view = modelData.id

                        StyledText {
                            anchors.centerIn: parent
                            text: tab.modelData.label
                            font.pixelSize: 16
                        }
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                FrameButton {
                    width: 28
                    height: 30
                    onClicked: root.shift(-1)

                    StyledText {
                        anchors.centerIn: parent
                        text: "‹"
                        font.pixelSize: 22
                    }
                }

                FrameButton {
                    width: todayLabel.implicitWidth + 14
                    height: 30
                    onClicked: root.goToday()

                    StyledText {
                        id: todayLabel

                        anchors.centerIn: parent
                        text: "Today"
                        font.pixelSize: 16
                    }
                }

                FrameButton {
                    width: 28
                    height: 30
                    onClicked: root.shift(1)

                    StyledText {
                        anchors.centerIn: parent
                        text: "›"
                        font.pixelSize: 22
                    }
                }
            }
        }

        Rectangle {
            id: divider

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: tabs.bottom
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            height: 2
            color: Theme.magenta
        }

        Item {
            id: body

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: divider.bottom
            anchors.bottom: parent.bottom
            anchors.margins: 8

            DaysView {
                anchors.fill: parent
                visible: root.view === "days"
                year: root.year
                month: root.month
                today: root.today
                firstDay: root.firstDay
            }

            Grid {
                anchors.fill: parent
                anchors.topMargin: 20
                visible: root.view !== "days"
                columns: 3

                Repeater {
                    model: 12

                    FrameButton {
                        id: cell

                        required property int index
                        readonly property int value: root.view === "months" ? index : root.year - root.year % 12 + index
                        readonly property bool isCurrent: root.view === "months"
                            ? root.year === root.today.getFullYear() && index === root.today.getMonth()
                            : value === root.today.getFullYear()

                        width: body.width / 3
                        height: (body.height - 20) / 4
                        checked: isCurrent
                        hoverFrame: "viewitem-hover"
                        pressedFrame: "viewitem-selected"
                        onClicked: {
                            if (root.view === "months") {
                                root.month = index;
                                root.view = "days";
                            } else {
                                root.year = value;
                                root.view = "months";
                            }
                        }

                        StyledText {
                            anchors.centerIn: parent
                            text: root.view === "months" ? Theme.capitalize(Qt.locale().standaloneMonthName(cell.index, Locale.ShortFormat)) : cell.value
                            font.pixelSize: 17
                        }
                    }
                }
            }
        }
    }
}
