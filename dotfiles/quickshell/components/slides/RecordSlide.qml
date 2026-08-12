import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../theme"

Item {
    id: root

    implicitWidth: 144
    implicitHeight: 32

    // Properti reaktif: Mengambil data live dari RecordService
    readonly property bool active: RecordService.isRecording
    readonly property string displayTime: active ? RecordService.formattedTime : "00:00"

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.surface
        border.color: active 
                        ? "#f38ba8" 
                        : Qt.alpha(Theme.foreground, 0.15)
        border.width: 1

        RowLayout {
            anchors.centerIn: parent
            spacing: Metrics.spacingSM ?? 6

            // Status Indicator (Red Dot / Idle Dot)
            Rectangle {
                id: statusDot
                implicitWidth: 8
                implicitHeight: 8
                radius: 4
                color: active 
                        ? "#f38ba8" 
                        : Qt.alpha(Theme.foreground, 0.3)
                
                // Pastikan opacity kembali ke 1.0 saat perekaman berhenti
                opacity: 1.0

                // Kedip hanya jika recording sedang aktif
                SequentialAnimation {
                    running: root.active
                    loops: Animation.Infinite

                    NumberAnimation { 
                        target: statusDot
                        property: "opacity"
                        from: 1.0
                        to: 0.3
                        duration: 800 
                    }
                    NumberAnimation { 
                        target: statusDot
                        property: "opacity"
                        from: 0.3
                        to: 1.0
                        duration: 800 
                    }
                }
            }

            // Timer Text
            Text {
                text: root.displayTime
                color: root.active ? Theme.foreground : Qt.alpha(Theme.foreground, 0.5)
                font.pixelSize: Metrics.textSM ?? 12
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
            }

            // Action Button (Stop Recording saat aktif, Start Recording saat idle)
            Rectangle {
                implicitWidth: 20
                implicitHeight: 20
                radius: 10
                color: root.active 
                        ? Qt.alpha("#f38ba8", 0.2) 
                        : Qt.alpha(Theme.primary ?? "#89b4fa", 0.2)

                Text {
                    anchors.centerIn: parent
                    text: root.active ? "󰓛" : "󰑋" // Icon Stop (󰓛) atau Record (󰑋)
                    color: root.active 
                            ? "#f38ba8" 
                            : (Theme.primary ?? "#89b4fa")
                    font.pixelSize: 10
                }

                HoverHandler { cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        if (root.active) {
                            RecordService.stopRecording();
                        } else {
                            controller.openScreenrecord()
                        }
                    }
                }
            }
        }
    }
}
