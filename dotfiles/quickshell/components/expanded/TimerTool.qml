import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../services"
import "../../theme"
import "../parts"

Item {
    id: root

    implicitWidth: 400
    implicitHeight: {
        if (root.currentTab !== "timer") {
            return 260
        }
        return (TimerService.tmRemaining > 0) ? 280 : 380
    }

    property string currentTab: "timer"

    CloseButton {}

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: Metrics.spacingLG

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacingLG

            HeaderIcon {
                iconText: "\uf520"
            }

            Text {
                text: "Timer & Stopwatch"
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
            text: "Mode"
            font.pixelSize: Metrics.textSM
            font.bold: true
            font.family: Theme.textFont
            color: Theme.foreground
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacingLG

            Repeater {
                model: [
                    { id: "timer", label: "Timer", icon: "\udb81\udd1b" },
                    { id: "stopwatch", label: "Stopwatch", icon: "\uf520" }
                ]

                delegate: Rectangle {
                    id: tabItem

                    required property var modelData

                    readonly property bool isActive: root.currentTab === modelData.id

                    Layout.fillWidth: true
                    implicitHeight: 42
                    radius: Metrics.radiusMD
                    color: isActive ? Theme.primary : Theme.surface

                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Metrics.spacingLG

                        Text {
                            text: tabItem.modelData.icon
                            color: tabItem.isActive ? Theme.background : Theme.foreground
                            font.pixelSize: Metrics.iconMD
                            font.family: Theme.iconFont
                        }

                        Text {
                            text: tabItem.modelData.label
                            color: tabItem.isActive ? Theme.background : Theme.foreground
                            font.pixelSize: Metrics.textMD
                            font.bold: tabItem.isActive
                            font.family: Theme.textFont
                        }
                    }

                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: root.currentTab = tabItem.modelData.id }
                }
            }
        }

        Item { Layout.fillHeight: true }

        Timer {
            visible: root.currentTab === "timer"
        }

        Stopwatch {
            visible: root.currentTab === "stopwatch"
        }
    }
}
