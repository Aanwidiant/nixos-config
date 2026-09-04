import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../parts"

Item {
    id: root
    implicitWidth: 280
    implicitHeight: 160

    CloseButton {}

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: Metrics.spacingLG

        AnalogClock {
            id: analogClock
            Layout.alignment: Qt.AlignHCenter
        }
        ColumnLayout { 
            spacing: Metrics.spacingLG

            Clock {
                id: clockText
                Layout.alignment: Qt.AlignHCenter
                customFont: Qt.font({
                    pixelSize: Metrics.text3XL,
                    weight: Font.Bold,
                    family: Theme.textFont
                })
                customColor: Theme.primary
            }

            Date {
                id: dateText
                dateFormat: "dddd\ndd MMM yyyy"
                Layout.alignment: Qt.AlignHCenter
                customFont: Qt.font({
                    pixelSize: Metrics.textMD,
                    weight: Font.Medium,
                    family: Theme.textFont
                })
            }
        }
    }
}
