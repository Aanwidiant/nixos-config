import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme"

ComboBox {
    id: control

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    // --- CUSTOM PROPERTIES ---
    property var selectedKey: null
    property string keyRole: "id"
    property string defaultText: "Select..."
    property var formatText: null

    // Signal kustom saat item dipilih oleh user
    signal itemActivated(var item, int index)

    Layout.fillWidth: true
    textRole: "description"

    // Helper internal pemformatan teks
    function getItemText(item) {
        if (!item) return ""
        if (formatText && typeof formatText === "function") {
            return formatText(item)
        }
        return item[textRole] ?? ""
    }

    // Helper internal penentuan item terpilih
    function isSelected(item) {
        if (!item || selectedKey === undefined || selectedKey === null) return false
        return item[keyRole] === selectedKey
    }

    // Fungsi sinkronisasi indeks secara aman tanpa merusak binding
    function syncCurrentIndex() {
        if (!model) {
            control.currentIndex = -1
            return
        }

        var targetIndex = -1
        // Model bisa berupa Array JS atau QML ListModel
        var count = model.count !== undefined ? model.count : model.length

        for (var i = 0; i < count; i++) {
            var item = model.get ? model.get(i) : model[i]
            if (isSelected(item)) {
                targetIndex = i
                break
            }
        }
        control.currentIndex = targetIndex
    }

    // Pantau perubahan model atau selectedKey untuk memperbarui indeks
    onModelChanged: syncCurrentIndex()
    onSelectedKeyChanged: syncCurrentIndex()
    Component.onCompleted: syncCurrentIndex()

    // Trigger signal kustom saat item diklik oleh user
    onActivated: function(index) {
        if (!model) return
        var item = model.get ? model.get(index) : model[index]
        control.itemActivated(item, index)
    }

    // --- HEADER TEXT DISPLAY ---
    contentItem: Text {
        leftPadding: Metrics.spacingLG
        rightPadding: control.indicator ? control.indicator.width + Metrics.spacingLG : Metrics.spacing2XL
        topPadding: Metrics.spacingLG
        bottomPadding: Metrics.spacingLG
        text: {
            var activeIndex = control.currentIndex
            if (activeIndex >= 0 && control.model) {
                var item = control.model.get ? control.model.get(activeIndex) : control.model[activeIndex]
                if (item) return control.getItemText(item)
            }
            return control.defaultText
        }
        font.pixelSize: Metrics.textMD
        color: (control.currentIndex >= 0 && control.model) ? Theme.foreground : Theme.muted
        wrapMode: Text.Wrap
        verticalAlignment: Text.AlignVCenter
    }

    // --- DROPDOWN ARROW ---
    indicator: Text {
        x: control.width - width - Metrics.spacingLG
        y: control.topPadding + (control.availableHeight - height) / 2
        text: "\uf107"
        font.family: Theme.iconFont
        font.pixelSize: Metrics.textSM
        color: control.hovered ? Theme.primary : Theme.muted
        verticalAlignment: Text.AlignVCenter
    }

    // --- BACKGROUND ---
    background: Rectangle {
        implicitHeight: Math.max(42, control.contentItem.implicitHeight)
        color: control.hovered ? Qt.alpha(Theme.primary, 0.2) : Theme.surface
        border.color: control.activeFocus ? Theme.primary : Theme.border
        border.width: 1
        radius: Metrics.radiusSM

        Behavior on color { ColorAnimation { duration: Metrics.durationFast } }
    }

    // --- ITEM DELEGATE ---
    delegate: ItemDelegate {
        id: delegate
        // Lebar mengikuti ListView (bukan control) agar tidak ter-clip oleh padding popup
        width: ListView.view.width
        highlighted: control.highlightedIndex === index

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }

        contentItem: Text {
            id: delegateText
            text: control.getItemText(modelData)
            color: control.isSelected(modelData) ? Theme.primary : Theme.foreground
            font.pixelSize: Metrics.textMD
            font.bold: control.isSelected(modelData)
            wrapMode: Text.Wrap
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: (delegate.hovered || delegate.highlighted)
            ? Qt.alpha(Theme.primary, 0.15)
            : "transparent"
            radius: Metrics.radiusXS
        }
    }

    // --- POPUP CONTAINER ---
    popup: Popup {
        y: control.height + Metrics.spacingMD
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: Metrics.spacingMD

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight > 250 ? 250 : contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            // Snap highlight tanpa animasi agar tidak goyang saat hover antar item
            highlightMoveDuration: 0
            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            color: Theme.surface
            border.color: Theme.border
            border.width: 1
            radius: Metrics.radiusSM
        }
    }
}
