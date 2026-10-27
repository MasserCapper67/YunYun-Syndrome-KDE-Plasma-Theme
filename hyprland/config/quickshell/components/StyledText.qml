import QtQuick
import qs.theme

Text {
    color: Theme.text
    font.family: Theme.font
    font.weight: Theme.fontWeight
    font.pixelSize: Theme.fontSize
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
    textFormat: Text.PlainText
}
