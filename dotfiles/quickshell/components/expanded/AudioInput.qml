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
                text: "Audio Input Setting"
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
            text: "Input Devices (Microphones)"
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
                spacing: Metrics.spacingLG

                Text {
                    visible: MicrophoneService.inputDevices.length === 0
                    text: "No input devices found"
                    color: Theme.muted
                    font.pixelSize: Metrics.textSM
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                }

                Repeater {
                    model: MicrophoneService.inputDevices

                    ColumnLayout {
                        id: deviceEntry
                        required property PwNode modelData

                        // Mengecek apakah node ini merupakan default audio source yang aktif
                        property bool isDefault: MicrophoneService.defaultSource && MicrophoneService.defaultSource.id === modelData.id

                        Layout.fillWidth: true
                        spacing: Metrics.spacingXS

                        PwObjectTracker {
                            objects: [deviceEntry.modelData]
                        }

                        // Baris Informasi: Device Nick/Name di kiri, Port Description di kanan
                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: {
                                    var devNick = deviceEntry.modelData.properties["device.nick"] ?? deviceEntry.modelData.properties["device.description"] ?? "";
                                    var nodeNick = deviceEntry.modelData.properties["node.nick"] ?? deviceEntry.modelData.description ?? deviceEntry.modelData.name;

                                    // Jika ada deskripsi card dan node, gabungkan agar nama Port (Digital/Stereo) terlihat
                                    if (devNick !== "" && nodeNick !== "" && devNick !== nodeNick) {
                                        return (deviceEntry.isDefault ? "◇ " : "  ") + devNick + " (" + nodeNick + ")";
                                    }
                                    return (deviceEntry.isDefault ? "◇ " : "  ") + (nodeNick !== "" ? nodeNick : devNick);
                                }
                                color: deviceEntry.isDefault ? Theme.primary : Theme.foreground
                                font.pixelSize: Metrics.textMD
                                font.bold: deviceEntry.isDefault
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: deviceEntry.modelData.description !== "" ? deviceEntry.modelData.description : (deviceEntry.modelData.properties["node.nick"] ?? "")
                                color: Theme.muted
                                font.pixelSize: Metrics.textSM
                            }
                        }

                        // Baris Kontrol Volume Slider & Tombol Mute/Select Default
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Metrics.spacingSM

                            Text {
                                Layout.preferredWidth: 40
                                color: Theme.muted
                                font.pixelSize: Metrics.textSM
                                text: deviceEntry.modelData.audio ? Math.round((deviceEntry.modelData.audio.volume || 0) * 100) + "%" : "0%"
                            }

                            Slider {
                                Layout.fillWidth: true
                                from: 0.0
                                to: 1.0
                                value: deviceEntry.modelData.audio ? deviceEntry.modelData.audio.volume : 0.0
                                onValueChanged: {
                                    if (deviceEntry.modelData.audio && value !== deviceEntry.modelData.audio.volume) {
                                        deviceEntry.modelData.audio.volume = value;
                                    }
                                }
                            }

                            Rectangle {
                                implicitWidth: 32
                                implicitHeight: 32
                                radius: 6
                                color: deviceEntry.modelData.audio && deviceEntry.modelData.audio.muted ? Theme.primary : (muteMouse.containsMouse ? Theme.surfaceHover : Theme.surface)

                                Text {
                                    anchors.centerIn: parent
                                    text: "\uf130"
                                    font.family: Theme.iconFont
                                    font.pixelSize: Metrics.textMD
                                    color: deviceEntry.modelData.audio && deviceEntry.modelData.audio.muted ? "#FFFFFF" : Theme.foreground
                                }

                                MouseArea {
                                    id: muteMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        // Set sebagai default source jika belum aktif
                                        if (!deviceEntry.isDefault) {
                                            MicrophoneService.setDefaultSource(deviceEntry.modelData);
                                        } else if (deviceEntry.modelData.audio) {
                                            // Toggle Mute jika sudah menjadi default device
                                            deviceEntry.modelData.audio.muted = !deviceEntry.modelData.audio.muted;
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
}
