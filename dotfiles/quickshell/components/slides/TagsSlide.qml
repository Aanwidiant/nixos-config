import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../services"

Item {
    id: root
    required property string monitorName   

    implicitWidth: 156
    implicitHeight: 36

    readonly property var monData: TagService.monitorsByName[root.monitorName]
    readonly property var activeTags: monData ? monData.active_tags : []
    readonly property var tagsInfo: monData ? monData.tags : []

    RowLayout {
        anchors.centerIn: parent
        spacing: Metrics.spacingMD - 1
        Repeater {
            model: [1, 2, 3, 4, 5, 6, 7, 8, 9]
            delegate: Rectangle {
                id: tagBtn
                required property int modelData
                property bool isActive: root.activeTags.indexOf(tagBtn.modelData) !== -1
                property int clientCount: {
                    const info = root.tagsInfo.find(t => t.index === tagBtn.modelData)
                    return info ? info.client_count : 0
                }
                property bool isOccupied: tagBtn.clientCount > 0

                implicitWidth: tagBtn.isActive ? 24 : 10
                implicitHeight: 10
                radius: height / 2
                color: tagBtn.isActive ? Theme.primary : (tagBtn.isOccupied ? Theme.accent : Theme.muted)
                Behavior on implicitWidth {
                    NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                }
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: TagService.switchTag(root.monitorName, tagBtn.modelData)
                }
            }
        }
    }
}
