import QtQuick

Item {
    id: triggerRoot

    required property var controller
    required property var islandItem

    width: Math.max(180, islandItem ? islandItem.width : 180)
    height: Math.max(16, islandItem ? (islandItem.y + islandItem.height) : 16)

    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter

    HoverHandler {
        id: topEdgeHoverHandler

        onHoveredChanged: {
            if (hovered) {
                triggerRoot.controller.isHovering = true
                triggerRoot.controller.stopAllTimers()

                if (triggerRoot.controller.currentState === "hidden" || !triggerRoot.controller.islandVisible) {
                    triggerRoot.controller.islandVisible = true
                    triggerRoot.controller.currentState = "clock"
                }
            } else {
                triggerRoot.controller.isHovering = false
                triggerRoot.controller.startExitSequence()
            }
        }
    }
}
