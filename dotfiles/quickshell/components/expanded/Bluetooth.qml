import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Bluetooth
import "../../services" 
import "../../theme" 
import "../parts"

Item {
    id: root

    implicitWidth: 400
    implicitHeight: 400

    property string selectedAddress: ""
    property string errorMessage: ""

    Connections {
        target: BluetoothService

        function onPairingFailed(address, err) {
            if (root.selectedAddress === address) {
                root.errorMessage = err || "Pairing failed"
            }
        }
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
                text: "Bluetooth"
                font.pixelSize: Metrics.textLG
                font.bold: true
                font.family: Theme.textFont
                color: Theme.foreground
                Layout.fillWidth: true
            }

            Item {
                implicitWidth: 20
                implicitHeight: 24

                visible: BluetoothService.bluetoothEnabled

                Text {
                    id: setting
                    anchors.centerIn: parent
                    text: "\uf013" 
                    font.family: Theme.iconFont
                    font.pixelSize: Metrics.iconMD
                    color: settingBtn.containsMouse ? Theme.primary : Theme.muted
                }

                MouseArea {
                    id: settingBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: controller.openBluetoothSettings()
                }
            }

            Item {
                implicitWidth: 20
                implicitHeight: 24

                visible: BluetoothService.bluetoothEnabled

                Text {
                    id: scanIcon
                    anchors.centerIn: parent
                    text: "\udb81\udc50" 
                    font.family: Theme.iconFont
                    font.pixelSize: Metrics.iconMD
                    color: BluetoothService.isScanning || refreshBtn.containsMouse ? Theme.primary : Theme.muted

                    rotation: 0

                    RotationAnimation on rotation {
                        running: BluetoothService.isScanning
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                    }
                }

                MouseArea {
                    id: refreshBtn
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    enabled: BluetoothService.bluetoothEnabled
                    onClicked: BluetoothService.startDiscovery()
                }
            }

            Switch {
                id: control
                checked: BluetoothService.bluetoothEnabled
                padding: 0
                onCheckedChanged: {
                    if (checked !== BluetoothService.bluetoothEnabled) {
                        root.selectedAddress = ""
                        root.errorMessage = ""
                        BluetoothService.toggleBluetooth()
                    }
                }
                indicator: Rectangle {
                    implicitWidth: 38
                    implicitHeight: 20
                    x: control.width - width - control.rightPadding
                    y: parent.height / 2 - height / 2
                    radius: Metrics.radiusFull
                    color: control.checked ? Theme.primary : Theme.muted

                    Rectangle {
                        x: control.checked ? parent.width - width : 0
                        width: 20
                        height: 20
                        radius: Metrics.radiusFull
                        color: Theme.foreground
                        border.color: Theme.accent
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !BluetoothService.bluetoothEnabled

            Column {
                anchors.centerIn: parent
                spacing: Metrics.spacingLG
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\udb80\udcb2"
                    font.family: Theme.iconFont 
                    font.pixelSize: Metrics.text5XL
                    color: Theme.muted
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Bluetooth is turned off"
                    color: Theme.muted
                    font.pixelSize: Metrics.textMD
                    font.family: Theme.textFont
                }
            }
        }

        Flickable {
            id: flickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            visible: BluetoothService.bluetoothEnabled
            contentHeight: mainListsColumn.height
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: mainListsColumn
                width: parent.width
                spacing: Metrics.spacingLG

                Column {
                    id: pairedColumn
                    width: parent.width
                    spacing: Metrics.spacingMD

                    Text {
                        text: "Paired Devices"
                        font.pixelSize: Metrics.textSM
                        font.weight: Font.Medium
                        font.family: Theme.textFont
                        color: Theme.muted
                        bottomPadding: 4
                        visible: pairedRepeater.count > 0
                    }

                    Repeater {
                        id: pairedRepeater
                        model: BluetoothService.devicesModel
                        property int expandedIndex: -1

                        delegate: Rectangle {
                            id: pairedDelegate
                            readonly property var dev: modelData
                            readonly property bool isPaired: dev ? (dev.paired === true) : false
                            readonly property bool isExpanded: pairedRepeater.expandedIndex === index

                            width: pairedColumn.width
                            visible: isPaired
                            height: visible ? (isExpanded ? 90 : 48) : 0
                            radius: Metrics.radiusMD
                            color: (mouseArea.containsMouse || isExpanded) ? Theme.surface : "transparent"
                            clip: true 

                            Behavior on height {
                                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: Metrics.spacingMD

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    spacing: Metrics.spacingLG 

                                    Text {
                                        text: getBluetoothIcon(dev)
                                        font.family: Theme.iconFont
                                        font.pixelSize: Metrics.textXL
                                        color: (dev && dev.connected) ? Theme.primary : Theme.muted

                                        function getBluetoothIcon(dev) {
                                            if (!dev) return "\udb80\udcaf"

                                            let icon = dev.iconName || ""
                                            if (icon.indexOf("headset") !== -1 || icon.indexOf("audio") !== -1) return "\udb80\udcaf" 
                                            if (icon.indexOf("phone") !== -1) return "\udb80\udcb8" 
                                            if (icon.indexOf("keyboard") !== -1) return "\udb80\udcb3"
                                            if (icon.indexOf("mouse") !== -1) return "\udb80\udcb5"

                                            return "\udb80\udcaf"
                                        }
                                    }

                                    Text {
                                        text: dev ? (dev.alias || dev.name || dev.address || "Unknown Device") : ""
                                        color: Theme.foreground
                                        font.bold: dev && dev.connected
                                        font.pixelSize: Metrics.textSM
                                        font.family: Theme.textFont
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true 
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Text {
                                        text: (dev && dev.connected) ? "Connected" : 
                                        (dev && dev.connecting) ? "Connecting..." : ""
                                        color: (dev && dev.connected) ? Theme.primary : Theme.muted
                                        font.pixelSize: Metrics.textSM
                                        font.family: Theme.textFont
                                        Layout.alignment: Qt.AlignVCenter
                                        visible: text !== ""
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    visible: pairedDelegate.isExpanded
                                    spacing: Metrics.spacingLG

                                    Item { Layout.fillWidth: true }

                                    Button {
                                        id: unpairBtn
                                        onClicked: BluetoothService.unpairDevice(dev)
                                        leftPadding: 14
                                        rightPadding: 14
                                        topPadding: 6
                                        bottomPadding: 6

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: parent.clicked()
                                        }

                                        background: Rectangle {
                                            color: unpairBtn.hovered ? Theme.secondary : Theme.primary
                                            radius: Metrics.radiusSM
                                        }

                                        contentItem: Row {
                                            spacing: Metrics.spacingMD
                                            anchors.centerIn: parent 

                                            Text {
                                                text: "\uf1f8"
                                                font.family: Theme.iconFont
                                                font.pixelSize: Metrics.textMD
                                                color: Theme.surface 
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Text {
                                                text: "Unpair"
                                                font.pixelSize: Metrics.textSM
                                                font.family: Theme.textFont
                                                color: Theme.surface 
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }

                                    Button {
                                        id: connectBtnPaired
                                        onClicked: {
                                            if (!dev) return
                                            if (dev.connected) BluetoothService.disconnectDevice(dev)
                                            else BluetoothService.connectDevice(dev)
                                        }

                                        leftPadding: 14
                                        rightPadding: 14
                                        topPadding: 6
                                        bottomPadding: 6

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: parent.clicked()
                                        }

                                        background: Rectangle {
                                            color: connectBtnPaired.hovered ? Theme.secondary : Theme.primary
                                            radius: Metrics.radiusSM
                                        }

                                        contentItem: Row {
                                            spacing: Metrics.spacingMD
                                            anchors.centerIn: parent 

                                            Text {
                                                text: (dev && dev.connected) ? "\uf127" : "\uf0c1" 
                                                font.family: Theme.iconFont
                                                font.pixelSize: Metrics.textMD
                                                color: Theme.surface 
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Text {
                                                text: (dev && dev.connected) ? "Disconnect" : "Connect" 
                                                font.pixelSize: Metrics.textSM
                                                font.family: Theme.textFont
                                                color: Theme.surface 
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                z: -1 
                                onClicked: {
                                    if (pairedRepeater.expandedIndex === index) {
                                        pairedRepeater.expandedIndex = -1
                                    } else {
                                        pairedRepeater.expandedIndex = index
                                    }
                                }
                            }
                        }
                    } 
                } 

                Column {
                    id: availableColumn
                    width: parent.width
                    spacing: Metrics.spacingMD

                    Text {
                        text: "Available Devices"
                        font.pixelSize: Metrics.textSM
                        font.weight: Font.Medium
                        font.family: Theme.textFont
                        color: Theme.muted
                        bottomPadding: 4
                    }

                    Repeater {
                        id: availableRepeater
                        model: BluetoothService.devicesModel

                        delegate: Rectangle {
                            id: availableDelegate
                            readonly property var dev: modelData
                            readonly property string devAddress: dev ? (dev.address || "") : ""
                            readonly property bool isNotPaired: dev ? (!dev.paired) : false
                            readonly property bool isSelected: root.selectedAddress !== "" && root.selectedAddress === devAddress

                            width: availableColumn.width
                            visible: isNotPaired

                            height: {
                                if (!visible) return 0
                                if (isSelected) {
                                    return (root.errorMessage !== "") ? 120 : 90
                                }
                                return 48
                            }
                            radius: Metrics.radiusMD
                            color: (availableMouseArea.containsMouse || isSelected) ? Theme.surface : "transparent"
                            clip: true

                            Behavior on height {
                                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: Metrics.spacingMD
                                visible: availableDelegate.visible

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    spacing: Metrics.spacingLG 

                                    Text {
                                        text: "\udb80\udcaf"
                                        font.family: Theme.iconFont
                                        font.pixelSize: Metrics.textXL
                                        color: Theme.muted
                                    }

                                    Text {
                                        text: dev ? (dev.alias || dev.name || dev.address || "Unknown Device") : "Unknown Device"
                                        color: Theme.foreground
                                        font.pixelSize: Metrics.textSM
                                        font.family: Theme.textFont
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true 
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Text {
                                        text: (isSelected && root.errorMessage) ? root.errorMessage :
                                        (dev && dev.connecting) ? "Pairing..." : ""
                                        color: (isSelected && root.errorMessage) ? Theme.danger : Theme.muted
                                        font.pixelSize: Metrics.textSM
                                        font.family: Theme.textFont
                                        Layout.alignment: Qt.AlignVCenter
                                        elide: Text.ElideRight
                                        visible: text !== ""
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    visible: isSelected 
                                    spacing: Metrics.spacingLG

                                    Item { Layout.fillWidth: true }

                                    Button {
                                        id: pairBtn
                                        onClicked: {
                                            if (!dev) return
                                            BluetoothService.pairDevice(dev)
                                        }

                                        leftPadding: 14
                                        rightPadding: 14
                                        topPadding: 6
                                        bottomPadding: 6

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: parent.clicked()
                                        }

                                        background: Rectangle {
                                            color: pairBtn.hovered ? Theme.secondary : Theme.primary
                                            radius: Metrics.radiusSM
                                        }

                                        contentItem: Row {
                                            spacing: Metrics.spacingMD
                                            anchors.centerIn: parent

                                            Text {
                                                text: "\uf0c1" 
                                                font.family: Theme.iconFont
                                                font.pixelSize: Metrics.textMD
                                                color: Theme.surface
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Text {
                                                text: "Pair"
                                                font.pixelSize: Metrics.textSM
                                                font.family: Theme.textFont
                                                color: Theme.surface
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: availableMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                z: -1
                                onClicked: {
                                    if (root.selectedAddress === availableDelegate.devAddress) {
                                        root.selectedAddress = ""
                                    } else {
                                        root.selectedAddress = availableDelegate.devAddress
                                        root.errorMessage = ""
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
