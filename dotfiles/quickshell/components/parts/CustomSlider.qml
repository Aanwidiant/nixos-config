import QtQuick
import Quickshell.Widgets
import QtQuick.Layouts
import "../../theme"

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 0

    property real value: 0.0
    property real minVal: 0.0
    property real maxVal: 1.0
    property bool isMuted: false
    property string iconText: ""
    property bool hasIconClickAction: false

    signal valueMoved(real newValue)
    signal iconClicked()

    readonly property int percentVal: Math.round(value * 100)

    Item {
        id: slider
        Layout.fillWidth: true
        implicitHeight: 44

        property bool isDragging: dragHandler.active

        ClippingRectangle {
            id: track
            anchors.fill: parent
            radius: height / 2
            color: sliderHover.hovered
            ? Qt.alpha(Theme.foreground, 0.12)
            : Qt.alpha(Theme.foreground, 0.08)

            Behavior on color { ColorAnimation { duration: 150 } }

            Rectangle {
                id: trackFill
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                width: Math.max(0, Math.min(1.0, root.value / 1.0) * parent.width)

                color: root.isMuted
                ? Qt.alpha(Theme.muted, 0.35)
                : (root.value > 1.0 ? Theme.warning : Theme.primary)

                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on width {
                    enabled: !slider.isDragging
                    SmoothedAnimation { velocity: 800 }
                }
            }

            Rectangle {
                id: thumb
                z: 3
                anchors.verticalCenter: parent.verticalCenter
                x: Math.max(0, Math.min(track.width - width, (Math.min(1.0, root.value) * track.width) - (width / 2)))
                width: 2
                height: parent.height
                color: Theme.foreground

                Behavior on x {
                    enabled: !slider.isDragging
                    SmoothedAnimation { velocity: 800 }
                }
            }
        }

        Item {
            id: iconArea
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 44
            z: 2

            Text {
                anchors.centerIn: parent
                text: root.iconText
                font.family: Theme.iconFont
                font.pixelSize: Metrics.textXL
                color: root.isMuted ? Theme.foreground : Theme.background

                Behavior on color { ColorAnimation { duration: 150 } }
            }

            HoverHandler {
                id: iconHover
                cursorShape: root.hasIconClickAction
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor
            }

            TapHandler {
                enabled: root.hasIconClickAction
                grabPermissions: PointerHandler.CanTakeOverFromAnything
                onTapped: root.iconClicked()
            }
        }

        Text {
            id: percentText
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            z: 2

            text: root.percentVal + "%"
            font.pixelSize: Metrics.textSM
            font.family: Theme.textFont
            font.weight: Font.DemiBold

            color: {
                if (root.isMuted) return Theme.foreground;
                return (trackFill.width > parent.width - width - 16)
                ? Theme.background
                : Theme.foreground;
            }

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        HoverHandler {
            id: sliderHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            grabPermissions: PointerHandler.CanTakeOverFromItems
            onPressedChanged: {
                if (pressed && point.position.x > iconArea.width) {
                    var rawRatio = point.position.x / track.width
                    var newVal = Math.max(root.minVal, Math.min(rawRatio, root.maxVal))
                    root.valueMoved(newVal)
                }
            }
        }

        DragHandler {
            id: dragHandler
            target: null
            xAxis.enabled: true
            yAxis.enabled: false
            grabPermissions: PointerHandler.CanTakeOverFromItems

            onActiveChanged: {
                if (active && centroid.position.x > iconArea.width) {
                    var rawRatio = centroid.position.x / track.width
                    var newVal = Math.max(root.minVal, Math.min(rawRatio, root.maxVal))
                    root.valueMoved(newVal)
                }
            }

            onCentroidChanged: {
                if (active) {
                    var rawRatio = centroid.position.x / track.width
                    var newVal = Math.max(root.minVal, Math.min(rawRatio, root.maxVal))
                    root.valueMoved(newVal)
                }
            }
        }
        WheelHandler {
            id: wheelHandler
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            blocking: false
            target: null

            onWheel: (event) => {
                var step = 0.05
                var delta = event.angleDelta.y > 0 ? step : -step
                var newVal = Math.max(root.minVal, Math.min(root.value + delta, root.maxVal))
                root.valueMoved(newVal)
            }
        }
    }
}
