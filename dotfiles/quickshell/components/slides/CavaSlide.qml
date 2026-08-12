import QtQuick
import "../../theme"
import "../parts"

Item {
    id: root

    implicitWidth: 144
    implicitHeight: 32

    readonly property bool isCavaVisible: root.visible

    Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 12
        text: "\uf001"
        font.pixelSize: Metrics.textLG
        font.family: Theme.iconFont
        color: Theme.primary
    }

    CavaVisualizer {
        id: visualizer
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 12

        running: root.isCavaVisible
        isVisible: root.isCavaVisible

        barCount: 6
        barWidth: 2
        barSpacing: 2
        minHeight: 1
        maxHeight: 16
        barColor: Theme.primary
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: controller.openMusicDetails()
    }
}
