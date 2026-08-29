import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "./theme"

ShellRoot {

    property string currentUser: Quickshell.env("USER") || "Guest"

    Instantiator {
        model: Quickshell.screens

        PanelWindow {
            id: watermark

            screen: modelData

            anchors {
                right: true
                bottom: true
            }

            margins {
                right: 72
                bottom: 48
            }

            implicitWidth: content.width
            implicitHeight: content.height

            color: "transparent"

            mask: Region {}

            WlrLayershell.layer: WlrLayer.Overlay

            Text {
                id: content
                text: currentUser + "."
                color: Qt.alpha(Theme.foreground, 0.5)
                font.pixelSize: Metrics.textLG
                font.weight: Font.Regular
                font.family: Theme.iconFont
                font.italic: true
            }
        }
    }
}
