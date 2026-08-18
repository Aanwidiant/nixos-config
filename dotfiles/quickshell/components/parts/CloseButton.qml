import QtQuick
import "../../theme"

Rectangle {
    id: closeButton

    anchors.top: parent.top
    anchors.topMargin: 4
    anchors.horizontalCenter: parent.horizontalCenter

    height: 2
    width: 64
    radius: Metrics.radiusFull
    color: hoverHandler.hovered ? Theme.primary : Qt.alpha(Theme.primary, 0.9)

    Shortcut {
        sequence: "Escape"
        enabled: closeButton.visible
        onActivated: controller.closeExpandedState()
    }

    Item {
        anchors.fill: parent
        anchors.margins: -4

        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: controller.closeExpandedState()
        }
    }
}
