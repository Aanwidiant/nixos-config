import QtQuick
import "../../theme"
import "../parts"

Item {
    id: root

    implicitWidth: 144
    implicitHeight: 32

    Clock {
        id: clockText
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: controller.openClockDetails()  
    }
}
