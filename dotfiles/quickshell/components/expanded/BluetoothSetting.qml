import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
        onActivated: controller.openBluetooth()
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        spacing: Metrics.spacingLG

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacingLG

            BackButton {
                onClicked: controller.openBluetooth() 
            }

            Text {
                text: "Bluetooth Setting"
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
            opacity: 0.3
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacingXL
            visible: BluetoothService.bluetoothEnabled

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Device Name"
                    font.pixelSize: Metrics.textMD
                    font.family: Theme.textFont
                    color: Theme.foreground
                    Layout.alignment: Qt.AlignVCenter
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: BluetoothService.activeAdapter?.name || "Unknown"
                    font.pixelSize: Metrics.textMD
                    font.weight: Font.DemiBold
                    font.family: Theme.textFont
                    color: Theme.primary
                    elide: Text.ElideRight
                    Layout.maximumWidth: 200
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Adapter ID"
                    font.pixelSize: Metrics.textMD
                    font.family: Theme.textFont
                    color: Theme.foreground
                    Layout.alignment: Qt.AlignVCenter
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: BluetoothService.activeAdapter?.adapterId || "Unknown"
                    font.pixelSize: Metrics.textMD
                    font.weight: Font.DemiBold
                    font.family: Theme.textFont
                    color: Theme.primary
                    elide: Text.ElideRight
                    Layout.maximumWidth: 200
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacingSM
                    Text {
                        text: "Pairable"
                        font.pixelSize: Metrics.textMD
                        font.family: Theme.textFont
                        color: Theme.foreground
                    }
                    Text {
                        text: "Allow devices to request pairing"
                        font.pixelSize: Metrics.textSM
                        font.family: Theme.textFont
                        color: Theme.muted
                    }
                }

                Item { Layout.fillWidth: true }

                Switch {
                    id: switchPairable                   
                    checked: BluetoothService.activeAdapter?.pairable || false
                    onCheckedChanged: {
                        if (BluetoothService.activeAdapter && checked !== BluetoothService.activeAdapter.pairable) {
                            BluetoothService.activeAdapter.pairable = checked
                        }
                    }
                    indicator: Rectangle {
                        implicitWidth: 38
                        implicitHeight: 20
                        x: switchPairable.width - width - switchPairable.rightPadding
                        y: parent.height / 2 - height / 2
                        radius: Metrics.radiusFull
                        color: switchPairable.checked ? Theme.primary : Theme.muted

                        Rectangle {
                            x: switchPairable.checked ? parent.width - width : 0
                            width: 20
                            height: 20
                            radius: Metrics.radiusFull
                            color: Theme.foreground
                            border.color: Theme.accent
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: BluetoothService.activeAdapter?.pairable || false

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacingMD
                    Text {
                        text: "Pairable Timeout"
                        font.pixelSize: Metrics.textMD
                        font.family: Theme.textFont
                        color: Theme.foreground
                    }
                    Text {
                        text: "Timeout in seconds (0 = unlimited)"
                        font.pixelSize: Metrics.textSM
                        font.family: Theme.textFont
                        color: Theme.muted
                    }
                }
                Item { Layout.fillWidth: true }
                SpinBox {
                    id: pairableSpin
                    from: 0
                    to: 3600
                    stepSize: 30
                    value: BluetoothService.activeAdapter?.pairableTimeout || 0
                    editable: false

                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 28

                    leftPadding: down.indicator.width
                    rightPadding: up.indicator.width

                    onValueModified: {
                        if (BluetoothService.activeAdapter) {
                            BluetoothService.activeAdapter.pairableTimeout = value
                        }
                    }

                    contentItem: Text {
                        z: 2
                        text: pairableSpin.textFromValue(pairableSpin.value, pairableSpin.locale)
                        font.pixelSize: Metrics.textSM
                        color: Theme.primary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    } 

                    up.indicator: Rectangle {
                        x: pairableSpin.mirrored ? 0 : parent.width - width
                        height: parent.height
                        implicitWidth: 28
                        implicitHeight: 28
                        radius: Metrics.radiusFull
                        color: pairableSpin.up.pressed ? Theme.accent : Theme.primary
                        opacity: pairableSpin.value < pairableSpin.to ? 1.0 : 0.4

                        Text {
                            text: "\uf067"
                            font.pixelSize: Metrics.textLG
                            color: Theme.background
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    down.indicator: Rectangle {
                        x: pairableSpin.mirrored ? parent.width - width : 0
                        height: parent.height
                        implicitWidth: 28
                        implicitHeight: 28
                        radius: Metrics.radiusFull

                        color: pairableSpin.down.pressed ? Theme.accent : Theme.primary
                        opacity: pairableSpin.value > pairableSpin.from ? 1.0 : 0.4

                        Text {
                            text: "\uf068"
                            font.pixelSize: Metrics.textLG
                            color: Theme.background
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    background: Rectangle {
                        implicitWidth: 100
                        implicitHeight: 28
                        radius: Metrics.radiusFull
                        border.color: Theme.primary
                        color: "transparent"
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacingSM
                    Text {
                        text: "Discoverable"
                        font.pixelSize: Metrics.textMD
                        font.family: Theme.textFont
                        color: Theme.foreground
                    }
                    Text {
                        text: "Visible to nearby Bluetooth devices"
                        font.pixelSize: Metrics.textSM
                        font.family: Theme.textFont
                        color: Theme.muted
                    }
                }

                Item { Layout.fillWidth: true }

                Switch {
                    id: switchDiscoverable                    
                    checked: BluetoothService.activeAdapter?.discoverable || false
                    onCheckedChanged: {
                        if (BluetoothService.activeAdapter && checked !== BluetoothService.activeAdapter.discoverable) {
                            BluetoothService.activeAdapter.discoverable = checked
                        }
                    }
                    indicator: Rectangle {
                        implicitWidth: 38
                        implicitHeight: 20
                        x: switchDiscoverable.width - width - switchDiscoverable.rightPadding
                        y: parent.height / 2 - height / 2
                        radius: Metrics.radiusFull
                        color: switchDiscoverable.checked ? Theme.primary : Theme.muted

                        Rectangle {
                            x: switchDiscoverable.checked ? parent.width - width : 0
                            width: 20
                            height: 20
                            radius: Metrics.radiusFull
                            color: Theme.foreground
                            border.color: Theme.accent
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: BluetoothService.activeAdapter?.discoverable || false

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacingMD
                    Text {
                        text: "Discoverable Timeout"
                        font.pixelSize: Metrics.textMD
                        font.family: Theme.textFont
                        color: Theme.foreground
                    }
                    Text {
                        text: "Timeout in seconds (0 = unlimited)"
                        font.pixelSize: Metrics.textSM
                        font.family: Theme.textFont
                        color: Theme.muted
                    }
                }
                Item { Layout.fillWidth: true }

                SpinBox {
                    id: discoverableSpin
                    from: 0
                    to: 3600
                    stepSize: 30
                    value: BluetoothService.activeAdapter?.discoverableTimeout || 0
                    editable: true

                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 28

                    leftPadding: down.indicator.width
                    rightPadding: up.indicator.width

                    onValueModified: {
                        if (BluetoothService.activeAdapter) {
                            BluetoothService.activeAdapter.discoverableTimeout = value
                        }
                    }

                    contentItem: Text {
                        z: 2
                        text: discoverableSpin.textFromValue(discoverableSpin.value, discoverableSpin.locale)
                        font.pixelSize: Metrics.textSM
                        font.family: Theme.textFont
                        color: Theme.primary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    } 

                    up.indicator: Rectangle {
                        x: discoverableSpin.mirrored ? 0 : parent.width - width
                        height: parent.height
                        implicitWidth: 28
                        implicitHeight: 28
                        radius: Metrics.radiusFull
                        color: discoverableSpin.up.pressed ? Theme.accent : Theme.primary
                        opacity: discoverableSpin.value < discoverableSpin.to ? 1.0 : 0.4

                        Text {
                            text: "\uf067"
                            font.pixelSize: Metrics.textLG
                            font.family: Theme.iconFont
                            color: Theme.background
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    down.indicator: Rectangle {
                        x: discoverableSpin.mirrored ? parent.width - width : 0
                        height: parent.height
                        implicitWidth: 28
                        implicitHeight: 28
                        radius: Metrics.radiusFull

                        color: discoverableSpin.down.pressed ? Theme.accent : Theme.primary
                        opacity: discoverableSpin.value > discoverableSpin.from ? 1.0 : 0.4

                        Text {
                            text: "\uf068"
                            font.pixelSize: Metrics.textLG
                            font.family: Theme.iconFont
                            color: Theme.background
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    background: Rectangle {
                        implicitWidth: 100
                        implicitHeight: 28
                        radius: Metrics.radiusFull
                        border.color: Theme.primary
                        color: "transparent"
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
