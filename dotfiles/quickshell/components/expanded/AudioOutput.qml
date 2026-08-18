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

    function getCleanProfileName(rawText) {
        if (!rawText) return ""
        var start = rawText.indexOf("(")
        var end = rawText.lastIndexOf(")")
        if (start !== -1 && end !== -1 && end > start) {
            return rawText.substring(start + 1, end).trim()
        }
        return rawText
    }

    function getCleanSinkName(rawText) {
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
                text: "Audio Output Setting"
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

        Flickable {
            id: flickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            visible: true
            contentHeight: mainListsColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: mainListsColumn
                width: flickable.width
                spacing: Metrics.spacingLG

                // --- SECTION 2: CARD PROFILE / CONFIGURATION ---
                Text {
                    text: "Configuration"
                    font.pixelSize: Metrics.textMD
                    font.bold: true
                    color: Theme.foreground
                    Layout.fillWidth: true
                }

                CustomComboBox {
                    id: profileComboBox
                    model: VolumeService.profileList
                    keyRole: "key"
                    selectedKey: VolumeService.activeProfileKey
                    defaultText: "No Profile Selected"
                    formatText: function(item) {
                        return root.getCleanProfileName(item.description)
                    }
                    // Menggunakan arrow function agar binding terhubung dengan benar
                    onItemActivated: (item) => {
                        VolumeService.setCardProfile(item.key)
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.border
                }

                Text {
                    text: "Output Device"
                    font.pixelSize: Metrics.textMD
                    font.bold: true
                    color: Theme.foreground
                    Layout.fillWidth: true
                }

                CustomComboBox {
                    id: sinkComboBox
                    model: VolumeService.sinks
                    keyRole: "id"
                    selectedKey: VolumeService.defaultSink ? VolumeService.defaultSink.id : null
                    defaultText: "No Output Device"
                    formatText: function(item) {
                        var desc = item.description
                        var nick = item.properties["node.nick"] ?? item.properties["device.description"]
                        var fullName = (desc && desc !== "") ? desc : (nick ? nick : item.name)
                        return root.getCleanSinkName(fullName)
                    }
                    // Menggunakan arrow function
                    onItemActivated: (item) => {
                        VolumeService.setAudioSink(item)
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.border
                }

                // --- SECTION 3: APPLICATION MIXER ---
                Text {
                    text: "Application Volume"
                    font.pixelSize: Metrics.textMD
                    font.bold: true
                    color: Theme.foreground
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacingLG

                    Text {
                        visible: VolumeService.appLinkTracker.linkGroups.length === 0
                        text: "No active audio streams"
                        color: Theme.muted
                        font.pixelSize: Metrics.textSM
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 10
                    }

                    Repeater {
                        model: VolumeService.appLinkTracker.linkGroups

                        ColumnLayout {
                            id: appMixerEntry
                            required property PwLinkGroup modelData
                            property PwNode appNode: modelData.source
                            Layout.fillWidth: true
                            spacing: Metrics.spacingMD

                            PwObjectTracker {
                                objects: [appMixerEntry.appNode]
                            }

                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                color: Theme.foreground
                                font.pixelSize: Metrics.textMD
                                font.bold: true
                                text: {
                                    if (!appMixerEntry.appNode) return "Unknown Application";
                                    var app = appMixerEntry.appNode.properties["application.name"] ?? (appMixerEntry.appNode.description !== "" ? appMixerEntry.appNode.description : appMixerEntry.appNode.name);
                                    var media = appMixerEntry.appNode.properties["media.name"];
                                    return media ? app + " - " + media : app;
                                }
                            }

                            CustomSlider {
                                Layout.fillWidth: true
                                minVal: 0.0
                                maxVal: 1.5
                                value: appMixerEntry.appNode && appMixerEntry.appNode.audio ? appMixerEntry.appNode.audio.volume : 0.0
                                isMuted: appMixerEntry.appNode && appMixerEntry.appNode.audio ? appMixerEntry.appNode.audio.muted : false
                                hasIconClickAction: true

                                iconText: {
                                    if (!appMixerEntry.appNode || !appMixerEntry.appNode.audio) return VolumeService.getVolumeIcon(0);
                                    if (appMixerEntry.appNode.audio.muted) return VolumeService.getVolumeIcon(0);
                                    var currentPercent = Math.round((appMixerEntry.appNode.audio.volume || 0) * 100);
                                    return VolumeService.getVolumeIcon(currentPercent);
                                }

                                onValueMoved: (newVal) => {
                                    if (appMixerEntry.appNode && appMixerEntry.appNode.audio) {
                                        appMixerEntry.appNode.audio.volume = newVal;
                                    }
                                }

                                onIconClicked: {
                                    if (appMixerEntry.appNode && appMixerEntry.appNode.audio) {
                                        appMixerEntry.appNode.audio.muted = !appMixerEntry.appNode.audio.muted;
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
