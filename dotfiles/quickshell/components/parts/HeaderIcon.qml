import QtQuick
import "../../theme"

Item {
    id: root

    implicitWidth: 32
    implicitHeight: 24

    property string iconText: "\uf060"
    property int iconSize: Metrics.textXL
    property color iconColor: Theme.foreground

    Text {
        id: icon
        anchors.centerIn: parent
        text: root.iconText
        font.family: Theme.iconFont
        font.pixelSize: root.iconSize
        color: root.iconColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
