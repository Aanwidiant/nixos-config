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
            opacity: 0.3
        }

        Text {
            text: "Card Profile"
            font.pixelSize: Metrics.textMD
            font.bold: true
            color: Theme.foreground
        }

        ComboBox {
            id: profileComboBox
            Layout.fillWidth: true
            model: VolumeService.profileList
            textRole: "description"

            currentIndex: {
                if (!model)
                    return -1;
                for (var i = 0; i < model.length; i++) {
                    if (model[i].key === VolumeService.activeProfileKey) {
                        return i;
                    }
                }
                return -1;
            }

            contentItem: Text {
                leftPadding: 10
                rightPadding: 10
                text: profileComboBox.displayText
                font.pixelSize: Metrics.textMD
                color: Theme.foreground
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                implicitHeight: 45
                color: profileComboBox.hovered ? Theme.surfaceHover : Theme.surface
                border.color: Theme.border
                border.width: 1
                radius: 6
            }

            delegate: ItemDelegate {
                id: itemDelegate
                width: profileComboBox.width

                contentItem: Text {
                    text: modelData.description
                    color: modelData.key === VolumeService.activeProfileKey ? Theme.primary : Theme.foreground
                    font.pixelSize: Metrics.textMD
                    font.bold: modelData.key === VolumeService.activeProfileKey
                    wrapMode: Text.WordWrap
                    width: itemDelegate.width - itemDelegate.leftPadding - itemDelegate.rightPadding
                }

                background: Rectangle {
                    color: itemDelegate.hovered ? Theme.surfaceHover : Theme.surface
                }

                onClicked: {
                    if (modelData.key !== VolumeService.activeProfileKey) {
                        VolumeService.setCardProfile(modelData.key);
                    }
                }
            }

            popup: Popup {
                y: profileComboBox.height + 4
                width: profileComboBox.width
                implicitHeight: contentItem.implicitHeight
                padding: 4

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight > 250 ? 250 : contentHeight
                    model: profileComboBox.popup.visible ? profileComboBox.delegateModel : null
                    ScrollIndicator.vertical: ScrollIndicator {}
                }

                background: Rectangle {
                    color: Theme.surface
                    border.color: Theme.border
                    border.width: 1
                    radius: 6
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
            opacity: 0.3
        }

        // --- SECTION 2: APPLICATION MIXER ---
        Text {
            text: "Application Volume"
            font.pixelSize: Metrics.textMD
            font.bold: true
            color: Theme.foreground
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: Metrics.spacingMD

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
                        spacing: Metrics.spacingXS

                        PwObjectTracker {
                            objects: [appMixerEntry.appNode]
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Metrics.spacingSM

                            Image {
                                visible: appMixerEntry.appNode !== null && source != ""
                                sourceSize.width: 20
                                sourceSize.height: 20
                                source: {
                                    if (!appMixerEntry.appNode)
                                        return "";
                                    var icon = appMixerEntry.appNode.properties["application.icon-name"] ?? "audio-x-generic";
                                    return "image://icon/" + icon;
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                color: Theme.foreground
                                font.pixelSize: Metrics.textMD
                                text: {
                                    if (!appMixerEntry.appNode)
                                        return "Unknown Application";
                                    var app = appMixerEntry.appNode.properties["application.name"] ?? (appMixerEntry.appNode.description !== "" ? appMixerEntry.appNode.description : appMixerEntry.appNode.name);
                                    var media = appMixerEntry.appNode.properties["media.name"];
                                    return media ? app + " - " + media : app;
                                }
                            }

                            Rectangle {
                                implicitWidth: 32
                                implicitHeight: 32
                                radius: 6
                                color: appMixerEntry.appNode && appMixerEntry.appNode.audio && appMixerEntry.appNode.audio.muted ? Theme.primary : (appMuteMouse.containsMouse ? Theme.surfaceHover : Theme.surface)

                                Text {
                                    anchors.centerIn: parent
                                    text: appMixerEntry.appNode && appMixerEntry.appNode.audio && appMixerEntry.appNode.audio.muted ? "\uf6a9" : "\uf028"
                                    font.family: Theme.iconFont
                                    font.pixelSize: Metrics.textMD
                                    color: appMixerEntry.appNode && appMixerEntry.appNode.audio && appMixerEntry.appNode.audio.muted ? "#FFFFFF" : Theme.foreground
                                }

                                MouseArea {
                                    id: appMuteMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (appMixerEntry.appNode && appMixerEntry.appNode.audio) {
                                            appMixerEntry.appNode.audio.muted = !appMixerEntry.appNode.audio.muted;
                                        }
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Metrics.spacingSM

                            Text {
                                Layout.preferredWidth: 40
                                color: Theme.muted
                                font.pixelSize: Metrics.textSM
                                text: appMixerEntry.appNode && appMixerEntry.appNode.audio ? Math.round((appMixerEntry.appNode.audio.volume || 0) * 100) + "%" : "0%"
                            }

                            Slider {
                                Layout.fillWidth: true
                                from: 0.0
                                to: 1.0
                                value: appMixerEntry.appNode && appMixerEntry.appNode.audio ? appMixerEntry.appNode.audio.volume : 0.0
                                onValueChanged: {
                                    if (appMixerEntry.appNode && appMixerEntry.appNode.audio && value !== appMixerEntry.appNode.audio.volume) {
                                        appMixerEntry.appNode.audio.volume = value;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
