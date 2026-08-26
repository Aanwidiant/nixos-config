import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../theme"

Item {
    id: root

    implicitWidth: 156
    implicitHeight: 36

    readonly property bool isTimerActive: TimerService.tmRunning || TimerService.tmRemaining > 0
    readonly property bool isSwActive: TimerService.swRunning || TimerService.swSeconds > 0
    readonly property bool isActive: isTimerActive || isSwActive

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        spacing: Metrics.spacingLG

        RowLayout {
            id: timerRow
            spacing: Metrics.spacingLG 

            Text {
                id: mainIcon
                Layout.alignment: Qt.AlignVCenter

                text: root.isSwActive ? "\uf520" : "\udb81\udd1b"

                font.pixelSize: Metrics.iconSM
                font.family: Theme.iconFont
                color: root.isActive ? Theme.primary :  Theme.foreground

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                text: {
                    if (TimerService.tmRemaining > 0) return TimerService.tmFormatted;
                    if (TimerService.swSeconds > 0) return TimerService.swFormatted;
                    return "Stopwatch";
                }

                font.pixelSize: Metrics.textSM
                font.bold: root.isActive
                color: root.isActive ? Theme.primary : Theme.foreground
                elide: Text.ElideRight

                verticalAlignment: Text.AlignVCenter
            }

            HoverHandler { cursorShape: Qt.PointingHandCursor }

            TapHandler {
                onTapped: controller.openTimer()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: Metrics.spacingLG

            Text {
                id: playPauseBtn
                Layout.alignment: Qt.AlignVCenter
                text: {
                    if (TimerService.tmRemaining > 0) return TimerService.tmRunning ? "\uf04c" : "\uf04b";
                    if (TimerService.swSeconds > 0) return TimerService.swRunning ? "\uf04c" : "\uf04b";
                    return "\uf04b";
                }
                font.pixelSize: Metrics.iconSM
                font.family: Theme.iconFont
                color: Theme.foreground

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter

                HoverHandler { cursorShape: Qt.PointingHandCursor }

                TapHandler {
                    onTapped: {
                        if (TimerService.tmRemaining > 0) {
                            TimerService.tmToggle();
                        } else if (TimerService.swSeconds > 0) {
                            TimerService.swToggle();
                        } else {
                            TimerService.swToggle();
                        }
                    }
                }
            }

            Text {
                id: resetBtn
                Layout.alignment: Qt.AlignVCenter
                text: "\uead2"
                font.pixelSize: Metrics.iconSM
                font.family: Theme.iconFont

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter

                readonly property bool canReset: {
                    if (TimerService.tmRemaining > 0) return !TimerService.tmRunning;
                    if (TimerService.swSeconds > 0) return TimerService.swCanReset;
                    return false;
                }

                color: canReset ?  Theme.foreground : Qt.alpha(Theme.foreground, 0.5)

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                HoverHandler {
                    cursorShape: resetBtn.canReset ? Qt.PointingHandCursor : Qt.ArrowCursor
                }

                TapHandler {
                    enabled: resetBtn.canReset
                    onTapped: {
                        if (TimerService.tmRemaining > 0) {
                            TimerService.tmReset();
                        } else if (TimerService.swSeconds > 0) {
                            TimerService.swReset();
                        }
                    }
                }
            }
        }
    }
}
