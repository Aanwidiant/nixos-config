import QtQuick
import Quickshell
import "../theme"
import "../components/expanded"
import "../services"

Item {
    id: root

    property alias islandItem: island
    property alias topEdgeTrigger: trigger

    property alias islandVisible: controller.islandVisible
    property alias isHovering: controller.isHovering
    property alias currentState: controller.currentState
    property alias pendingContent: controller.pendingContent
    property alias pendingType: controller.pendingType
    property alias isClosingExpanded: controller.isClosingExpanded

    readonly property alias isExpandedState: controller.isExpandedState
    readonly property alias isExpandedOrClosing: controller.isExpandedOrClosing
    readonly property alias isBusy: controller.isBusy

    IslandController {
        id: controller
        expandedPopup: expandedPopup
        osdContainer: osdContainer
    }

    IslandTrigger {
        id: trigger
        controller: controller
        islandItem: island
    }

    function stopAllTimers() { controller.stopAllTimers() }
    function startExitSequence() { controller.startExitSequence() }
    function openClockDetails() { controller.openClockDetails() }
    function openMusicDetails() { controller.openMusicDetails() }
    function closeExpandedState() { controller.closeExpandedState() }

    Rectangle {
        id: island
        visible: true

        readonly property Item activeContent: {
            if (controller.isExpandedState && !controller.isClosingExpanded) return expandedPopup
            if (controller.currentState === "hidden" || !controller.islandVisible) return null
            return clockLoader.item
        }

        readonly property bool isFullyHidden: (controller.currentState === "hidden" || !controller.islandVisible) && height <= 12

        width: activeContent ? activeContent.implicitWidth : 148
        height: (controller.currentState === "hidden" || !controller.islandVisible) ? 6 : (activeContent ? activeContent.implicitHeight : 32)

        color: (controller.currentState === "notification" && NotificationService.activeCount > 1) ? "transparent" : Theme.background
        anchors.horizontalCenter: parent.horizontalCenter
        y: (controller.currentState === "hidden" || !controller.islandVisible) ? 0 : 8

        readonly property bool isRegularExpanded: controller.isExpandedState
        && !controller.isClosingExpanded

        topLeftRadius: isFullyHidden ? 0 : (isRegularExpanded ? Metrics.radiusXL : Metrics.radiusFull)
        topRightRadius: isFullyHidden ? 0 : (isRegularExpanded ? Metrics.radiusXL : Metrics.radiusFull)
        bottomLeftRadius: isFullyHidden ? 16 : (isRegularExpanded ? Metrics.radiusXL : Metrics.radiusFull)
        bottomRightRadius: isFullyHidden ? 16 : (isRegularExpanded ? Metrics.radiusXL : Metrics.radiusFull)

        Behavior on width { SpringAnimation { spring: 4.5; damping: 0.35; epsilon: 0.25 } }
        Behavior on height { SpringAnimation { spring: 4.5; damping: 0.35; epsilon: 0.25 } }
        Behavior on y { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

        onHeightChanged: {
            if (controller.isClosingExpanded && Math.abs(height - 32) < 0.5) {
                controller.isClosingExpanded = false
                controller.currentState = "clock"
                if (!controller.isHovering) {
                    controller.startExitSequence()
                }
            }
        }

        Item {
            anchors.fill: parent
            clip: true
            z: 2

            opacity: (controller.currentState === "hidden" || !controller.islandVisible) ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 150 } }

            ExpandedPopup {
                id: expandedPopup
                anchors.centerIn: parent
                contentType: controller.currentState
                expanded: controller.isExpandedState && !controller.isClosingExpanded

                Behavior on opacity {
                    id: expandedFadeOut
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                        onRunningChanged: {
                            if (!expandedFadeOut.running && controller.isClosingExpanded) {
                                controller.clockShowDelay.start()
                            }
                        }
                    }
                }
            }

            Item {
                id: osdContainer
                anchors.fill: parent
                anchors.margins: 6
                property bool _showClock: false

                visible: !controller.isExpandedState
                opacity: (controller.isExpandedState || (controller.isClosingExpanded && !_showClock)) ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 150 } }

                Loader {
                    id: clockLoader
                    anchors.fill: parent
                    source: "DefaultIsland.qml"
                    visible: controller.currentState === "clock" || (controller.isClosingExpanded && osdContainer._showClock)
                }
            }
        }
    }
}
