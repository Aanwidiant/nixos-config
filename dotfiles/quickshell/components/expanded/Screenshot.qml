import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../theme" 
import "../parts" 

Item {
    id: root

    implicitWidth: 400
    implicitHeight: 205

    CloseButton {}

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: Metrics.spacingLG

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacingLG

            HeaderIcon {
                iconText: "\udb80\udd04"
            }

            Text {
                text: "Screen Capture"
                font.pixelSize: Metrics.textLG
                font.bold: true
                font.family: Theme.textFont
                color: Theme.foreground
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
        }

        Text {
            text: "Capture Mode"
            font.pixelSize: Metrics.textSM
            font.bold: true
            font.family: Theme.textFont
            color: Theme.foreground
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacingLG

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 42
                radius: Metrics.radiusMD
                color: ScreenshotService.selectedMode === "region" ? Theme.primary : Theme.surface

                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Metrics.spacingLG

                    Text {
                        text: "\udb86\udcf5"
                        color: ScreenshotService.selectedMode === "region" ? Theme.background : Theme.foreground
                        font.pixelSize: Metrics.iconMD
                        font.family: Theme.iconFont
                    }

                    Text {
                        text: "Region"
                        color: ScreenshotService.selectedMode === "region" ? Theme.background : Theme.foreground
                        font.pixelSize: Metrics.textMD
                        font.bold: ScreenshotService.selectedMode === "region"
                        font.family: Theme.textFont
                    }
                }                

                HoverHandler { cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: ScreenshotService.selectedMode = "region" }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 42
                radius: Metrics.radiusMD
                color: ScreenshotService.selectedMode === "fullscreen"  ? Theme.primary : Theme.surface

                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Metrics.spacingLG

                    Text {
                        text: "\udb83\ude51"
                        color: ScreenshotService.selectedMode === "fullscreen" ? Theme.background : Theme.foreground
                        font.pixelSize: Metrics.iconMD
                        font.family: Theme.iconFont
                    }

                    Text {
                        text: "Fullscreen"
                        color: ScreenshotService.selectedMode === "fullscreen" ? Theme.background : Theme.foreground
                        font.pixelSize: Metrics.textMD
                        font.bold: ScreenshotService.selectedMode === "fullscreen"
                        font.family: Theme.textFont
                    }
                }  

                HoverHandler { cursorShape: Qt.PointingHandCursor }

                TapHandler {
                    onTapped: ScreenshotService.selectedMode = "fullscreen"
                }
            }
        }

        Item { Layout.fillHeight: true }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 42
            radius: Metrics.radiusMD
            color: Theme.primary

            RowLayout {
                anchors.centerIn: parent
                spacing: Metrics.spacingLG

                Text {
                    text: "\udb80\udd04"
                    color: Theme.background 
                    font.pixelSize: Metrics.iconLG
                    font.family: Theme.iconFont
                }

                Text {
                    text: "Take Screenshot"
                    color: Theme.background 
                    font.pixelSize: Metrics.textMD
                    font.bold: true 
                    font.family: Theme.textFont
                }
            } 

            HoverHandler { cursorShape: Qt.PointingHandCursor }

            TapHandler {
                onTapped: {
                    controller.closeExpandedState(() => {
                        ScreenshotService.takeScreenshot(); 
                    });
                }
            }
        }
    }
}
