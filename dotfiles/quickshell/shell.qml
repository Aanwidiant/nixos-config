import Quickshell
import Quickshell.Wayland
import QtQuick
import "modules"
import "services"

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: mainPanel

            property var modelData

            screen: modelData

            readonly property bool isActiveScreen: modelData.name === ScreenService.activeMonitorName

            anchors.top: true
            exclusiveZone: 0 
            color: "transparent"

            implicitWidth: modelData.width * 0.5
            implicitHeight: modelData.height * 0.8

            readonly property string currentState: dynamicIsland.currentState
            readonly property bool isExclusiveFocus: States.isExclusiveFocus(currentState)
            readonly property bool isOnDemandFocus: States.isOnDemandFocus(currentState)

            WlrLayershell.keyboardFocus: {
                if (!mainPanel.isActiveScreen) {
                    return WlrKeyboardFocus.None
                }
                return isExclusiveFocus ? WlrKeyboardFocus.Exclusive :
                isOnDemandFocus ? WlrKeyboardFocus.OnDemand :
                WlrKeyboardFocus.None
            }

            WlrLayershell.layer: WlrLayer.Top

            DynamicIsland {
                id: dynamicIsland
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top

                property bool isMainScreen: mainPanel.isActiveScreen
                property string monitorName: modelData.name
            }

            mask: Region {
                item: (mainPanel.isActiveScreen && dynamicIsland.islandVisible) 
                ? dynamicIsland.islandItem 
                : dynamicIsland.topEdgeTrigger
            }
        }
    }

    Component.onCompleted: {
        IpcService
    }
}
