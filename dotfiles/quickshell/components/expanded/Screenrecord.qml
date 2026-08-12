import QtQuick
import QtQuick.Layouts
import "../../services" 
import "../../theme" 
import "../parts" 

Item {
    id: root

    implicitWidth: 400
    implicitHeight: RecordService.isRecording ? 240 : 400

    Shortcut {
        sequence: "Escape"
        enabled: root.visible
        onActivated: controller.closeExpandedState()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: Metrics.spacingLG

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacingLG

            HeaderIcon {
                iconText: "\uf03d"
            }

            Text {
                text: "Screen Recorder"
                font.pixelSize: Metrics.textLG
                font.bold: true
                color: Theme.foreground
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Metrics.spacingLG
            visible: !RecordService.isRecording

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacingLG 

                Text {
                    text: "Record Area"
                    font.pixelSize: Metrics.textSM
                    font.bold: true
                    color: Theme.foreground
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacingLG

                    Repeater {
                        model: [
                            { id: "region", icon: "\udb86\udcf5", label: "Region" },
                            { id: "fullscreen", icon: "\udb83\ude51", label: "Fullscreen" }
                        ]

                        delegate: Rectangle {
                            id: area
                            required property var modelData

                            Layout.fillWidth: true
                            implicitHeight: 42
                            radius: Metrics.radiusMD
                            color: RecordService.selectedMode === area.modelData.id ? Theme.primary : Theme.surface

                            Behavior on color { ColorAnimation { duration: 150 } }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: Metrics.spacingLG

                                Text {
                                    text: area.modelData.icon
                                    color: RecordService.selectedMode === area.modelData.id ? Theme.background : Theme.foreground
                                    font.pixelSize: Metrics.iconMD
                                    font.family: Theme.iconFont
                                }

                                Text {
                                    text: area.modelData.label
                                    color: RecordService.selectedMode === area.modelData.id ? Theme.background : Theme.foreground
                                    font.pixelSize: Metrics.textMD
                                    font.bold: RecordService.selectedMode === area.modelData.id
                                }
                            }

                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: RecordService.selectedMode = area.modelData.id }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacingLG 

                Text {
                    text: "Audio Input"
                    font.pixelSize: Metrics.textSM
                    font.bold: true
                    color: Theme.foreground
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: Metrics.spacingLG
                    columnSpacing: Metrics.spacingLG

                    Repeater {
                        model: [
                            { id: "none", icon: "\udb80\udf6d", label: "No Audio" },
                            { id: "mic", icon: "\udb80\udf6c", label: "Microphone" },
                            { id: "desktop", icon: "\udb84\udc1e", label: "Desktop" },
                            { id: "combined", icon: "\udb81\udf79", label: "Combined" }
                        ]

                        delegate: Rectangle {
                            id: audio
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 42
                            radius: Metrics.radiusMD
                            color: RecordService.selectedAudio === audio.modelData.id ? Theme.primary : Theme.surface 

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: Metrics.spacingLG

                                Text {
                                    text: audio.modelData.icon 
                                    color: RecordService.selectedAudio === audio.modelData.id ? Theme.background : Theme.foreground
                                    font.pixelSize: Metrics.iconMD
                                    font.family: Theme.iconFont
                                }

                                Text {
                                    text: audio.modelData.label 
                                    color: RecordService.selectedAudio === audio.modelData.id ? Theme.background : Theme.foreground
                                    font.pixelSize: Metrics.textMD
                                    font.bold: RecordService.selectedAudio === audio.modelData.id
                                }
                            } 

                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: RecordService.selectedAudio = audio.modelData.id }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacingLG 

                Text {
                    text: "Frame Rate"
                    font.pixelSize: Metrics.textSM
                    font.bold: true
                    color: Theme.foreground
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacingLG

                    Repeater {
                        model: [
                            { id: 30, icon: "\udb82\udea1", label: "30 FPS" },
                            { id: 60, icon: "\udb82\udea5", label: "60 FPS"}
                        ]

                        delegate: Rectangle {
                            id: fps
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 42
                            radius: Metrics.radiusMD
                            color: RecordService.selectedFps === fps.modelData.id ? Theme.primary : Theme.surface 

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: Metrics.spacingLG

                                Text {
                                    text: fps.modelData.icon 
                                    color: RecordService.selectedFps === fps.modelData.id ? Theme.background : Theme.foreground
                                    font.pixelSize: Metrics.iconMD
                                    font.family: Theme.iconFont
                                }

                                Text {
                                    text: fps.modelData.label
                                    color: RecordService.selectedFps === fps.modelData.id ? Theme.background : Theme.foreground
                                    font.pixelSize: Metrics.textMD
                                    font.bold: RecordService.selectedFps === fps.modelData.id
                                }
                            } 

                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: RecordService.selectedFps = fps.modelData.id }
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            visible: RecordService.isRecording
            spacing: Metrics.spacingLG

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Metrics.spacingMD

                Text {
                    text: "\udb81\udc4b"
                    font.pixelSize: Metrics.iconXL
                    font.family: Theme.iconFont
                    color: Theme.danger

                    SequentialAnimation on opacity {
                        running: RecordService.isRecording
                        loops: Animation.Infinite

                        NumberAnimation { to: 0.3; duration: 800 }
                        NumberAnimation { to: 1.0; duration: 800 }
                    }
                }

                Text {
                    text: "\uf03d"
                    font.pixelSize: Metrics.iconXL
                    font.family: Theme.iconFont
                    color: Theme.danger
                }

                Text {
                    text: "Recording..."
                    font.pixelSize: Metrics.textLG
                    font.bold: true
                    color: Theme.foreground
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: RecordService.formattedTime
                font.pixelSize: Metrics.text4XL
                font.bold: true
                color: Theme.primary
            }

            Item {
                Layout.fillHeight: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 42
            radius: Metrics.radiusMD
            color: RecordService.isRecording ? Theme.danger : Theme.primary

            RowLayout {
                anchors.centerIn: parent
                spacing: Metrics.spacingLG

                Text {
                    text: RecordService.isRecording ? "\ueba5" : "\uf03d"  
                    color: Theme.background 
                    font.pixelSize: Metrics.iconLG
                    font.family: Theme.iconFont
                }

                Text {
                    text: RecordService.isRecording ? "Stop Recording" : "Start Recording" 
                    color: Theme.background
                    font.pixelSize: Metrics.textMD
                    font.bold: true 
                }
            } 

            HoverHandler { cursorShape: Qt.PointingHandCursor }
            TapHandler {
                onTapped: {
                    if (RecordService.isRecording) {
                        controller.closeExpandedState();
                        RecordService.stopRecording(); 
                    } else {
                        controller.closeExpandedState(() => {
                            RecordService.startRecording();
                        });
                    }
                }
            }
        }
    }
}
