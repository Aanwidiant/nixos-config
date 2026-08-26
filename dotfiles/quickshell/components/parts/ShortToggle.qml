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
        model: ListModel {
            id: quickTogglesModel
            ListElement { toggleId: "nightlight"; iconOn: "\udb83\udf65"; iconOff: "\udb83\udf65" }
            ListElement { toggleId: "trackpad"; iconOn: "\udb82\udd33"; iconOff: "\udb81\udff8" }
            ListElement { toggleId: "idle"; iconOn: "\udb86\udc66"; iconOff: "\udb85\udc53" }
            ListElement { toggleId: "dnd"; iconOn: "\udb80\udc9b"; iconOff: "\udb80\udc9a" }
            ListElement { toggleId: "airplane"; iconOn: "\uf072"; iconOff: "\uf072" }
        }

        delegate: Item {
            id: toggleContainer
            Layout.fillWidth: true
            implicitHeight: 42

            property bool isActive: {
                switch (model.toggleId) {
                    case "nightlight": return NightLightService.isNightLightActive
                    case "trackpad": return !TouchpadService.isTouchpadActive
                    case "idle": return !IdleService.isIdleActive
                    case "dnd": return NotificationService.isDndActive
                    case "airplane": return AirplaneService.isAirplaneActive
                    default: return false
                }
            }

            Rectangle {
                id: pillBg
                anchors.fill: parent
                radius: height / 2
                color: toggleContainer.isActive ? Theme.primary : Theme.surface

                Behavior on color { 
                    ColorAnimation { duration: 150 } 
                }
            }

            Text {
                anchors.centerIn: parent
                text: toggleContainer.isActive ? model.iconOn : model.iconOff
                font.family: Theme.iconFont
                font.pixelSize: Metrics.iconLG
                color: toggleContainer.isActive ? Theme.background : Theme.foreground

                Behavior on color { 
                    ColorAnimation { duration: 150 } 
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
                onTapped: {
                    toggleContainer.isActive = !toggleContainer.isActive

                    switch (model.toggleId) {
                        case "nightlight":
                        NightLightService.toggle()
                        break
                        case "trackpad":
                        TouchpadService.toggle()
                        break
                        case "idle":
                        IdleService.toggle()
                        break
                        case "dnd":
                        NotificationService.toggleDnd()
                        break
                        case "airplane":
                        AirplaneService.toggle()
                        break
                    }
                }
            }
        }
    }
}
