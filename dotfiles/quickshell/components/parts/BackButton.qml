import QtQuick
import "../../theme"

Item {
    id: root
    implicitWidth: 32
    implicitHeight: 24

    signal clicked()

    property string iconText: "\uf060"
    property int iconSize: Metrics.textXL
    property color normalColor: Theme.muted
    property color hoverColor: Theme.primary

    Text {
        id: backIcon
        anchors.centerIn: parent
        text: root.iconText 
        font.family: Theme.iconFont
        font.pixelSize: root.iconSize
        color: mouseArea.containsMouse ? root.hoverColor : root.normalColor

        Behavior on color { ColorAnimation { duration: 150 } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: root.clicked()
    }
}
