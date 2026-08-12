pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Item {
    id: root

    // ==========================================
    // 1. UPOWER DEVICE (BATERAI)
    // ==========================================
    readonly property UPowerDevice device: UPower.displayDevice

    // Status dasar
    readonly property bool isReady: device?.ready ?? false
    readonly property bool isValidBattery: device?.isLaptopBattery ?? false

    // Persentase baterai (0 - 100)
    readonly property int percentage: Math.round((device?.percentage ?? 0) * 100)

    // Status Pengisian Daya
    readonly property int state: device?.state ?? UPowerDeviceState.Unknown
    readonly property bool isCharging: state === UPowerDeviceState.Charging
    readonly property bool isFullyCharged: state === UPowerDeviceState.FullyCharged
    readonly property bool isPluggedIn: isCharging || isFullyCharged || state === UPowerDeviceState.PendingCharge

    // Estimasi Sisa Waktu (Detik)
    readonly property real timeRemainingSeconds: isCharging ? (device?.timeToFull ?? 0) : (device?.timeToEmpty ?? 0)

    // Formatter Sisa Waktu ("1j 30m" atau "45m")
    readonly property string formattedTimeRemaining: {
        if (timeRemainingSeconds <= 0) return ""
        var hours = Math.floor(timeRemainingSeconds / 3600)
        var minutes = Math.floor((timeRemainingSeconds % 3600) / 60)

        if (hours > 0) return hours + "j " + minutes + "m"
        return minutes + "m"
    }

    // ==========================================
    // 2. POWER PROFILES DAEMON
    // ==========================================
    // Mengakses Singleton PowerProfiles bawaan Quickshell
    readonly property int activeProfile: PowerProfiles.profile
    readonly property bool hasPerformance: PowerProfiles.hasPerformanceProfile

    // Fungsi untuk mengubah Power Profile menggunakan Enum
    function setPowerProfile(newProfile) {
        if (newProfile === PowerProfile.Performance && !hasPerformance) {
            console.warn("BatteryService: Profil Performance tidak didukung pada sistem ini.")
            return
        }
        PowerProfiles.profile = newProfile
    }

    // Fungsi berganti profil secara sekuensial (Toggle/Cycle)
    function cyclePowerProfile() {
        if (activeProfile === PowerProfile.PowerSaver) {
            setPowerProfile(PowerProfile.Balanced)
        } else if (activeProfile === PowerProfile.Balanced) {
            if (hasPerformance) {
                setPowerProfile(PowerProfile.Performance)
            } else {
                setPowerProfile(PowerProfile.PowerSaver)
            }
        } else {
            setPowerProfile(PowerProfile.PowerSaver)
        }
    }

    // Mendapatkan nama string/label untuk UI
    function getProfileName(profile) {
        var p = (profile !== undefined) ? profile : activeProfile
        return PowerProfile.toString(p)
    }

    function getProfileIconByEnum(profile) {
        var p = (profile !== undefined) ? profile : activeProfile
        switch (p) {
            case PowerProfile.PowerSaver:  return "\uf06c"
            case PowerProfile.Balanced:    return "\udb83\udf85"
            case PowerProfile.Performance: return "\udb85\udcde"
            default: return "\uf128"
        }
    }

    function getProfileLabelByEnum(profile) {
        var p = (profile !== undefined) ? profile : activeProfile
        switch (p) {
            case PowerProfile.PowerSaver:  return "Power-Saver"
            case PowerProfile.Balanced:    return "Balanced"
            case PowerProfile.Performance: return "Performance"
            default: return "Unknown"
        }
    }
}
