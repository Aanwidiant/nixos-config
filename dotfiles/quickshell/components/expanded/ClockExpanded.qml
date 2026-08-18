import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../parts"
import "../../services"

Item {
    id: root
    implicitWidth: 280
    implicitHeight: 220

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

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Metrics.spacingMD

            Repeater {
                model: [1, 2, 3, 4, 5, 6, 7, 8, 9]

                delegate: Rectangle {
                    id: tagBtn
                    required property int modelData

                    property bool isActive: TagService.activeTagsList.indexOf(tagBtn.modelData) !== -1
                    property bool isOccupied: TagService.occupiedTagsList.indexOf(tagBtn.modelData) !== -1

                    implicitWidth: 24
                    implicitHeight: 24
                    radius: Metrics.radiusSM 
                    color: tagBtn.isActive ? Theme.surface : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: tagBtn.modelData.toString()
                        font.pixelSize: Metrics.textSM
                        font.bold: tagBtn.isActive
                        color: tagBtn.isActive ? Theme.primary : (tagBtn.isOccupied ? Theme.foreground : Theme.muted)
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: TagService.switchTag(tagBtn.modelData)
                    }
                }
            }
        }
    }
}
