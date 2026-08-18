import QtQuick
import "../../theme"
import "../../services"

Item {
    id: root
    implicitWidth: 215
    implicitHeight: 32

    readonly property real volume: VolumeService.volume
    readonly property bool muted: VolumeService.isMuted

    readonly property int volumePercent: Math.round(root.volume * 100)

    Row {
        anchors.centerIn: parent
        spacing: Metrics.spacingXL

        Text {
            id: volumeIcon
            text: root.muted ? "\ueee8" : VolumeService.getVolumeIcon(root.volumePercent)
            color: root.muted ? Theme.muted : Theme.foreground
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
                width: parent.width * Math.min(1.0, root.volume)
                height: parent.height
                radius: Metrics.radiusFull
                color: root.muted ? Theme.muted : Theme.primary

                Behavior on width {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        Text {
            id: volumeText
            text: root.volumePercent + "%"
            color: root.muted ? Theme.muted : Theme.foreground
            font.pixelSize: Metrics.textSM
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignRight
        }
    }
}
