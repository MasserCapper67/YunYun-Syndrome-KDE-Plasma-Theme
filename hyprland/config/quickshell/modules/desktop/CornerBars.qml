import QtQuick
import qs.theme

// Purple + pink bars in the bottom corners, fading out towards the middle of the screen
Item {
    id: root

    height: 12

    // Bottom left: purple, then pink fading out
    Row {
        anchors.left: parent.left
        height: parent.height

        Rectangle {
            width: 235
            height: parent.height
            color: Theme.barPurple
        }

        Rectangle {
            width: 100
            height: parent.height
            color: Theme.barPink
        }

        Rectangle {
            width: 25
            height: parent.height
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: Theme.barPink }
                GradientStop { position: 1; color: "transparent" }
            }
        }
    }

    // Bottom right: fading in, purple, then pink to the edge
    Row {
        anchors.right: parent.right
        height: parent.height

        Rectangle {
            width: 10
            height: parent.height
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 1; color: Theme.barPurple }
            }
        }

        Rectangle {
            width: 125
            height: parent.height
            color: Theme.barPurple
        }

        Rectangle {
            width: 235
            height: parent.height
            color: Theme.barPink
        }
    }
}
