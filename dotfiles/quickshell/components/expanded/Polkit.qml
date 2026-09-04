import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../services"

Item {
    id: polkitContent
    implicitWidth: 480
    implicitHeight: 190

    readonly property var service: PolkitService
    readonly property string message: service.message
    readonly property string iconName: service.iconName
    readonly property string supplementaryMessage: service.supplementaryMessage
    readonly property bool isError: service.isError
    readonly property bool isProcessing: service.isProcessing

    readonly property bool isLocked: isProcessing

    Shortcut {
        sequence: "Escape"
        enabled: polkitContent.visible && !polkitContent.isLocked
        onActivated: polkitContent.userCancel()
    }

    function confirmAuth() {
        if (isLocked) return

        var password = passwordInput.text
        if (password.length === 0) {
            supplementaryText.color = Theme.danger
            supplementaryText.text = "Password cannot be empty"
            return
        }

        service.submitPassword(password)
    }

    function userCancel() {
        if (isLocked) return
        service.cancelRequest()
        resetUI()
        controller.closeExpandedState()
    }

    function resetUI() {
        passwordInput.text = ""
        supplementaryText.text = ""
        supplementaryText.color = Theme.secondary

        if (polkitContent.visible) {
            Qt.callLater(claimFocus)
        }
    }

    function claimFocus() {
        if (visible && passwordInput.enabled) {
            passwordInput.forceActiveFocus()
        }
    }

    onVisibleChanged: {
        if (visible) {
            Qt.callLater(claimFocus)
        } else {
            resetUI()
        }
    }

    onIsProcessingChanged: {
        if (isProcessing) {
            supplementaryText.text = "Authenticating..."
            supplementaryText.color = Theme.primary
        } else {
            if (isError) {
                supplementaryText.text = supplementaryMessage !== "" ? supplementaryMessage : "Incorrect password, please try again."
                supplementaryText.color = Theme.danger

                Qt.callLater(function() {
                    passwordInput.forceActiveFocus()
                    passwordInput.selectAll()
                })
            } else if (!isError && supplementaryMessage === "") {
                supplementaryText.text = ""
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: Metrics.spacingLG

        RowLayout {
            spacing: Metrics.spacingLG
            Layout.fillWidth: true

            Text {
                text: "\uf084"
                color: Theme.foreground
                font.pixelSize: Metrics.iconMD
                font.family: Theme.iconFont
                Layout.alignment: Qt.AlignVCenter
            }
            Text {
                text: "Authentication Required"
                color: Theme.foreground
                font {
                    pixelSize: Metrics.textMD
                    weight: Font.Bold
                    family: Theme.textFont
                }
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }
        }

        Text {
            text: polkitContent.message || "Application requesting admin privileges"
            color: Theme.muted
            font {
                pixelSize: Metrics.textSM
                weight: Font.Medium
                family: Theme.textFont
            }
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            color: Theme.surface
            radius: Metrics.radiusSM
            border.color: passwordInput.activeFocus ? Theme.primary : Theme.muted
            border.width: passwordInput.activeFocus ? 2 : 1
            clip: true
            opacity: passwordInput.enabled ? 1.0 : 0.6

            TextInput {
                id: passwordInput
                echoMode: TextInput.Password
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: Text.AlignVCenter
                color: Theme.foreground
                font.pixelSize: Metrics.textSM
                font.family: Theme.textFont
                enabled: !polkitContent.isLocked
                clip: true
                maximumLength: 128
                cursorPosition: text.length

                HoverHandler {
                    cursorShape: passwordInput.enabled ? Qt.IBeamCursor : Qt.ArrowCursor
                }

                TapHandler {
                    enabled: passwordInput.enabled
                    onTapped: passwordInput.forceActiveFocus()
                }

                Text {
                    text: "Enter password..."
                    color: Theme.muted
                    font.pixelSize: Metrics.textSM
                    font.family: Theme.textFont
                    visible: parent.text.length === 0 && !parent.activeFocus
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                }

                onAccepted: {
                    polkitContent.confirmAuth()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 4
            spacing: 12

            Text {
                id: supplementaryText
                text: ""
                color: Theme.danger
                font.pixelSize: Metrics.textSM
                font.family: Theme.textFont
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                visible: text !== ""
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                visible: supplementaryText.text === ""
            }

            Rectangle {
                id: cancelBtn
                implicitWidth: 72
                implicitHeight: 36
                color: Theme.surface
                radius: Metrics.radiusSM
                enabled: !polkitContent.isLocked
                opacity: enabled ? (cancelHover.hovered ? 0.9 : 1.0) : 0.5

                Behavior on opacity {
                    NumberAnimation { duration: 100 }
                }

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    color: Theme.foreground
                    font {
                        pixelSize: Metrics.textSM
                        weight: Font.DemiBold
                        family: Theme.textFont
                    }
                }

                HoverHandler {
                    id: cancelHover
                    cursorShape: cancelBtn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                }

                TapHandler {
                    enabled: cancelBtn.enabled
                    onTapped: polkitContent.userCancel()
                }
            }

            Rectangle {
                id: confirmBtn
                implicitWidth: 120
                implicitHeight: 36
                color: Theme.primary
                radius: Metrics.radiusSM
                enabled: !polkitContent.isLocked
                opacity: enabled ? (confirmHover.hovered ? 0.9 : 1.0) : 0.5

                Behavior on opacity {
                    NumberAnimation { duration: 100 }
                }

                Text {
                    anchors.centerIn: parent
                    text: "Authenticate"
                    color: Theme.background
                    font {
                        pixelSize: Metrics.textSM
                        weight: Font.DemiBold
                        family: Theme.textFont
                    }
                }

                HoverHandler {
                    id: confirmHover
                    cursorShape: confirmBtn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                }

                TapHandler {
                    enabled: confirmBtn.enabled
                    onTapped: polkitContent.confirmAuth()
                }
            }
        }
    }
}
