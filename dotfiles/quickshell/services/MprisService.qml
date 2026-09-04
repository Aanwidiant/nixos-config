pragma Singleton
import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: root

    readonly property MprisPlayer activePlayer: {
        let players = Mpris.players.values;
        if (players.length === 0) return null;
        for (let i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing) {
                return players[i];
            }
        }
        return players[0];
    }

    readonly property string trackTitle: activePlayer ? (activePlayer.trackTitle || "Nothing Played") : "Nothing Played"
    readonly property string trackArtist: activePlayer ? (activePlayer.trackArtist || "Nothing Played") : "Nothing Played"

    readonly property bool isPlaying: activePlayer ? activePlayer.isPlaying : false
    readonly property bool canGoNext: activePlayer ? activePlayer.canGoNext : false
    readonly property bool canGoPrevious: activePlayer ? activePlayer.canGoPrevious : false
    readonly property bool canControl: activePlayer ? activePlayer.canControl : false
    readonly property bool canSeek: activePlayer ? (activePlayer.canSeek && activePlayer.positionSupported) : false

    readonly property real position: activePlayer ? activePlayer.position : 0
    readonly property real length: (activePlayer && activePlayer.lengthSupported) ? activePlayer.length : 0

    readonly property string albumArtUrl: {
        if (!activePlayer) return "";
        if (activePlayer.trackArtUrl && activePlayer.trackArtUrl !== "") {
            return activePlayer.trackArtUrl;
        }
        let ytThumb = getYouTubeThumbnail(activePlayer.trackUrl);
        if (ytThumb !== "") {
            return ytThumb;
        }
        return "";
    }

    function getYouTubeThumbnail(url) {
        if (!url) return "";
        let regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
        let match = url.match(regExp);
        if (match && match[2].length === 11) {
            return "https://img.youtube.com/vi/" + match[2] + "/hqdefault.jpg";
        }
        return "";
    }

    function formatTime(seconds) {
        if (!seconds || isNaN(seconds) || seconds < 0) return "0:00";
        let m = Math.floor(seconds / 60);
        let s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    function togglePlaying() {
        if (activePlayer && canControl) activePlayer.togglePlaying();
    }

    function next() {
        if (activePlayer && canGoNext) activePlayer.next();
    }

    function previous() {
        if (activePlayer && canGoPrevious) activePlayer.previous();
    }

    function seekToRatio(ratio) {
        if (!activePlayer || !length) return;
        let targetPosition = Math.min(Math.max(ratio, 0), 1) * length;
        activePlayer.position = targetPosition;
    }

    property var _animation: FrameAnimation {
        running: root.activePlayer && root.isPlaying
        onTriggered: {
            if (root.activePlayer) {
                root.activePlayer.positionChanged();
            }
        }
    }
}
