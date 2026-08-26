import QtQuick
import "../../theme"
import "../parts"

Item {
    id: root

    implicitWidth: 156
    implicitHeight: 36

    Clock {
        id: clockText
        anchors.centerIn: parent
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: controller.openClockDetails()
    }
}
