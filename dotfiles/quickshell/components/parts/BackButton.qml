import QtQuick
import "../../theme"

Item {
    id: root
    implicitWidth: 32
    implicitHeight: 24

    signal clicked()

    property string iconText: "\uf060"
    property int iconSize: Metrics.textXL
    property color normalColor: Theme.foreground

    Text {
        id: backIcon
        anchors.centerIn: parent
        text: root.iconText 
        font.family: Theme.iconFont
        font.pixelSize: root.iconSize
        color: hoverHandler.hovered ? root.normalColor: Qt.alpha(root.normalColor, 0.9)

        Behavior on color {
            ColorAnimation { duration: 100 }
        }
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
