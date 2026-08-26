import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import "../../theme"
import "../../services"
import "../parts"

Item {
    id: root

    implicitWidth: 156
    implicitHeight: 36

    readonly property bool isCavaVisible: SwipeView.isCurrentItem

    onIsCavaVisibleChanged: titleContainer.updateAnimation()

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        spacing: Metrics.spacingLG

        Rectangle {
            id: albumContainer
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignVCenter
            radius: Metrics.radius2XS
            color: Theme.surface

            Text {
                anchors.centerIn: parent
                text: "\uf001"
                font.pixelSize: Metrics.textMD
                font.family: Theme.iconFont
                color: Theme.primary
                visible: imageArt.status !== Image.Ready
            }

            Image {
                id: imageArt
                anchors.fill: parent
                source: MprisService.albumArtUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                visible: status === Image.Ready

                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: ShaderEffectSource {
                        sourceItem: Rectangle {
                            width: albumContainer.width
                            height: albumContainer.height
                            radius: albumContainer.radius
                        }
                    }
                }
            }
        }

        Item {
            id: titleContainer
            Layout.fillWidth: true
            height: titleText.implicitHeight
            clip: true

            Text {
                id: titleText
                x: 0
                text: MprisService.trackTitle
                color: Theme.foreground
                font.pixelSize: Metrics.textXS
                font.bold: true
            }

            SequentialAnimation {
                id: titleBounce
                loops: Animation.Infinite
                running: false

                NumberAnimation {
                    target: titleText
                    property: "x"
                    to: titleContainer.width - titleText.implicitWidth
                    duration: Math.max((titleText.implicitWidth - titleContainer.width) * 35, 1000)
                    easing.type: Easing.InOutQuad
                }

                PauseAnimation { duration: 1200 }

                NumberAnimation {
                    target: titleText
                    property: "x"
                    to: 0
                    duration: Math.max((titleText.implicitWidth - titleContainer.width) * 35, 1000)
                    easing.type: Easing.InOutQuad
                }

                PauseAnimation { duration: 1200 }
            }

            function updateAnimation() {
                titleBounce.stop()
                titleText.x = 0

                if (root.isCavaVisible && titleText.implicitWidth > titleContainer.width) {
                    titleBounce.start()
                }
            }

            onWidthChanged: updateAnimation()
            Component.onCompleted: updateAnimation()

            Connections {
                target: MprisService
                function onTrackTitleChanged() { titleContainer.updateAnimation() }
            }
        }

        CavaVisualizer {
            id: visualizer
            running: root.isCavaVisible
            isVisible: root.isCavaVisible

            barCount: 6
            barWidth: 2
            barSpacing: 2
            minHeight: 1
            maxHeight: 16
            barColor: Theme.primary
        }
    }

    HoverHandler { cursorShape: Qt.PointingHandCursor }

    TapHandler {
        onTapped: controller.openMusicDetails()
    }
}
