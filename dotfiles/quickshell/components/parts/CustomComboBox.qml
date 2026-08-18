import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme"

ComboBox {
    id: control

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
        leftPadding: 10
        rightPadding: 30 
        topPadding: 8
        bottomPadding: 8
        text: {
            var activeIndex = control.currentIndex
            if (activeIndex >= 0 && control.model) {
                var item = control.model.get ? control.model.get(activeIndex) : control.model[activeIndex]
                if (item) return control.getItemText(item)
            }
            return control.defaultText
        }
        font.pixelSize: Metrics.textMD
        color: Theme.foreground
        wrapMode: Text.Wrap
        verticalAlignment: Text.AlignVCenter
    }

    // --- BACKGROUND ---
    background: Rectangle {
        implicitHeight: Math.max(45, control.contentItem.implicitHeight)
        color: control.hovered ? Theme.primary : Theme.surface
        border.color: Theme.border
        border.width: 1
        radius: Metrics.radiusSM ?? 6
    }

    // --- ITEM DELEGATE ---
    delegate: ItemDelegate {
        id: delegate
        width: control.width
        highlighted: control.highlightedIndex === index

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
            color: delegate.hovered || delegate.highlighted ? Theme.primary : Theme.surface
        }
    }

    // --- POPUP CONTAINER ---
    popup: Popup {
        y: control.height + 4
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 4

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight > 250 ? 250 : contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            color: Theme.surface
            border.color: Theme.border
            border.width: 1
            radius: Metrics.radiusSM ?? 6
        }
    }
}
