import QtQuick
import Quickshell.Widgets
import QtQuick.Layouts
import "../../theme"

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 0

    // --- PROPERTY INTERFACE ---
    property real value: 0.0
    property real minVal: 0.0
    property real maxVal: 1.0
    property bool isMuted: false
    property string iconText: ""
    property bool hasIconClickAction: false

    // --- SIGNALS / CALLBACKS ---
    signal valueMoved(real newValue)
    signal iconClicked()

    // Internal Calculations
    readonly property int percentVal: Math.round(value * 100)

    Item {
        id: slider
        Layout.fillWidth: true
        implicitHeight: 44

        property bool isDragging: sliderArea.pressed

        // --- TRACK CONTAINER ---
        ClippingRectangle {
            id: track
            anchors.fill: parent
            radius: height / 2
            color: sliderArea.containsMouse ? Qt.alpha(Theme.foreground, 0.12) : Qt.alpha(Theme.foreground, 0.08)

            Behavior on color { ColorAnimation { duration: 150 } }

            // --- TRACK FILL ---
            Rectangle {
                id: trackFill
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                // Visual mentok di 100% (1.0)
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

            // --- THUMB ---
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

        // --- ICON AREA (KIRI) ---
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

            MouseArea {
                anchors.fill: parent
                enabled: root.hasIconClickAction
                cursorShape: root.hasIconClickAction ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.iconClicked()
                onPressed: (mouse) => {
                    if (root.hasIconClickAction) mouse.accepted = true
                }
            }
        }

        // --- SLIDER MOUSE AREA (DRAG & WHEEL) ---
        MouseArea {
            id: sliderArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            preventStealing: true
            z: 1

            function updateValueFromMouse(mouseXPos) {
                var rawRatio = mouseXPos / track.width
                var newVal = Math.max(root.minVal, Math.min(rawRatio * 1.0, root.maxVal))
                root.valueMoved(newVal)
            }

            onPressed: (mouse) => updateValueFromMouse(mouse.x)
            onPositionChanged: (mouse) => { if (pressed) updateValueFromMouse(mouse.x) }

            onWheel: (wheel) => {
                var step = 0.05
                var delta = wheel.angleDelta.y > 0 ? step : -step
                var targetVal = Math.max(root.minVal, Math.min(root.value + delta, root.maxVal))
                root.valueMoved(targetVal)
            }
        }
    }
}
