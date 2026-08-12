import Quickshell
import QtQuick
import "../../theme"

Text {
    id: root
    property string timeFormat: "hh:mm"
    property int precision: SystemClock.Minutes
    property font customFont: Qt.font({
        pixelSize: Metrics.textSM,
        weight: Font.DemiBold
    })

    text: Qt.formatDateTime(clock.date, timeFormat)
    color: Theme.foreground
    font: root.customFont

    SystemClock {
        id: clock
        precision: root.precision
    }
}
