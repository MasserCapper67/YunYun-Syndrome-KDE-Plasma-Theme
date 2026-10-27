import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.theme

// Dot-matrix audio visualizer hanging from the top of the panel, fed by cava
Item {
    id: root

    readonly property int dot: 3
    readonly property int pitchX: 5
    readonly property int pitchY: 4
    readonly property int rows: 6
    readonly property int columns: Math.max(0, Math.floor((width + pitchX - dot) / pitchX))
    property var levels: []
    property int failures: 0

    visible: Settings.visualizer && cava.running

    Process {
        id: cava

        running: Settings.visualizer && root.columns > 0
        command: ["cava", "-p", Quickshell.shellPath("assets/cava.conf")]
        stdout: SplitParser {
            onRead: line => {
                const values = line.split(";");
                const out = [];
                for (let i = 0; i < values.length; i++) {
                    if (values[i] !== "")
                        out.push(parseInt(values[i]));
                }
                root.levels = out;
                root.failures = 0;
            }
        }
        onExited: (code, status) => {
            root.levels = [];
            // cava missing or no audio server yet: retry a few times, then give up
            if (Settings.visualizer && root.failures < 5) {
                root.failures++;
                restart.start();
            }
        }
    }

    Timer {
        id: restart
        interval: 3000 * root.failures
        onTriggered: cava.running = Settings.visualizer
    }

    Row {
        spacing: root.pitchX - root.dot

        Repeater {
            model: root.columns

            Column {
                id: column

                required property int index
                // Spread the cava bars over however many columns fit
                readonly property int level: {
                    const n = root.levels.length;
                    if (n === 0)
                        return 0;
                    return root.levels[Math.min(n - 1, Math.floor(index * n / root.columns))];
                }

                spacing: root.pitchY - root.dot

                Repeater {
                    model: root.rows

                    Rectangle {
                        required property int index

                        width: root.dot
                        height: root.dot
                        color: Theme.visualizer
                        visible: index < column.level
                    }
                }
            }
        }
    }
}
