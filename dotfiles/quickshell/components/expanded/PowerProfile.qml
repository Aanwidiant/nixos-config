import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.UPower
import "../../theme"
import "../../services"
import "../parts"

Item {
    id: root

    implicitWidth: 280
    implicitHeight: 96

    property bool expanded: false

    function resetSelection() {
        if (repeater.count === 0) return

        let activeProfileEnum = BatteryService.activeProfile
        let targetIndex = 0 

        for (let i = 0; i < repeater.count; i++) {
            let item = repeater.itemAt(i)
            if (item && item.profileEnum === activeProfileEnum) {
                targetIndex = i
                break
            }
        }

        let targetItem = repeater.itemAt(targetIndex)
        if (targetItem) {
            targetItem.forceActiveFocus()
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
                    { profileEnum: PowerProfile.PowerSaver },
                    { profileEnum: PowerProfile.Balanced },
                    { 
                        profileEnum: PowerProfile.Performance,
                        enabled: BatteryService.hasPerformance 
                    }
                ]

                delegate: Rectangle {
                    id: btnRect
                    required property var modelData
                    required property int index

                    readonly property int profileEnum: modelData.profileEnum
                    readonly property bool isEnabledOption: modelData.enabled !== undefined ? modelData.enabled : true

                    readonly property bool isActiveProfile: BatteryService.activeProfile === profileEnum

                    readonly property string profileIcon: BatteryService.getProfileIconByEnum(profileEnum)
                    readonly property string profileLabel: BatteryService.getProfileLabelByEnum(profileEnum)

                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 72
                    radius: Metrics.radiusLG
                    opacity: isEnabledOption ? 1.0 : 0.4

                    color: (btnHover.hovered || btnRect.activeFocus) ? Qt.alpha(Theme.primary, 0.15) : Theme.surface

                    border.width: btnRect.activeFocus ? 2 : 0
                    border.color: Theme.primary

                    Rectangle {
                        id: activeIndicator
                        width: 6
                        height: 6
                        rotation: 45 
                        color: Theme.primary
                        visible: btnRect.isActiveProfile

                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 10
                        anchors.topMargin: 10

                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }
                    }

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
                        if (!isEnabledOption) return

                        BatteryService.setPowerProfile(btnRect.profileEnum)

                        console.log("Power Profile Changed to:", btnRect.profileLabel)
                        if (typeof controller !== "undefined" && controller.closeExpandedState) {
                            controller.closeExpandedState()
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: btnRect.profileIcon
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
                            text: btnRect.profileLabel
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
