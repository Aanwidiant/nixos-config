import QtQuick
import "../../theme"
import "../../services"

Item {
    id: root
    implicitWidth: 215
    implicitHeight: 32

    readonly property real brightness: BrightnessService.brightness
    readonly property int brightnessPercent: Math.round(root.brightness * 100)

    Row {
        anchors.centerIn: parent
        spacing: Metrics.spacingXL

        Text {
            id: brightnessIcon
            text: BrightnessService.getBrightnessIcon(root.brightnessPercent)
            color: Theme.foreground
            font.pixelSize: Metrics.textXL
            font.family: Theme.iconFont 
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: progressBar
            width: 100
            height: 5
            radius: Metrics.radiusFull
            color: Theme.surface
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: progressFill
                width: parent.width * root.brightness
                height: parent.height
                radius: Metrics.radiusFull
                color: Theme.primary

                Behavior on width {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        Text {
            id: brightnessText
            text: root.brightnessPercent + "%"
            color: Theme.foreground
            font.pixelSize: Metrics.textSM
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignRight
        }
    }
}
