import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../theme"

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter

    ColumnLayout {
        Layout.fillWidth: true
        visible: !TimerService.tmRunning && TimerService.tmRemaining === 0
        spacing: Metrics.spacingXL

        ColumnLayout {
            Layout.fillWidth: true

            Layout.alignment: Qt.AlignHCenter
            spacing: Metrics.spacingLG

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Quick Presets"
                font.pixelSize: Metrics.textSM
                font.bold: true
                font.family: Theme.textFont
                color: Theme.foreground
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Metrics.spacingLG

                Repeater {
                    model: [
                        { label: "1m", secs: 60 },
                        { label: "5m", secs: 300 },
                        { label: "10m", secs: 600 },
                        { label: "25m", secs: 1500 }
                    ]

                    Rectangle {
                        implicitWidth: 64
                        implicitHeight: 32
                        radius: Metrics.radiusSM
                        color: tapPreset.pressed ? Theme.primary : Theme.surface

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            font.pixelSize: Metrics.textSM
                            font.bold: true
                            font.family: Theme.textFont
                            color: tapPreset.pressed ? Theme.background : Theme.foreground
                        }

                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                        TapHandler { 
                            id: tapPreset 
                            onTapped: TimerService.setPreset(modelData.secs) 
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: Metrics.spacingLG

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Custom Timer"
                font.pixelSize: Metrics.textSM
                font.bold: true
                font.family: Theme.textFont
                color: Theme.foreground
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Metrics.spacingMD

                DigitSpinBox {
                    value: Math.floor(TimerService.customHours / 10)
                    onValueModified: {
                        let units = TimerService.customHours % 10;
                        TimerService.customHours = (value * 10) + units;
                    }
                }
                DigitSpinBox {
                    value: TimerService.customHours % 10
                    onValueModified: {
                        let tens = Math.floor(TimerService.customHours / 10);
                        TimerService.customHours = (tens * 10) + value;
                    }
                }

                Text {
                    text: ":"
                    font.pixelSize: Metrics.text2XL
                    font.bold: true
                    font.family: Theme.textFont
                    color: Theme.foreground
                    Layout.alignment: Qt.AlignVCenter
                }

                DigitSpinBox {
                    to: 5
                    value: Math.floor(TimerService.customMins / 10)
                    onValueModified: {
                        let units = TimerService.customMins % 10;
                        TimerService.customMins = (value * 10) + units;
                    }
                }
                DigitSpinBox {
                    value: TimerService.customMins % 10
                    onValueModified: {
                        let tens = Math.floor(TimerService.customMins / 10);
                        TimerService.customMins = (tens * 10) + value;
                    }
                }

                Text {
                    text: ":"
                    font.pixelSize: Metrics.text2XL
                    font.bold: true
                    font.family: Theme.textFont
                    color: Theme.foreground
                    Layout.alignment: Qt.AlignVCenter
                }

                DigitSpinBox {
                    to: 5 
                    value: Math.floor(TimerService.customSecs / 10)
                    onValueModified: {
                        let units = TimerService.customSecs % 10;
                        TimerService.customSecs = (value * 10) + units;
                    }
                }
                DigitSpinBox {
                    value: TimerService.customSecs % 10
                    onValueModified: {
                        let tens = Math.floor(TimerService.customSecs / 10);
                        TimerService.customSecs = (tens * 10) + value;
                    }
                }
            }
        }

        Rectangle {
            implicitWidth: 120
            implicitHeight: 36
            radius: Metrics.radiusSM
            color: Theme.primary 
            opacity: TimerService.totalCustomSeconds > 0 ? 1.0 : 0.4
            Layout.alignment: Qt.AlignHCenter

            RowLayout {
                anchors.centerIn: parent
                spacing: Metrics.spacingMD

                Text {
                    text: "\uf04b"
                    color: Theme.background
                    font.pixelSize: Metrics.iconSM
                    font.family: Theme.iconFont
                }

                Text {
                    text: "Start"
                    font.pixelSize: Metrics.textSM
                    color: Theme.background
                    font.weight: Font.DemiBold
                    font.family: Theme.textFont
                }
            }

            HoverHandler { cursorShape: TimerService.totalCustomSeconds > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor }
            TapHandler { onTapped: TimerService.tmStartCustom() }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        visible: TimerService.tmRemaining > 0
        spacing: Metrics.spacingXL

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: TimerService.tmFormatted
            font.pixelSize: 48
            font.bold: true
            font.family: Theme.textFont
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
                        text: TimerService.tmRunning ? "\uf04c" : "\uf04b"
                        color: Theme.background
                        font.pixelSize: Metrics.iconSM
                        font.family: Theme.iconFont
                    }

                    Text {
                        text: TimerService.tmRunning ? "Pause" : "Start"
                        font.pixelSize: Metrics.textSM
                        color: Theme.background
                        font.weight: Font.DemiBold
                        font.family: Theme.textFont
                    }
                }

                HoverHandler { cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: TimerService.tmToggle() }
            }

            Rectangle {
                implicitWidth: 120
                implicitHeight: 36
                radius: Metrics.radiusSM
                color: Theme.surface
                opacity: TimerService.tmRunning ? 0.4 : 1.0

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
                        font.family: Theme.textFont
                    }
                }

                HoverHandler { 
                    cursorShape: TimerService.tmRunning ? Qt.ArrowCursor : Qt.PointingHandCursor 
                }

                TapHandler { 
                    enabled: !TimerService.tmRunning
                    onTapped: TimerService.tmReset() 
                }
            }
        }
    }
}
