import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../parts"

Item {
    id: root
    implicitWidth: 280
    implicitHeight: 180

    CloseButton {}

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: Metrics.spacingLG

        AnalogClock {
            id: analogClock
            Layout.alignment: Qt.AlignHCenter
        }

        Date {
            id: dateText
            Layout.alignment: Qt.AlignHCenter
            customFont: Qt.font({
                pixelSize: Metrics.textSM,
                weight: Font.Medium
            })
        }

    }
}
