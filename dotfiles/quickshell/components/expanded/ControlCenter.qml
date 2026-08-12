import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../services" 
import "../../theme" 
import "../parts"

Item {
    id: root

    implicitWidth: 400
    implicitHeight: 472

    property string currentUser: Quickshell.env("USER") || "Guest"

    Shortcut {
        sequence: "Escape"
        enabled: root.visible
        onActivated: controller.closeExpandedState()
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        spacing: Metrics.spacingXL

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacingLG
            Layout.leftMargin: 6
            Layout.rightMargin: 6

            RowLayout {
                spacing: Metrics.spacingMD


                Text {
                    id: userIcon
                    text: "\uf2bd" 
                    font.family: Theme.iconFont
                    font.pixelSize: Metrics.text2XL
                    color: Theme.primary 
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    id: userName
                    text: currentUser 
                    font.pixelSize: Metrics.textMD
                    color: Theme.primary 
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Item {
                implicitWidth: 32
                implicitHeight: 32
                Layout.alignment: Qt.AlignVCenter

                Text {
                    id: powerIcon
                    anchors.centerIn: parent
                    text: "\uf011"
                    font.family: Theme.iconFont
                    font.pixelSize: Metrics.textXL
                    color: powerArea.containsMouse ? Theme.primary : Theme.muted
                }

                MouseArea {
                    id: powerArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: controller.openPowerSystem()
                }
            }

            Item {
                id: batteryWrapper
                implicitWidth: batteryIcon.implicitWidth
                implicitHeight: batteryIcon.implicitHeight
                Layout.alignment: Qt.AlignVCenter

                BatteryIcon {
                    id: batteryIcon
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: batteryArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: controller.openPowerProfile()
                }
            }
        }

        LongToggle {}

        ColumnLayout {
            spacing: Metrics.spacingLG

            ShortToggle {}
            ActionButton {}
        }

        ColumnLayout {
            spacing: Metrics.spacingLG
            Repeater {
                model: [
                    {
                        type: "volume",
                        maxVal: 1.5,
                        minVal: 0.0,
                        getVal: () => VolumeService.volume,
                        setVal: (v) => VolumeService.setVolume(v),
                        getIcon: (pct) => VolumeService.isMuted ? "\ueee8" : VolumeService.getVolumeIcon(pct),
                        isMuted: () => VolumeService.isMuted,
                        hasClickAction: true,
                        onIconClick: () => VolumeService.toggleMute()
                    },
                    {
                        type: "brightness",
                        maxVal: 1.0,
                        minVal: 0.01,
                        getVal: () => BrightnessService.brightness,
                        setVal: (v) => BrightnessService.setBrightness(v),
                        getIcon: (pct) => BrightnessService.getBrightnessIcon(pct),
                        isMuted: () => false,
                        hasClickAction: false,
                        onIconClick: null
                    }
                ]

                delegate: CustomSlider {
                    readonly property var sliderData: modelData

                    value: sliderData.getVal()
                    minVal: sliderData.minVal
                    maxVal: sliderData.maxVal
                    isMuted: sliderData.isMuted()
                    iconText: sliderData.getIcon(percentVal)
                    hasIconClickAction: sliderData.hasClickAction

                    onValueMoved: (newValue) => sliderData.setVal(newValue)
                    onIconClicked: {
                        if (sliderData.hasClickAction && sliderData.onIconClick) {
                            sliderData.onIconClick()
                        }
                    }
                }
            }
        }
    }
}
