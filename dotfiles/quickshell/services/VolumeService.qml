pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

Item {
    id: root

    // --- Core Master Volume State ---
    property var defaultSink: Pipewire.defaultAudioSink
    property real volume: 0
    property bool muted: false
    property bool isBooted: false

    readonly property alias isMuted: root.muted

    signal volumeUpdated()
    signal muteToggled()
    signal sinkChanged()

    // --- Card Profiles State ---
    property string activeCardName: ""
    property string activeProfileKey: ""
    property var profileList: []

    // --- Application Streams Tracker ---
    property alias appLinkTracker: linkTracker

    PwNodeLinkTracker {
        id: linkTracker
        node: Pipewire.defaultAudioSink
    }

    Timer {
        id: startupTimer
        interval: 300
        running: true
        repeat: false
        onTriggered: {
            root.isBooted = true
        }
    }

    function syncInitialState() {
        var sink = Pipewire.defaultAudioSink
        if (sink && sink.audio) {
            root.volume = sink.audio.volume || 0
            root.muted = sink.audio.muted || false
        }
    }

    Component.onCompleted: {
        syncInitialState()
        refreshCardProfiles()
    }

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    // --- Master Volume Connections ---
    Connections {
        target: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
        enabled: Pipewire.defaultAudioSink !== null && Pipewire.defaultAudioSink.audio !== null

        function onVolumeChanged() {
            var sink = Pipewire.defaultAudioSink
            if (!sink || !sink.audio) return

            var newVolume = sink.audio.volume || 0

            if (Math.abs(newVolume - root.volume) > 0.001) {
                root.volume = newVolume
                if (root.isBooted) root.volumeUpdated()
            }
        }

        function onMutedChanged() {
            var sink = Pipewire.defaultAudioSink
            if (!sink || !sink.audio) return

            var newMuted = sink.audio.muted || false

            if (newMuted !== root.muted) {
                root.muted = newMuted
                root.muteToggled()
                if (root.isBooted) root.volumeUpdated()
            }
        }
    }

    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() {
            root.defaultSink = Pipewire.defaultAudioSink
            root.sinkChanged()
            root.syncInitialState()
        }
    }

    // --- Master Control Functions ---
    function setVolume(newVolume) {
        var sink = Pipewire.defaultAudioSink
        if (!sink || !sink.audio) return
        var clamped = Math.max(0.0, Math.min(1.5, newVolume))
        sink.audio.volume = clamped
    }

    function increaseVolume(step) {
        var sink = Pipewire.defaultAudioSink
        if (!sink || !sink.audio) return
        setVolume(sink.audio.volume + step)
    }

    function decreaseVolume(step) {
        var sink = Pipewire.defaultAudioSink
        if (!sink || !sink.audio) return
        setVolume(sink.audio.volume - step)
    }

    function toggleMute() {
        var sink = Pipewire.defaultAudioSink
        if (!sink || !sink.audio) return
        sink.audio.muted = !sink.audio.muted 
    }

    function getVolumeIcon(percent) {
        if (percent === 0) return "\ueee8"
        if (percent < 33) return "\uf026"
        if (percent < 66) return "\uf027"
        return "\uf028"
    }

    // --- Card Profiles Management ---
    Process {
        id: fetchCardProcess
        command: ["pactl", "-f", "json", "list", "cards"]

        property string accumulatedOutput: ""

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                fetchCardProcess.accumulatedOutput += data
            }
        }

        onExited: (code, status) => {
            if (code === 0 && accumulatedOutput.length > 0) {
                try {
                    var cards = JSON.parse(accumulatedOutput)
                    if (cards.length > 0) {
                        var card = cards[0] 

                        root.activeCardName = card.name
                        root.activeProfileKey = card.active_profile

                        var parsedProfiles = []
                        for (var profileKey in card.profiles) {
                            var prof = card.profiles[profileKey]
                            parsedProfiles.push({
                                key: profileKey,
                                description: prof.description,
                                available: prof.available
                            })
                        }

                        root.profileList = parsedProfiles
                    }
                } catch (e) {
                    console.log("[VolumeService] Error parsing JSON:", e)
                }
            }
            accumulatedOutput = ""
        }
    }

    Process {
        id: setProfileProcess
        onExited: (code, status) => {
            if (code === 0) {
                root.refreshCardProfiles()
            }
        }
    }

    function setCardProfile(profileKey) {
        if (!activeCardName || !profileKey) return
        setProfileProcess.command = ["pactl", "set-card-profile", activeCardName, profileKey]
        setProfileProcess.running = true
    }

    function refreshCardProfiles() {
        fetchCardProcess.running = false
        fetchCardProcess.running = true
    }
}
