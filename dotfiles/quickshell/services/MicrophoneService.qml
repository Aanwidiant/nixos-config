pragma Singleton
import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: root

    property var defaultSource: Pipewire.defaultAudioSource
    property bool muted: false
    property real volume: 0.0
    property bool initialized: false

    property var inputDevices: []

    signal microphoneToggled()
    signal sourceChanged()

    PwObjectTracker {
        objects: Pipewire.defaultAudioSource ? [Pipewire.defaultAudioSource, ...root.inputDevices] : root.inputDevices
    }

    function updateInputDevices() {
        var devices = []
        var nodesList = Pipewire.nodes.values

        for (var i = 0; i < nodesList.length; i++) {
            var node = nodesList[i]
            if (!node || !node.properties) continue

            var mediaClass = node.properties["media.class"] || ""
            // Filter node bertipe Audio/Source (mikrofon/input device)
            if (mediaClass === "Audio/Source" || (!node.isStream && !node.isSink && node.audio)) {
                devices.push(node)
            }
        }
        root.inputDevices = devices
    }

    function syncInitialState() {
        var source = Pipewire.defaultAudioSource
        if (source && source.audio) {
            root.muted = source.audio.muted || false
            root.volume = source.audio.volume || 0.0
            root.initialized = true
        }
        updateInputDevices()
    }

    Component.onCompleted: {
        syncInitialState()
    }

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

        function onVolumeChanged() {
            var source = Pipewire.defaultAudioSource
            if (!source || !source.audio) return

            var newVol = source.audio.volume || 0.0

            if (Math.abs(newVol - root.volume) > 0.001) {
                root.volume = newVol
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

    function setDefaultSource(node) {
        if (node) {
            Pipewire.preferredDefaultAudioSource = node
        }
    }

    function setVolume(newVolume: real): void {
        var source = Pipewire.defaultAudioSource
        if (source && source.audio) {
            source.audio.volume = Math.max(0.0, Math.min(1.0, newVolume))
        }
    }

    function incrementVolume(amount: real): void {
        setVolume(root.volume + (amount || 0.05))
    }

    function decrementVolume(amount: real): void {
        setVolume(root.volume - (amount || 0.05))
    }

    function toggleMute(): void {
        var source = Pipewire.defaultAudioSource
        if (source && source.audio) {
            source.audio.muted = !source.audio.muted
        }
    }

    function mute(): void {
        var source = Pipewire.defaultAudioSource
        if (source && source.audio) {
            source.audio.muted = true
        }
    }

    function unmute(): void {
        var source = Pipewire.defaultAudioSource
        if (source && source.audio) {
            source.audio.muted = false
        }
    }
}
