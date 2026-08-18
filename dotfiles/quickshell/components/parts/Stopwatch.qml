import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../theme"

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter
    spacing: Metrics.spacingLG

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: TimerService.swFormatted
        font.pixelSize: Metrics.text4XL
        font.bold: true
        color: Theme.foreground
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Metrics.spacingLG

        Rectangle {
            implicitWidth: 120
            implicitHeight: 36
            radius: Metrics.radiusSM
            color: Theme.primary

            RowLayout {
                anchors.centerIn: parent
                spacing: Metrics.spacingMD

                Text {
                    text: TimerService.swRunning ? "\uf04c" : "\uf04b"
                    color: Theme.background
                    font.pixelSize: Metrics.iconSM
                    font.family: Theme.iconFont
                }

                Text {
                    text: TimerService.swRunning ? "Pause" : "Start"
                    font.pixelSize: Metrics.textSM
                    color: Theme.background
                    font.weight: Font.DemiBold
                }
            }

            HoverHandler { cursorShape: Qt.PointingHandCursor }

            TapHandler { onTapped: TimerService.swToggle() }
        }

        Rectangle {
            implicitWidth: 120
            implicitHeight: 36
            radius: Metrics.radiusSM
            color: Theme.surface
            opacity: TimerService.swCanReset ? 1.0 : 0.4

            RowLayout {
                anchors.centerIn: parent
                spacing: Metrics.spacingMD

                Text {
                    text: "\uead2"
                    color: Theme.foreground
                    font.pixelSize: Metrics.iconSM
                    font.family: Theme.iconFont
                }

                Text {
                    text: "Reset"
                    font.pixelSize: Metrics.textSM
                    color: Theme.foreground
                    font.weight: Font.DemiBold
                }
            }

            HoverHandler { 
                cursorShape: TimerService.swCanReset ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            TapHandler { 
                enabled: TimerService.swCanReset
                onTapped: TimerService.swReset() 
            }
        }
    }
}
