import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import QtQuick.Effects
import Quickshell.Wayland
import "../../services"
import "../../theme"

Item {
    id: root

    required property LockService service

    Image {
        id: bgImage
        anchors.fill: parent
        source: "file:///home/aanwidiant/.config/theme/current/background"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        visible: false 
    }

    MultiEffect {
        source: bgImage
        anchors.fill: bgImage

        blurEnabled: true
        blurMax: 64
        blur: 1.0
        autoPaddingEnabled: false

        brightness: -0.2
        saturation: 0.8
    }

    Timer {
        id: failureTimer
        interval: 1000
        repeat: false
        onTriggered: {
            root.service.showFailure = false;
            passwordBox.text = "";
            passwordBox.forceActiveFocus();
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Metrics.spacingXL

        Date {
            id: dateText
            Layout.alignment: Qt.AlignHCenter
            customFont: Qt.font({
                pixelSize: Metrics.text3XL,
                weight: Font.Medium,
                family: Theme.textFont
            })
        }

        Clock {
            id: clockText
            Layout.alignment: Qt.AlignHCenter
            customFont: Qt.font({
                pixelSize: 2.5 * Metrics.text5XL,
                weight: Font.Medium,
                family: Theme.textFont
            })
        }

        TextField {
            id: passwordBox

            Layout.alignment: Qt.AlignHCenter

            implicitWidth: 300
            padding: 16
            focus: true
            enabled: !root.service.unlockInProgress && !root.service.showFailure
            font.pixelSize: Metrics.textLG
            font.weight: Font.Medium
            font.family: Theme.textFont

            echoMode: root.service.showFailure ? TextInput.Normal : TextInput.Password
            inputMethodHints: Qt.ImhSensitiveData

            color: root.service.showFailure ? Theme.danger : Theme.foreground
            font.italic: root.service.showFailure

            placeholderText: "Enter Password"

            background: Rectangle {
                color: Theme.background
                radius: Metrics.radiusMD
                border.width: 1.5
                border.color: {
                    if (root.service.showFailure) return Theme.danger;
                    if (passwordBox.activeFocus) return Theme.primary;
                    return Theme.surface;
                }
            }

            onTextChanged: {
                if (!root.service.showFailure) {
                    root.service.currentText = text;
                }
            }

            onAccepted: root.service.tryUnlock()

            Connections {
                target: root.service

                function onShowFailureChanged() {
                    if (root.service.showFailure) {
                        passwordBox.text = "Authentication failed!";
                        failureTimer.restart();
                    }
                }

                function onCurrentTextChanged() {
                    if (!root.service.showFailure) {
                        passwordBox.text = root.service.currentText;
                    }
                }
            }
        }
    }
}
