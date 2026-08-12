import Quickshell
import QtQuick
import "../../theme"

Text {
    id: root
    property string dateFormat: "dddd, dd MMMM yyyy"
    property int precision: SystemClock.Minutes
    property font customFont: Qt.font({
        pixelSize: Metrics.textSM,
        weight: Font.Normal
    })

    text: Qt.formatDateTime(clock.date, dateFormat)
    color: Theme.foreground
    font: root.customFont

    SystemClock {
        id: clock
        precision: root.precision
    }
}
