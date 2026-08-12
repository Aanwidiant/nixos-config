pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

Item {
    id: root

    readonly property bool debug: true

    // ==========================================
    // LOGGING HELPERS
    // ==========================================
    function log(...args) { if (debug) console.log("[NetworkService]", ...args) }
    function warn(...args) { if (debug) console.warn("[NetworkService]", ...args) }

    // ==========================================
    // SIGNALS
    // ==========================================
    signal passwordRequired(var network)
    signal connectionFailed(string name, string errorMessage)

    // ==========================================
    // 1. GLOBAL STATE & BACKEND
    // ==========================================
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled
    readonly property var backend: Networking.backend
    readonly property var connectivity: Networking.connectivity
    readonly property bool canCheckConnectivity: Networking.canCheckConnectivity

    onWifiEnabledChanged: {
        log("📡 Wi-Fi software →", wifiEnabled)
        if (wifiEnabled && wifiDevice) wifiDevice.scannerEnabled = true
    }

    onWifiHardwareEnabledChanged: log("🔌 Wi-Fi hardware →", wifiHardwareEnabled)

    // ==========================================
    // 2. DEVICE RESOLUTION
    // ==========================================
    property WifiDevice wifiDevice: null
    property WiredDevice wiredDevice: null
    property var _previousActiveNetwork: null

    Instantiator {
        model: Networking.devices
        delegate: QtObject {
            Component.onCompleted: root._registerDevice(modelData)
            Component.onDestruction: root._unregisterDevice(modelData)
        }
    }

    function _registerDevice(dev) {
        if (!dev) return
        log("🔍 Device ditemukan:", dev.name, "| Type:", dev.type)

        if (dev.type === DeviceType.Wifi && !wifiDevice) {
            wifiDevice = dev
            wifiDevice.scannerEnabled = true
            log("✅ Wi-Fi device tersimpan:", dev.name)
        } else if (dev.type === DeviceType.Wired && !wiredDevice) {
            wiredDevice = dev
            log("✅ Wired device tersimpan:", dev.name)
        }
    }

    function _unregisterDevice(dev) {
        if (wifiDevice === dev) {
            wifiDevice = null
            log("❌ Wi-Fi device dihapus")
        }
        if (wiredDevice === dev) {
            wiredDevice = null
            log("❌ Wired device dihapus")
        }
    }

    // ==========================================
    // 3. EXPOSED PROPERTIES & WIRED DETAILS
    // ==========================================
    readonly property bool isWifiConnected: wifiDevice ? wifiDevice.connected : false
    readonly property bool isWiredConnected: wiredDevice ? wiredDevice.connected : false
    readonly property bool wiredHasLink: wiredDevice ? wiredDevice.hasLink : false
    readonly property int wiredLinkSpeed: wiredDevice ? wiredDevice.linkSpeed : 0

    property bool isScanning: false
    readonly property var wifiNetworksModel: wifiDevice ? wifiDevice.networks : null

    // ==========================================
    // 4. TIMERS (SCAN & ROLLBACK)
    // ==========================================
    Timer {
        id: scanAnimationTimer
        interval: 3000
        onTriggered: {
            root.isScanning = false
            log("⏹️ Animasi scan selesai.")
        }
    }

    // DIPERBAIKI: Gunakan Timer statis daripada Qt.createQmlObject (lebih aman & ringan)
    Timer {
        id: rollbackTimer
        interval: 1000
        property var targetNetwork: null

        onTriggered: {
            if (targetNetwork) {
                log("🔄 Executing rollback to:", targetNetwork.name)
                targetNetwork.connect()
            }
            targetNetwork = null
        }
    }

    function scanWifi() {
        if (!wifiDevice) {
            warn("⚠️ Tidak bisa scan: Wi-Fi device tidak ditemukan")
            return
        }
        log("🔄 Meminta pemicu scan baru pada", wifiDevice.name)
        wifiDevice.scannerEnabled = true
        root.isScanning = true
        scanAnimationTimer.restart()
    }

    // ==========================================
    // 5. ICONS CONSTANTS
    // ==========================================
    readonly property var _wifiIcons: ({
        "limited":   ["\udb82\udd2b", "\udb82\udd20", "\udb82\udd23", "\udb82\udd26", "\udb82\udd29"],
        "encrypted": ["\udb82\udd2c", "\udb82\udd21", "\udb82\udd24", "\udb82\udd27", "\udb82\udd2a"],
        "open":      ["\udb82\udd2f", "\udb82\udd1f", "\udb82\udd22", "\udb82\udd25", "\udb82\udd28"]
    })

    function _getIconIndex(strength) {
        if (strength >= 0.8) return 4
        if (strength >= 0.6) return 3
        if (strength >= 0.4) return 2
        if (strength >= 0.2) return 1
        return 0
    }

    // ==========================================
    // 6. ACTIONS & LOGIC
    // ==========================================
    function toggleWifi() {
        if (!wifiHardwareEnabled) { warn("⚠️ Hardware disabled"); return }
        const newState = !wifiEnabled
        log("🔄 Toggle Wi-Fi →", newState)
        Networking.wifiEnabled = newState
    }

    function setWifiEnabled(enabled) {
        if (wifiHardwareEnabled) Networking.wifiEnabled = enabled
    }

    function checkConnectivity() {
        if (!canCheckConnectivity) { warn("⚠️ Tidak support connectivity check"); return }
        log("🔍 Trigger connectivity check")
        Networking.checkConnectivity()
    }

    function disconnectWifi() {
        if (!wifiDevice || !wifiDevice.connected) { log("ℹ️ Wi-Fi sudah terputus"); return }
        log("🔌 Disconnect Wi-Fi")
        wifiDevice.disconnect()
    }

    function disconnectWired() {
        if (!wiredDevice || !wiredDevice.connected) { log("ℹ️ Wired sudah terputus"); return }
        log("🔌 Disconnect Wired")
        wiredDevice.disconnect()
    }

    function connectToNetwork(network) {
        if (!network) return
        // Diperbaiki: Menggunakan None (standar) alih-alih Open agar konsisten di seluruh file
        const isEncrypted = network.security !== WifiSecurityType.Open 

        if (isEncrypted && !network.known) {
            log("🔑 Jaringan butuh password:", network.name)
            root.passwordRequired(network)
        } else {
            log("🔗 Connect langsung ke:", network.name)
            network.connect()
        }
    }

    function connectWithPassword(network, password) {
        if (!network) return

        const networkName = network.name
        const wasKnownBefore = network.known === true

        // 1. Simpan jaringan aktif sebelumnya sebagai fallback
        root._previousActiveNetwork = null
        const connectedNet = _iterateModel(function(net) {
            return net && net !== network && (net.connected === true || net.isConnected === true)
        })

        if (connectedNet) {
            root._previousActiveNetwork = connectedNet
            log("📌 Fallback terdeteksi & disimpan:", connectedNet.name)
        }

        log("🔑 Mencoba koneksi dengan password ke:", networkName)

        var onFailedHandler, onConnectedHandler

        var cleanup = function() {
            try {
                network.connectionFailed.disconnect(onFailedHandler)
                network.connectedChanged.disconnect(onConnectedHandler)
            } catch (e) {
                // Abaikan error jika sinyal terlanjur terputus / objek network hancur
            }
        }

        onFailedHandler = function(reason) {
            log("❌ Connection Failed Reason Code:", reason)
            if (!wasKnownBefore) network.forget()

            var errorMsg = "Failed to connect"
            switch (reason) {
                case ConnectionFailReason.NoSecrets: errorMsg = "Incorrect password"; break
                case ConnectionFailReason.WifiAuthTimeout: errorMsg = "Authentication timed out"; break
                case ConnectionFailReason.WifiNetworkLost: errorMsg = "Network lost or out of range"; break
                default: errorMsg = ConnectionFailReason.toString(reason) || "Connection failed"
            }

            const targetFallback = root._previousActiveNetwork
            root._previousActiveNetwork = null

            if (targetFallback) {
                log("⏳ Menunggu NetworkManager idle, lalu reconnect ke:", targetFallback.name)
                errorMsg += " (Reconnecting to " + targetFallback.name + "...)"

                // Gunakan timer statis
                rollbackTimer.targetNetwork = targetFallback
                rollbackTimer.restart()
            }

            root.connectionFailed(networkName, errorMsg)
            cleanup()
        }

        onConnectedHandler = function() {
            if (network.connected) {
                log("🎉 Berhasil terhubung ke:", networkName)
                root._previousActiveNetwork = null 
                cleanup()
            }
        }

        network.connectionFailed.connect(onFailedHandler)
        network.connectedChanged.connect(onConnectedHandler)

        // Bungkus dalam try-catch untuk mencegah crash jika object rusak di tengah jalan
        try {
            network.connectWithPsk(password)
        } catch (e) {
            cleanup()
            warn("Error saat memanggil connectWithPsk:", e)
        }
    } 

    function disconnectNetwork(network) {
        if (!network) return
        log("🔌 Disconnect dari:", network.name)
        network.disconnect()
    }

    function forgetNetwork(network) {
        if (!network) return
        log("🗑️ Forget network:", network.name)
        network.forget()
    }

    function getWifiIcon(net) {
        if (!net) return "\udb82\udd2f" // Off / Disconnected

        const s = net.signalStrength || 0
        const idx = _getIconIndex(s)

        // 1. Kondisi Terhubung Tapi Terbatas / Tanpa Internet
        if (net.connected && (Networking.connectivity === NetworkConnectivity.Limited)) {
            return _wifiIcons.limited[idx]
        }

        // 2. Kondisi Terkunci (Encrypted)
        if (net.security !== WifiSecurityType.Open) {
            return _wifiIcons.encrypted[idx]
        } 

        // 3. Kondisi Terbuka / Standar (Open / Normal)
        return _wifiIcons.open[idx]
    }

    // ==========================================
    // 7. HELPER ITERASI MODEL
    // ==========================================
    // Mencegah duplikasi kode loop pada model.values vs rowCount()
    function _iterateModel(callback) {
        var model = wifiNetworksModel
        if (!model) return null

        if (model.values && model.values.length > 0) {
            for (var i = 0; i < model.values.length; i++) {
                if (callback(model.values[i])) return model.values[i]
            }
        } 
        else if (typeof model.rowCount === "function") {
            var count = model.rowCount()
            for (var j = 0; j < count; j++) {
                var item = model.data(model.index(j, 0))
                if (callback(item)) return item
            }
        }
        return null
    }

    function getConnectedWifiObject() {
        return _iterateModel(function(net) {
            return net && (net.connected === true || net.isConnected === true || net.state === "connected")
        })
    }

    function getConnectedWifiName() {
        var net = getConnectedWifiObject()
        if (net) return net.ssid || net.name || "Connected"
        return "Disconnected"
    }

    function activeWifiIcon() {
        if (!wifiEnabled) return "\udb82\udd2f" 
        return getWifiIcon(getConnectedWifiObject()) 
    }

    // ==========================================
    // 8. INITIALIZATION LOG
    // ==========================================
    Timer {
        id: initTimer
        interval: 500
        onTriggered: {
            log("🚀 === Status Akhir ===")
            log("   ├─ Backend:", NetworkBackendType.toString(root.backend))
            log("   ├─ Hardware:", root.wifiHardwareEnabled)
            log("   ├─ Software:", root.wifiEnabled)
            log("   ├─ Connectivity:", NetworkConnectivity.toString(root.connectivity))
            log("   ├─ Wi-Fi:", root.wifiDevice ? root.wifiDevice.name : "❌ Not Found")
            log("   └─ Wired:", root.wiredDevice ? (root.wiredDevice.name + " (Link: " + root.wiredHasLink + ")") : "❌ Not Found")
        }
    }

    Component.onCompleted: initTimer.start()
}
