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

    Connections {
        target: PowerService
        function onFinished() {
            controller.closeExpandedState()
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
                    { icon: "\uf023",     label: "Lock",     action: () => PowerService.lock() },
                    { icon: "\udb80\udf43", label: "Logout",   action: () => PowerService.logout() },
                    { icon: "\udb81\udcb2", label: "Suspend",  action: () => PowerService.suspend() },
                    { icon: "\udb81\udf09", label: "Reboot",   action: () => PowerService.reboot() },
                    { icon: "\uf011",     label: "Shutdown", action: () => PowerService.shutdown() }
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
                        modelData.action()
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
                            font.family: Theme.textFont
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
