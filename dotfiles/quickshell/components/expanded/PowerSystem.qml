import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import "../../theme"
import "../../services"
import "../parts"

Item {
    id: root

    implicitWidth: 420
    implicitHeight: 96

    property bool expanded: false

    Process {
        id: runnerProcess
    }

    function resetSelection() {
        if (repeater.count > 0) {
            let firstItem = repeater.itemAt(0)
            if (firstItem) {
                firstItem.forceActiveFocus()
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            resetSelection()
        }
    }

    onExpandedChanged: {
        if (expanded) {
            resetSelection()
        }
    }

    CloseButton {}

    Item {
        id: container
        anchors.fill: parent
        anchors.margins: 6

        RowLayout {
            id: rowLayout
            anchors.centerIn: parent
            spacing: Metrics.spacingLG

            Repeater {
                id: repeater
                model: [
                    { icon: "\uf023",     label: "Lock",     cmd: "my-lock-screen" },
                    { icon: "\udb80\udf43", label: "Logout",   cmd: "my-cmd-logout" },
                    { icon: "\udb81\udcb2", label: "Suspend",  cmd: "systemctl suspend" },
                    { icon: "\udb81\udf09", label: "Reboot",   cmd: "my-cmd-reboot" },
                    { icon: "\uf011",     label: "Shutdown", cmd: "my-cmd-shutdown" }
                ]

                delegate: Rectangle {
                    id: btnRect
                    required property var modelData
                    required property int index

                    Layout.preferredWidth: 72
                    Layout.preferredHeight: 72
                    radius: Metrics.radiusLG

                    color: (btnHover.hovered || btnRect.activeFocus) ? Qt.alpha(Theme.primary, 0.15) : Theme.surface 

                    border.width: btnRect.activeFocus ? 2 : 0
                    border.color: Theme.primary 

                    Keys.onLeftPressed: {
                        let prevIndex = (btnRect.index - 1 + repeater.count) % repeater.count
                        repeater.itemAt(prevIndex).forceActiveFocus()
                    }

                    Keys.onRightPressed: {
                        let nextIndex = (btnRect.index + 1) % repeater.count
                        repeater.itemAt(nextIndex).forceActiveFocus()
                    }

                    Keys.onReturnPressed: performAction()
                    Keys.onSpacePressed: performAction()

                    function performAction() {
                        runnerProcess.command = ["sh", "-c", modelData.cmd]
                        runnerProcess.running = true

                        controller.closeExpandedState()
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.icon
                            font.family: Theme.iconFont 
                            font.pixelSize: (btnHover.hovered || btnRect.activeFocus) ? Metrics.text2XL : Metrics.textXL
                            color: (btnHover.hovered || btnRect.activeFocus) ? Theme.primary : Qt.alpha(Theme.primary, 0.8)

                            Behavior on font.pixelSize {
                                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                            }

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.label
                            font.pixelSize: Metrics.textXS
                            font.weight: Font.Medium
                            color: (btnHover.hovered || btnRect.activeFocus) ? Theme.primary : Qt.alpha(Theme.primary, 0.8)

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }
                    }

                    HoverHandler {
                        id: btnHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    
                    TapHandler {
                        onTapped: {
                            if (btnRect.activeFocus) {
                                btnRect.performAction()
                            } else {
                                btnRect.forceActiveFocus()
                            }
                        }
                    }
                }
            }
        }
    }
}
