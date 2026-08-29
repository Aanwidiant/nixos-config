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
        customColor: Theme.primary
        customFont: Qt.font({
            pixelSize: Metrics.textMD,
            weight: Font.DemiBold
        })
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: controller.openClockDetails()
    }
}
