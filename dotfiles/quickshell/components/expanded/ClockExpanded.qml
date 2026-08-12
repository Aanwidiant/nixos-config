import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../parts"
import "../../services"

Item {
    id: root
    implicitWidth: 280
    implicitHeight: 72

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: 6

        Item {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: headerRow.implicitWidth
            implicitHeight: headerRow.implicitHeight

            RowLayout {
                id: headerRow
                anchors.fill: parent
                spacing: 8

                Date {
                    id: dateText
                    customFont: Qt.font({
                        pixelSize: Metrics.textSM,
                        weight: Font.Medium
                    })
                }

                Text {
                    text: "•"
                    font.pixelSize: Metrics.textSM
                    color: Theme.muted
                }

                Clock {
                    id: clockText
                    customFont: Qt.font({
                        pixelSize: Metrics.textMD,
                        weight: Font.Bold
                    })
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: controller.closeExpandedState()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 1

            Repeater {
                model: [1, 2, 3, 4, 5, 6, 7, 8, 9]
                delegate: Rectangle {
                    id: tagBtn
                    required property int modelData

                    property bool isActive: TagService.activeTagsList.indexOf(tagBtn.modelData) !== -1
                    property bool isOccupied: TagService.occupiedTagsList.indexOf(tagBtn.modelData) !== -1

                    implicitWidth: 24
                    implicitHeight: 24
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: tagBtn.modelData.toString()
                        font.pixelSize: Metrics.textSM
                        font.weight: tagBtn.isActive ? Font.Bold : Font.Normal

                        color: tagBtn.isActive 
                        ? Theme.primary 
                        : (tagBtn.isOccupied ? Theme.foreground : Theme.muted)
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: TagService.switchTag(tagBtn.modelData)
                    }
                }
            }
        }
    }
}
