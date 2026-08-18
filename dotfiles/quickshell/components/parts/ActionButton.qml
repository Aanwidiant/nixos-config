import QtQuick
import QtQuick.Layouts
import "../../services" 
import "../../theme" 

GridLayout {
    Layout.fillWidth: true
    columns: 5
    rowSpacing: Metrics.spacingLG
    columnSpacing: Metrics.spacingLG

    Repeater {
        model: [
            { actionId: "timer", icon: "\uf520" },
            { actionId: "screenshot", icon: "\udb80\udd04" },
            { actionId: "screenrecord", icon: "\uf03d" },
            { actionId: "colorpicker", icon: "\uf1fb" },
            { actionId: "emoji", icon: "\udb83\udc68" },

            { actionId: "theme", icon: "\udb80\udfd8" },
            { actionId: "bg", icon: "\uf03e" },
            { actionId: "font", icon: "\udb81\uded6" },
            { actionId: "clipboard", icon: "\uf0ea" },
            { actionId: "keybind", icon: "\uea65" }
        ]

        delegate: Item {
            id: actionBtnContainer
            Layout.fillWidth: true
            implicitHeight: 42

            readonly property var btnData: modelData

            Rectangle {
                id: btnBg
                anchors.fill: parent
                radius: height / 2
                color: tapHandler.pressed ? Theme.primary : Theme.surface

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
            }

            Text {
                anchors.centerIn: parent
                text: actionBtnContainer.btnData.icon
                font.family: Theme.iconFont
                font.pixelSize: Metrics.iconLG
                color: tapHandler.pressed ? Theme.background : Theme.foreground

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: parent.height / 2
                color: Theme.foreground
                opacity: hoverHandler.hovered ? 0.08 : 0
                visible: opacity > 0

                Behavior on opacity { 
                    NumberAnimation { duration: 100 } 
                }
            }

            HoverHandler {
                id: hoverHandler
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                id: tapHandler
                onTapped: {
                    switch (actionBtnContainer.btnData.actionId) {
                        case "emoji":
                        controller.openEmoji() 
                        break
                        case "timer":
                        controller.openTimer()
                        break
                        case "screenshot":
                        controller.openScreenshot()
                        break
                        case "screenrecord":
                        controller.openScreenrecord()
                        break
                        case "colorpicker":
                        controller.closeExpandedState(() => {
                            HyprpickerService.pickColor(); 
                        });
                        break
                        case "theme":
                        controller.openTheme()
                        break
                        case "bg":
                        controller.openBackground()
                        break
                        case "font":
                        controller.openFont()
                        break
                        case "clipboard":
                        controller.openClipboard()
                        break
                        case "keybind":
                        controller.openKeybind()
                        break
                    }
                }
            }
        }
    }
}
