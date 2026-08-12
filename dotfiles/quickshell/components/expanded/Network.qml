import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Networking
import "../../services" 
import "../../theme" 
import "../parts"

Item {
    id: root

    implicitWidth: 400
    implicitHeight: 400

    property string selectedSsid: ""
    property string passwordText: ""
    property string errorMessage: ""
    property bool showPassword: false

    Connections {
        target: NetworkService

        function onConnectionFailed(ssid, err) {
            if (root.selectedSsid === ssid) {
                root.errorMessage = err || "Incorrect password or connection failed"
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
                text: "Wi-Fi"
                font.pixelSize: Metrics.textLG
                font.bold: true
                color: Theme.foreground
                Layout.fillWidth: true
            }

            Item {
                implicitWidth: 32
                implicitHeight: 24

                visible: NetworkService.wifiEnabled 
                Layout.preferredWidth: visible ? 32 : 0
                Layout.preferredHeight: visible ? 24 : 0

                Text {
                    id: scanIcon
                    anchors.centerIn: parent
                    text: "\udb81\udc50" 
                    font.family: Theme.iconFont
                    font.pixelSize: Metrics.textXL
                    color: NetworkService.isScanning || refreshBtn.containsMouse ? Theme.primary : Theme.muted

                    rotation: 0

                    RotationAnimation on rotation {
                        running: NetworkService.isScanning
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                    }
                }

                MouseArea {
                    id: refreshBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: NetworkService.wifiEnabled && NetworkService.wifiHardwareEnabled
                    onClicked: NetworkService.scanWifi()
                }
            }

            Switch {
                id: control
                padding: 0
                checked: NetworkService.wifiEnabled
                enabled: NetworkService.wifiHardwareEnabled
                onCheckedChanged: {
                    if (checked !== NetworkService.wifiEnabled) {
                        root.selectedSsid = ""
                        root.errorMessage = ""
                        NetworkService.toggleWifi()
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
            visible: !NetworkService.wifiEnabled

            Column {
                anchors.centerIn: parent
                spacing: Metrics.spacingLG
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\udb82\udd2d" 
                    font.family: Theme.iconFont 
                    font.pixelSize: Metrics.text5XL
                    color: Theme.muted
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Wi-Fi is turned off"
                    color: Theme.muted
                    font.pixelSize: Metrics.textMD
                }
            }
        }

        Flickable {
            id: flickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            visible: NetworkService.wifiEnabled
            contentHeight: mainListsColumn.height
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: mainListsColumn
                width: parent.width
                spacing: Metrics.spacingLG

                Column {
                    id: knownColumn
                    width: parent.width
                    spacing: Metrics.spacingMD

                    Text {
                        text: "Saved Networks"
                        font.pixelSize: Metrics.textSM
                        font.weight: Font.Medium
                        color: Theme.muted
                        bottomPadding: 4
                        visible: knownRepeater.count > 0
                    }

                    Repeater {
                        id: knownRepeater
                        model: NetworkService.wifiNetworksModel
                        property int expandedIndex: -1

                        delegate: Rectangle {
                            id: knownDelegate
                            readonly property var net: modelData
                            readonly property bool isKnown: net ? (net.known === true) : false
                            readonly property bool isExpanded: knownRepeater.expandedIndex === index

                            width: knownColumn.width
                            visible: isKnown
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
                                        text: NetworkService.getWifiIcon(net) 
                                        font.family: Theme.iconFont
                                        font.pixelSize: Metrics.textXL
                                        color: (net && net.connected) ? Theme.primary : Theme.muted
                                    }

                                    Text {
                                        text: net ? (net.ssid || net.name || "Hidden Network") : ""
                                        color: Theme.foreground
                                        font.bold: net && net.connected
                                        font.pixelSize: Metrics.textSM
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true 
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Text {
                                        text: (net && net.connected) ? "Connected" : 
                                        (net && net.stateChanging) ? "Connecting..." : ""
                                        color: (net && net.connected) ? Theme.primary : Theme.muted
                                        font.pixelSize: Metrics.textSM
                                        Layout.alignment: Qt.AlignVCenter
                                        visible: text !== ""
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    visible: knownDelegate.isExpanded
                                    spacing: Metrics.spacingLG

                                    Item { Layout.fillWidth: true }

                                    Button {
                                        id: forgetBtn
                                        onClicked: NetworkService.forgetNetwork(net)
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
                                            color: forgetBtn.hovered ? Theme.secondary : Theme.primary
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
                                                text: "Forget"
                                                font.pixelSize: Metrics.textSM
                                                color: Theme.surface 
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }

                                    Button {
                                        id: connectBtnKnown
                                        onClicked: {
                                            if (!net) return
                                            if (net.connected) NetworkService.disconnectNetwork(net)
                                            else NetworkService.connectToNetwork(net)
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
                                            color: connectBtnKnown.hovered ? Theme.secondary : Theme.primary
                                            radius: Metrics.radiusSM
                                        }

                                        contentItem: Row {
                                            spacing: Metrics.spacingMD
                                            anchors.centerIn: parent 

                                            Text {
                                                text: (net && net.connected) ? "\uf127" : "\uf0c1" 
                                                font.family: Theme.iconFont
                                                font.pixelSize: Metrics.textMD
                                                color: Theme.surface 
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Text {
                                                text: (net && net.connected) ? "Disconnect" : "Connect" 
                                                font.pixelSize: Metrics.textSM
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
                                    if (knownRepeater.expandedIndex === index) {
                                        knownRepeater.expandedIndex = -1
                                    } else {
                                        knownRepeater.expandedIndex = index
                                    }
                                }
                            }
                        }
                    } 
                } 

                // --- AVAILABLE NETWORKS ---
                Column {
                    id: availableColumn
                    width: parent.width
                    spacing: Metrics.spacingMD

                    Text {
                        text: "Available Networks"
                        font.pixelSize: Metrics.textSM
                        font.weight: Font.Medium
                        color: Theme.muted
                        bottomPadding: 4
                    }

                    Repeater {
                        id: availableRepeater
                        model: NetworkService.wifiNetworksModel

                        delegate: Rectangle {
                            id: availableDelegate
                            readonly property var net: modelData
                            readonly property string netSsid: net ? (net.ssid || net.name || "") : ""
                            readonly property bool isNotKnown: net ? (!net.known) : false
                            readonly property bool isEncrypted: net ? (net.securityType !== WifiSecurityType.Open) : false
                            readonly property bool isSelected: root.selectedSsid !== "" && root.selectedSsid === netSsid

                            width: availableColumn.width
                            visible: isNotKnown

                            height: {
                                if (!visible) return 0
                                if (isSelected) {
                                    return (root.errorMessage !== "") ? 120 : 104
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
                                        text:NetworkService.getWifiIcon(net) 
                                        font.family: Theme.iconFont
                                        font.pixelSize: Metrics.textXL
                                        color: Theme.muted
                                    }

                                    Text {
                                        text: availableDelegate.netSsid || "Hidden Network" 
                                        color: Theme.foreground
                                        font.pixelSize: Metrics.textSM
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true 
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Text {
                                        text: (isSelected && root.errorMessage) ? root.errorMessage :
                                        (net && net.stateChanging) ? "Connecting..." : ""
                                        color: (isSelected && root.errorMessage) ? Theme.danger : Theme.muted
                                        font.pixelSize: Metrics.textSM
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

                                    TextField {
                                        id: passInput
                                        Layout.fillWidth: true
                                        placeholderText: "Enter password"
                                        echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                                        font.pixelSize: Metrics.textSM
                                        text: root.passwordText

                                        rightPadding: eyeBtn.width + 12 
                                        leftPadding: 12
                                        topPadding: 8
                                        bottomPadding: 8

                                        onTextChanged: {
                                            root.passwordText = text
                                            if (root.errorMessage !== "") root.errorMessage = ""
                                        }
                                        onAccepted: connectBtn.clicked()

                                        onVisibleChanged: {
                                            if (visible) passInput.forceActiveFocus()
                                        }

                                        background: Rectangle {
                                            color: Theme.surface 
                                            border.color: passInput.activeFocus ? Theme.primary : "transparent"
                                            border.width: 1
                                            radius: Metrics.radiusSM
                                        }

                                        Item {
                                            id: eyeBtn
                                            width: 28
                                            height: parent.height
                                            anchors.right: parent.right
                                            anchors.rightMargin: 6
                                            anchors.verticalCenter: parent.verticalCenter

                                            Text {
                                                anchors.centerIn: parent
                                                text: root.showPassword ? "\uf06e" : "\uf070" 
                                                font.family: Theme.iconFont
                                                font.pixelSize: Metrics.textMD
                                                color: eyeMouseArea.containsMouse 
                                                ? Theme.primary 
                                                : (passInput.text.length > 0 ? Theme.foreground : Theme.muted)
                                            }

                                            MouseArea {
                                                id: eyeMouseArea
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true
                                                onClicked: root.showPassword = !root.showPassword
                                            }
                                        }
                                    }

                                    Button {
                                        id: connectBtn
                                        onClicked: {
                                            if (net) {
                                                root.errorMessage = ""
                                                NetworkService.connectWithPassword(net, root.passwordText)
                                            }
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
                                            color: connectBtn.hovered ? Theme.secondary : Theme.primary
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
                                                text: "Connect" 
                                                font.pixelSize: Metrics.textSM
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
                                    if (!net) return
                                    if (availableDelegate.isEncrypted) {
                                        if (isSelected) {
                                            root.selectedSsid = ""
                                            root.errorMessage = ""
                                            root.showPassword = false
                                        } else {
                                            root.selectedSsid = availableDelegate.netSsid
                                            root.passwordText = ""
                                            root.errorMessage = ""
                                            root.showPassword = false
                                        }
                                    } else {
                                        NetworkService.connectToNetwork(net)
                                    }
                                }
                            }
                        } 
                    }
                }

                Item {
                    width: parent.width
                    height: 80
                    visible: knownRepeater.count === 0 && availableRepeater.count === 0

                    Text {
                        anchors.centerIn: parent
                        text: NetworkService.isScanning ? "Scanning for networks..." : "No networks found."
                        color: Theme.muted
                        font.pixelSize: Metrics.textMD
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
