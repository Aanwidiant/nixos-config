import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../theme"

Item {
    id: root

    implicitWidth: 168
    implicitHeight: 32

    // Status Timer dan Stopwatch
    readonly property bool isTimerActive: TimerService.tmRunning || TimerService.tmRemaining > 0
    readonly property bool isSwActive: TimerService.swRunning || TimerService.swSeconds > 0
    readonly property bool isActive: isTimerActive || isSwActive

    // Rasio progress murni Timer (1.0 = Penuh, 0.0 = Habis)
    readonly property real progressRatio: {
        if (TimerService.tmTotal > 0) {
            return Math.max(0.0, Math.min(1.0, TimerService.tmProgress));
        }
        return 0.0;
    }

    // Trigger pembaruan Canvas setiap kali detik timer berubah
    Connections {
        target: TimerService
        function onTmRemainingChanged() {
            if (root.isTimerActive) {
                borderCanvas.requestPaint();
            }
        }
        function onTmProgressChanged() {
            if (root.isTimerActive) {
                borderCanvas.requestPaint();
            }
        }
    }

    // -------------------------------------------------------------
    // CANVAS FOR MOVING PROGRESS BORDER (TIMER ONLY)
    // -------------------------------------------------------------
    Canvas {
        id: borderCanvas
        anchors.fill: parent
        // Hanya tampil jika mode TIMER aktif/tersimpan
        visible: root.isTimerActive && root.progressRatio > 0

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            if (!root.isTimerActive || root.progressRatio <= 0) return;

            var w = 168;
            var h = 32;
            var r = h / 2;
            var lineWidth = 2;

            var inset = lineWidth / 2;
            var rx = inset;
            var ry = inset;
            var rw = w - lineWidth;
            var rh = h - lineWidth;

            // Hitung total keliling rounded rectangle
            var straightX = rw - 2 * r;
            var straightY = rh - 2 * r;
            var arcLen = 0.5 * Math.PI * r; // 1/4 lingkaran
            var totalPath = (2 * straightX) + (2 * straightY) + (4 * arcLen);

            // Panjang garis yang harus digambar berdasarkan sisa waktu
            var targetLen = totalPath * root.progressRatio;

            ctx.lineWidth = lineWidth;
            ctx.strokeStyle = Theme.primary;
            ctx.lineCap = "round";

            // Buat jalur border tunggal
            ctx.beginPath();

            // Jalur 1: Dari Atas-Tengah ke Kanan
            var seg1 = straightX / 2;
            var currentLen = 0;

            if (targetLen > 0) {
                var d1 = Math.min(targetLen, seg1);
                ctx.moveTo(w / 2, ry);
                ctx.lineTo(w / 2 + d1, ry);
                currentLen += seg1;
            }

            // Jalur 2: Sudut Kanan-Atas
            if (targetLen > currentLen) {
                var remArc1 = Math.min(targetLen - currentLen, arcLen) / arcLen;
                ctx.arc(rx + rw - r, ry + r, r, -Math.PI / 2, -Math.PI / 2 + (remArc1 * Math.PI / 2));
                currentLen += arcLen;
            }

            // Jalur 3: Sisi Kanan (Ke Bawah)
            if (targetLen > currentLen) {
                var d2 = Math.min(targetLen - currentLen, straightY);
                ctx.lineTo(rx + rw, ry + r + d2);
                currentLen += straightY;
            }

            // Jalur 4: Sudut Kanan-Bawah
            if (targetLen > currentLen) {
                var remArc2 = Math.min(targetLen - currentLen, arcLen) / arcLen;
                ctx.arc(rx + rw - r, ry + rh - r, r, 0, remArc2 * Math.PI / 2);
                currentLen += arcLen;
            }

            // Jalur 5: Sisi Bawah (Ke Kiri)
            if (targetLen > currentLen) {
                var d3 = Math.min(targetLen - currentLen, straightX);
                ctx.lineTo(rx + rw - r - d3, ry + rh);
                currentLen += straightX;
            }

            // Jalur 6: Sudut Kiri-Bawah
            if (targetLen > currentLen) {
                var remArc3 = Math.min(targetLen - currentLen, arcLen) / arcLen;
                ctx.arc(rx + r, ry + rh - r, r, Math.PI / 2, Math.PI / 2 + (remArc3 * Math.PI / 2));
                currentLen += arcLen;
            }

            // Jalur 7: Sisi Kiri (Ke Atas)
            if (targetLen > currentLen) {
                var d4 = Math.min(targetLen - currentLen, straightY);
                ctx.lineTo(rx, ry + rh - r - d4);
                currentLen += straightY;
            }

            // Jalur 8: Sudut Kiri-Atas
            if (targetLen > currentLen) {
                var remArc4 = Math.min(targetLen - currentLen, arcLen) / arcLen;
                ctx.arc(rx + r, ry + r, r, Math.PI, Math.PI + (remArc4 * Math.PI / 2));
                currentLen += arcLen;
            }

            // Jalur 9: Kembali ke Atas-Tengah
            if (targetLen > currentLen) {
                var d5 = Math.min(targetLen - currentLen, seg1);
                ctx.lineTo(rx + r + d5, ry);
            }

            ctx.stroke();
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: Metrics.spacingMD

        // -------------------------------------------------------------
        // 1. ICON TIMER / STOPWATCH
        // -------------------------------------------------------------
        Text {
            text: TimerService.swRunning || TimerService.swSeconds > 0 ? "\uf520" : "\udb81\udd1b"
            font.pixelSize: Metrics.iconSM
            font.family: Theme.iconFont
            color: root.isActive ? Theme.primary : (iconHover.hovered ? Theme.primary : Theme.foreground)

            HoverHandler {
                id: iconHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: {
                    if (typeof controller !== "undefined" && controller.openTimer) {
                        controller.openTimer();
                    }
                }
            }
        }

        // -------------------------------------------------------------
        // 2. TEXT DISPLAY TIMER / STOPWATCH
        // -------------------------------------------------------------
        Text {
            Layout.fillWidth: true
            text: {
                if (TimerService.tmRemaining > 0) return TimerService.tmFormatted;
                if (TimerService.swSeconds > 0) return TimerService.swFormatted;
                return "Timer";
            }
            font.pixelSize: Metrics.textSM
            font.bold: root.isActive
            color: root.isActive ? Theme.primary : (textHover.hovered ? Theme.primary : Theme.foreground)
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter

            HoverHandler {
                id: textHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: {
                    if (typeof controller !== "undefined" && controller.openTimer) {
                        controller.openTimer();
                    }
                }
            }
        }

        // -------------------------------------------------------------
        // 3. ACTION BUTTONS (START/PAUSE & RESET)
        // -------------------------------------------------------------
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: Metrics.spacingMD

            // Tombol Start / Pause
            Text {
                id: playPauseBtn
                text: {
                    if (TimerService.tmRemaining > 0) return TimerService.tmRunning ? "\uf04c" : "\uf04b";
                    if (TimerService.swSeconds > 0) return TimerService.swRunning ? "\uf04c" : "\uf04b";
                    return "\uf04b";
                }
                font.pixelSize: Metrics.iconSM
                font.family: Theme.iconFont
                color: playHover.hovered ? Theme.primary : Theme.foreground

                HoverHandler {
                    id: playHover
                    cursorShape: Qt.PointingHandCursor
                }

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

            // Tombol Reset
            Text {
                id: resetBtn
                text: "\uead2"
                font.pixelSize: Metrics.iconSM
                font.family: Theme.iconFont

                readonly property bool canReset: {
                    if (TimerService.tmRemaining > 0) return !TimerService.tmRunning;
                    if (TimerService.swSeconds > 0) return TimerService.swCanReset;
                    return false;
                }

                color: canReset ? (resetHover.hovered ? Theme.primary : Theme.foreground) : Theme.foreground
                opacity: canReset ? 1.0 : 0.35

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                HoverHandler {
                    id: resetHover
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
