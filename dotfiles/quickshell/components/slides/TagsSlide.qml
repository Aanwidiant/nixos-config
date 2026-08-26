import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../services"

Item {
    id: root
    implicitWidth: 156
    implicitHeight: 36

    RowLayout { 
        anchors.centerIn: parent
        spacing: Metrics.spacingMD - 1

        Repeater {
            model: [1, 2, 3, 4, 5, 6, 7, 8, 9]

            delegate: Rectangle {
                id: tagBtn
                required property int modelData

                property bool isActive: TagService.activeTagsList.indexOf(tagBtn.modelData) !== -1
                property bool isOccupied: TagService.occupiedTagsList.indexOf(tagBtn.modelData) !== -1

                implicitWidth: tagBtn.isActive ? 24 : 10
                implicitHeight: 10
                radius: height / 2

                color: tagBtn.isActive ? Theme.primary : (tagBtn.isOccupied ?  Theme.accent : Theme.muted)

                Behavior on implicitWidth {
                    NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
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
