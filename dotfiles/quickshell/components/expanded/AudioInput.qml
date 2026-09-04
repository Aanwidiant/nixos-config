import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../../services"
import "../../theme"
import "../parts"

Item {
    id: root

    implicitWidth: 400
    implicitHeight: 400

    property string selectedAddress: ""
    property string errorMessage: ""

    function getCleanSourceName(rawText) {
        if (!rawText) return ""
        var target = "(HD Audio) "
        var index = rawText.indexOf(target)
        if (index !== -1) {
            return rawText.substring(index + target.length).trim()
        }
        return rawText
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.visible
        onActivated: controller.openControlCenter()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: Metrics.spacingLG

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacingLG

            BackButton {
                onClicked: controller.openControlCenter()
            }

            Text {
                text: "Audio Input Setting"
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

        Flickable {
            id: flickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentHeight: mainListsColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: mainListsColumn
                width: flickable.width
                spacing: Metrics.spacingLG

                Text {
                    text: "Input Device"
                    font.pixelSize: Metrics.textMD
                    font.bold: true
                    font.family: Theme.textFont
                    color: Theme.foreground
                    Layout.fillWidth: true
                }

                CustomComboBox {
                    id: sourceComboBox
                    model: MicrophoneService.inputDevices
                    keyRole: "id"
                    selectedKey: MicrophoneService.defaultSource ? MicrophoneService.defaultSource.id : null
                    defaultText: "No Input Device"
                    formatText: function(item) {
                        var desc = item.description
                        var nick = item.properties["node.nick"] ?? item.properties["device.description"]
                        var fullName = (desc && desc !== "") ? desc : (nick ? nick : item.name)
                        return root.getCleanSourceName(fullName)
                    }
                    onItemActivated: (item) => {
                        MicrophoneService.setDefaultSource(item)
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.border
                }

                Text {
                    text: "Input Device Levels"
                    font.pixelSize: Metrics.textMD
                    font.bold: true
                    font.family: Theme.textFont
                    color: Theme.foreground
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacingLG

                    Text {
                        visible: MicrophoneService.inputDevices.length === 0
                        text: "No input devices found"
                        color: Theme.muted
                        font.pixelSize: Metrics.textSM
                        font.family: Theme.textFont
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 10
                    }

                    Repeater {
                        model: MicrophoneService.inputDevices

                        ColumnLayout {
                            id: deviceEntry
                            required property PwNode modelData

                            property bool isDefault: MicrophoneService.defaultSource && MicrophoneService.defaultSource.id === modelData.id

                            Layout.fillWidth: true
                            spacing: Metrics.spacingMD

                            PwObjectTracker {
                                objects: [deviceEntry.modelData]
                            }

                            Text {
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                                color: deviceEntry.isDefault ? Theme.primary : Theme.foreground
                                font.pixelSize: Metrics.textMD
                                font.bold: deviceEntry.isDefault
                                font.family: Theme.iconFont
                                text: {
                                    var devNick = deviceEntry.modelData.properties["device.nick"] ?? deviceEntry.modelData.properties["device.description"] ?? "";
                                    var nodeNick = deviceEntry.modelData.properties["node.nick"] ?? deviceEntry.modelData.description ?? deviceEntry.modelData.name;

                                    var label = "";
                                    if (devNick !== "" && nodeNick !== "" && devNick !== nodeNick) {
                                        label = devNick + " (" + nodeNick + ")";
                                    } else {
                                        label = nodeNick !== "" ? nodeNick : devNick;
                                    }

                                    var cleanLabel = root.getCleanSourceName(label)
                                    return (deviceEntry.isDefault ? "\udb82\udccf " : "") + cleanLabel;
                                }
                            }

                            CustomSlider {
                                Layout.fillWidth: true
                                minVal: 0.0
                                maxVal: 1.5
                                value: deviceEntry.modelData && deviceEntry.modelData.audio ? deviceEntry.modelData.audio.volume : 0.0
                                isMuted: deviceEntry.modelData && deviceEntry.modelData.audio ? deviceEntry.modelData.audio.muted : false
                                hasIconClickAction: true

                                iconText: {
                                    if (!deviceEntry.modelData || !deviceEntry.modelData.audio) return "\uf131";
                                    if (deviceEntry.modelData.audio.muted) return "\uf131";
                                    return "\uf130";
                                }

                                onValueMoved: (newVal) => {
                                    if (deviceEntry.modelData && deviceEntry.modelData.audio) {
                                        deviceEntry.modelData.audio.volume = newVal;
                                    }
                                }

                                onIconClicked: {
                                    if (deviceEntry.modelData && deviceEntry.modelData.audio) {
                                        deviceEntry.modelData.audio.muted = !deviceEntry.modelData.audio.muted;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                id: scroll
                active: flickable.moving || scroll.hovered 
                orientation: Qt.Vertical

                rightPadding: 1

                contentItem: Rectangle {
                    implicitWidth: 4
                    implicitHeight: 100
                    radius: Metrics.radiusFull
                    color: Theme.primary
                    opacity: scroll.policy === ScrollBar.AlwaysOn || (scroll.active && scroll.size < 1.0) ? 0.75 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }
                }
            }
        }
    }
}
