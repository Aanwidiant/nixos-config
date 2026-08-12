pragma Singleton
import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: root

    property var defaultSource: Pipewire.defaultAudioSource
    property bool muted: false
    property bool initialized: false

    // Model untuk menyimpan daftar perangkat mikrofon fisik
    property var inputDevices: []

    signal microphoneToggled()
    signal sourceChanged()

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSource ]
    }

    // Fungsi untuk memperbarui daftar node audio source (perangkat fisik)
    function updateInputDevices() {
        var devices = []
        var nodesList = Pipewire.nodes.values

        for (var i = 0; i < nodesList.length; i++) {
            var node = nodesList[i]
            if (!node || !node.properties) continue

            var mediaClass = node.properties["media.class"] || ""
            // Filter hanya node yang bertipe Audio/Source (mikrofon/input device)
            if (mediaClass === "Audio/Source") {
                devices.push(node)
            }
        }
        root.inputDevices = devices
    }

    function syncInitialState() {
        var source = Pipewire.defaultAudioSource
        if (source && source.audio) {
            root.muted = source.audio.muted || false
            root.initialized = true
        }
        updateInputDevices()
    }

    Component.onCompleted: {
        syncInitialState()
    }

    // Listener ketika ada perubahan pada node-node Pipewire
    Connections {
        target: Pipewire.nodes
        function onValuesChanged() {
            root.updateInputDevices()
        }
    }

    Connections {
        target: Pipewire.defaultAudioSource ? Pipewire.defaultAudioSource.audio : null
        enabled: Pipewire.defaultAudioSource !== null && Pipewire.defaultAudioSource.audio !== null

        function onMutedChanged() {
            var source = Pipewire.defaultAudioSource
            if (!source || !source.audio) return

            var newMuted = source.audio.muted || false

            if (newMuted !== root.muted) {
                root.muted = newMuted

                if (root.initialized) {
                    root.microphoneToggled()
                }
            }
        }
    }

    Connections {
        target: Pipewire

        function onDefaultAudioSourceChanged() {
            root.defaultSource = Pipewire.defaultAudioSource
            root.sourceChanged()
            root.syncInitialState()
        }
    }

    // Menjadikan perangkat tertentu sebagai default input source
    function setDefaultSource(node) {
        if (node) {
            Pipewire.defaultAudioSource = node
        }
    }

    function toggleMute() {
        var source = Pipewire.defaultAudioSource
        if (source && source.audio) {
            source.audio.muted = !source.audio.muted
        }
    }

    function mute() {
        var source = Pipewire.defaultAudioSource
        if (source && source.audio) {
            source.audio.muted = true
        }
    }

    function unmute() {
        var source = Pipewire.defaultAudioSource
        if (source && source.audio) {
            source.audio.muted = false
        }
    }
}
