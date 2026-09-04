import QtQuick
import "../../theme"
import "../../services"

Item {
    id: root
    implicitWidth: 160
    implicitHeight: 36

    readonly property bool muted: MicrophoneService.muted

    Row {
        anchors.centerIn: parent
        spacing: Metrics.spacingXL

        Text {
            id: micIcon
            text: root.muted ? "\udb80\udf6d" : "\udb80\udf6c"
            color: root.muted ? Theme.muted : Theme.foreground
            font.pixelSize: Metrics.textXL
            font.family: Theme.iconFont
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: micText
            text: root.muted ? "Muted" : "Unmuted"
            color: root.muted ? Theme.muted : Theme.foreground
            font.pixelSize: Metrics.textSM
            font.family: Theme.textFont
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
