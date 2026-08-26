import QtQuick
import QtQuick.Shapes
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

        width: activeContent ? activeContent.implicitWidth : 156
        height: (controller.currentState === "hidden" || !controller.islandVisible) ? 10 : (activeContent ? activeContent.implicitHeight : 36)

        color: "transparent"
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0

        readonly property bool isRegularExpanded: controller.isExpandedState && !controller.isClosingExpanded

        property real concaveRadius: Metrics.radiusSM

        readonly property real rawBottomRadius: isFullyHidden ? Metrics.radiusXS : (isRegularExpanded ? Metrics.radiusLG : Metrics.radiusMD)
        readonly property real bottomRadius: Math.min(rawBottomRadius, height / 2)

        Behavior on width { SpringAnimation { spring: 6; damping: 0.4; epsilon: 0.25 } }
        Behavior on height { SpringAnimation { spring: 6; damping: 0.4; epsilon: 0.25 } }
        Behavior on y { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

        Shape {
            id: islandBackground
            anchors.fill: parent
            anchors.leftMargin: -island.concaveRadius
            anchors.rightMargin: -island.concaveRadius

            visible: !island.isFullyHidden
            z: 0

            layer.enabled: true
            layer.samples: 8
            smooth: true

            ShapePath {
                fillColor: Qt.alpha(Theme.background, 0.75)
                strokeColor: Qt.alpha(Theme.primary, 0.1) 

                startX: 0
                startY: 0

                PathArc {
                    x: island.concaveRadius
                    y: island.concaveRadius
                    radiusX: island.concaveRadius
                    radiusY: island.concaveRadius
                    direction: PathArc.Clockwise
                }

                PathLine { 
                    x: island.concaveRadius
                    y: island.height - island.bottomRadius 
                }

                PathArc {
                    x: island.concaveRadius + island.bottomRadius
                    y: island.height
                    radiusX: island.bottomRadius
                    radiusY: island.bottomRadius
                    direction: PathArc.Counterclockwise
                }

                PathLine { 
                    x: island.concaveRadius + island.width - island.bottomRadius
                    y: island.height 
                }

                PathArc {
                    x: island.concaveRadius + island.width
                    y: island.height - island.bottomRadius
                    radiusX: island.bottomRadius
                    radiusY: island.bottomRadius
                    direction: PathArc.Counterclockwise
                }

                PathLine { 
                    x: island.concaveRadius + island.width
                    y: island.concaveRadius 
                }

                PathArc {
                    x: island.concaveRadius * 2 + island.width
                    y: 0
                    radiusX: island.concaveRadius
                    radiusY: island.concaveRadius
                    direction: PathArc.Clockwise
                }

                PathLine { x: 0; y: 0 }
            }
        }

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
