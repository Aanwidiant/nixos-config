import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"
import "../../services"

Item {
    id: root

    implicitWidth: 360
    implicitHeight: 148

    property bool expanded: false

    Item {
        anchors.fill: parent
        anchors.margins: 16

        RowLayout {
            anchors.fill: parent
            spacing: Metrics.spacingXL

            Rectangle {
                id: albumContainer
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                Layout.alignment: Qt.AlignVCenter
                radius: Metrics.radiusMD
                color: Theme.surface

                Text {
                    anchors.centerIn: parent
                    text: "\uf001"
                    font.pixelSize: Metrics.text5XL
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

                MouseArea {
                    id: mouseClose
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: controller.closeExpandedState()
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
                spacing: Metrics.spacingSM

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.spacingMD

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
                            font.pixelSize: Metrics.textMD
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

                            if (titleText.implicitWidth > titleContainer.width) {
                                titleBounce.start()
                            }
                        }

                        onWidthChanged: updateAnimation()
                        Component.onCompleted: updateAnimation()

                        Connections {
                            target: MprisService
                            function onTrackTitleChanged() { titleContainer.updateAnimation() }
                        }

                        Connections {
                            target: root
                            function onExpandedChanged() {
                                if (root.expanded) {
                                    titleContainer.updateAnimation()
                                } else {
                                    titleBounce.stop()
                                    titleText.x = 0
                                }
                            }
                        }
                    }

                    Text {
                        id: artistText
                        Layout.fillWidth: true
                        text: MprisService.trackArtist
                        color: Theme.muted
                        font.pixelSize: Metrics.textSM
                        elide: Text.ElideRight
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 14

                    Rectangle {
                        id: progressBg
                        anchors.centerIn: parent
                        width: parent.width
                        height: mouseSeek.containsMouse ? 6 : 4
                        radius: height / 2
                        color: Theme.muted
                        Behavior on height { NumberAnimation { duration: 100 } }

                        Rectangle {
                            height: parent.height
                            radius: parent.radius
                            color: Theme.primary 
                            width: {
                                if (MprisService.length > 0) {
                                    let ratio = MprisService.position / MprisService.length;
                                    return parent.width * Math.min(Math.max(ratio, 0), 1);
                                }
                                return 0;
                            }
                        }
                    }

                    MouseArea {
                        id: mouseSeek
                        anchors.fill: parent
                        hoverEnabled: MprisService.canSeek
                        enabled: MprisService.canSeek
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                        function doSeek(mouse) {
                            MprisService.seekToRatio(mouse.x / width);
                        }

                        onClicked: (mouse) => doSeek(mouse)
                        onPositionChanged: (mouse) => {
                            if (pressed) doSeek(mouse);
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: MprisService.formatTime(MprisService.position)
                        color: Theme.muted
                        font.pixelSize: Metrics.textXS
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: MprisService.length > 0 ? MprisService.formatTime(MprisService.length) : "--:--"
                        color: Theme.muted
                        font.pixelSize: Metrics.textXS

                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Metrics.spacingXL

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: Metrics.radiusFull
                        color: MprisService.canGoPrevious ? Theme.surface : Theme.danger

                        Text {
                            anchors.centerIn: parent
                            text: "\udb81\udcae"
                            color: Theme.foreground
                            font.pixelSize: Metrics.textMD
                            font.family: Theme.iconFont
                        }

                        MouseArea {
                            id: mousePrev
                            anchors.fill: parent
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: MprisService.canGoPrevious
                            onClicked: MprisService.previous()
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: Metrics.radiusFull
                        color: Theme.primary 
                        opacity: MprisService.canControl ? 1.0 : 0.5

                        Text {
                            anchors.centerIn: parent
                            text: MprisService.isPlaying ? "\uf04c" : "\uf04b"
                            color: Theme.foreground
                            font.pixelSize: Metrics.textLG
                            font.family: Theme.iconFont
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: MprisService.canControl
                            onClicked: MprisService.togglePlaying()
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: Metrics.radiusFull
                        color: MprisService.canGoNext ? Theme.surface : Theme.danger

                        Text {
                            anchors.centerIn: parent
                            text: "\udb81\udcad"
                            color: Theme.foreground
                            font.pixelSize: Metrics.textMD
                            font.family: Theme.iconFont
                        }

                        MouseArea {
                            id: mouseNext
                            anchors.fill: parent
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: MprisService.canGoNext
                            onClicked: MprisService.next()
                        }
                    }
                }
            }
        }
    }
}
