import QtQuick
import QtQuick.Layouts
import "../../services" 
import "../../theme" 

GridLayout {
    Layout.fillWidth: true
    columns: 2
    rowSpacing: Metrics.spacingLG
    columnSpacing: Metrics.spacingLG

    Repeater {
        model: ListModel {
            id: controlButtonsModel
            ListElement { btnId: "wifi"; title: "Wi-Fi"; subtitle: "Active"; iconOn: "\udb82\udd28"; iconOff: "\udb82\udd2e" }
            ListElement { btnId: "bluetooth"; title: "Bluetooth"; subtitle: "Active"; iconOn: "\udb80\udcaf"; iconOff: "\udb80\udcb2" }
            ListElement { btnId: "audio"; title: "Audio"; subtitle: "Active"; iconOn: "\uf028"; iconOff: "\ueee8" }
            ListElement { btnId: "mic"; title: "Microphone"; subtitle: "Active"; iconOn: "\udb80\udf6c"; iconOff: "\udb80\udf6d" }
        }

        delegate: Item {
            id: btnContainer

            Layout.fillWidth: true
            implicitHeight: 48

            readonly property bool checked: {
                switch (model.btnId) {
                    case "wifi":
                    return NetworkService.wifiEnabled 
                    case "bluetooth":
                    return BluetoothService.bluetoothEnabled
                    case "audio":
                    return !VolumeService.muted
                    case "mic":
                    return !MicrophoneService.muted
                    default:
                    return false
                }
            }

            function getIcon() {
                if (model.btnId === "wifi" && btnContainer.checked) {
                    return NetworkService.activeWifiIcon(model.iconOn) ?? model.iconOff
                } else if (model.btnId === "audio" && btnContainer.checked) {
                    let pct = Math.round((VolumeService.volume / 1.0) * 100) 
                    return VolumeService.getVolumeIcon(pct) ?? model.iconOn 
                }
                return btnContainer.checked ? model.iconOn : model.iconOff
            }

            function getSubtitle() {
                if (model.btnId === "wifi") {
                    return NetworkService.getConnectedWifiName() ?? model.subtitle
                }
                return model.subtitle
            }

            Rectangle {
                id: mainBg
                anchors.fill: parent
                radius: Metrics.radiusFull
                color: btnContainer.checked ? Theme.primary : Theme.surface

                Behavior on color { 
                    ColorAnimation { duration: 150 } 
                }
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 8 
                        spacing: Metrics.spacingLG

                        Text {
                            text: btnContainer.getIcon()
                            font.family: Theme.iconFont
                            font.pixelSize: Metrics.iconXL
                            color: btnContainer.checked ? Theme.background : Theme.foreground
                            verticalAlignment: Text.AlignVCenter
                            Layout.preferredWidth: 32
                        }

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: model.title 
                                font.pixelSize: Metrics.textSM
                                font.bold: true
                                color: btnContainer.checked ? Theme.background : Theme.foreground
                                verticalAlignment: Text.AlignVCenter
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: btnContainer.getSubtitle()
                                font.pixelSize: Metrics.textXS
                                color: btnContainer.checked ? Theme.background : Theme.foreground
                                opacity: 0.8
                                verticalAlignment: Text.AlignVCenter
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                visible: btnContainer.checked
                            }
                        }
                    }

                    HoverHandler { cursorShape: Qt.PointingHandCursor }

                    TapHandler {
                        onTapped: {
                            switch (model.btnId) {
                                case "wifi":
                                NetworkService.toggleWifi()
                                break
                                case "bluetooth":
                                BluetoothService.toggleBluetooth()
                                break
                                case "audio":
                                VolumeService.toggleMute()
                                break
                                case "mic":
                                MicrophoneService.toggleMute()
                                break
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1.5
                    Layout.fillHeight: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                    color: btnContainer.checked ? Theme.background : Theme.foreground
                    opacity: 0.15
                }

                Item {
                    Layout.preferredWidth: 36
                    Layout.fillHeight: true

                    Text {
                        anchors.centerIn: parent
                        text: "\uf054"
                        font.family: Theme.iconFont
                        font.pixelSize: Metrics.iconSM
                        color: btnContainer.checked ? Theme.background : Theme.foreground
                    }

                    HoverHandler { cursorShape: Qt.PointingHandCursor }

                    TapHandler {
                        onTapped: {
                            switch (model.btnId) {
                                case "wifi":
                                controller.openNetwork() 
                                break
                                case "bluetooth":
                                controller.openBluetooth() 
                                break
                                case "audio":
                                controller.openAudioOutput()
                                break
                                case "mic":
                                controller.openAudioInput()
                                break
                            }
                        }
                    }
                }
            }
        }
    }
}
