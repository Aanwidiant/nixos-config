pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io
import "../theme"

Item {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice

    readonly property bool isReady: device?.ready ?? false
    readonly property bool isValidBattery: device?.isLaptopBattery ?? false

    readonly property int percentage: Math.round((device?.percentage ?? 0) * 100)

    readonly property int state: device?.state ?? UPowerDeviceState.Unknown

    readonly property bool isCharging: state === UPowerDeviceState.Charging
    readonly property bool isFullyCharged: state === UPowerDeviceState.FullyCharged
    readonly property bool isPendingCharge: state === UPowerDeviceState.PendingCharge
    readonly property bool isPluggedIn: isCharging || isFullyCharged || isPendingCharge

    readonly property real timeRemainingSeconds: isCharging ? (device?.timeToFull ?? 0) : (device?.timeToEmpty ?? 0)

    readonly property string formattedTimeRemaining: {
        if (timeRemainingSeconds <= 0) return ""
        var hours = Math.floor(timeRemainingSeconds / 3600)
        var minutes = Math.floor((timeRemainingSeconds % 3600) / 60)

        if (hours > 0) return hours + "h " + minutes + "m"
        return minutes + "m"
    }

    Process {
        id: notifyProcess
    }

    function sendNotification(summary, body, urgency = "normal") {
        var cmd = `notify-send -u "${urgency}" -a "System" -i "${Theme.nixosIcon}" "${summary}" "${body}"`
        notifyProcess.command = ["/bin/sh", "-c", cmd]
        notifyProcess.running = true
    }

    property var lastPluggedState: null
    property bool lowBatteryNotified: false

    onIsPluggedInChanged: {
        if (!isReady) return

        if (lastPluggedState === null) {
            lastPluggedState = isPluggedIn
            return
        }

        if (isPluggedIn && !lastPluggedState) {
            var msgIn = "Battery is charging (" + percentage + "%)."
            if (formattedTimeRemaining !== "") {
                msgIn += " Time until full: " + formattedTimeRemaining + "."
            }
            sendNotification("Charger Connected", msgIn, "normal")
            lowBatteryNotified = false
        } else if (!isPluggedIn && lastPluggedState) {
            var msgOut = "Charger disconnected (" + percentage + "%)."
            if (formattedTimeRemaining !== "") {
                msgOut += " Time remaining: " + formattedTimeRemaining + "."
            }
            sendNotification("Charger Disconnected", msgOut, "normal")
        }

        lastPluggedState = isPluggedIn
    }

    onPercentageChanged: {
        if (!isReady || isPluggedIn) return

        if (percentage <= 20 && !lowBatteryNotified) {
            var msgLow = "Battery is low (" + percentage + "%)."
            if (formattedTimeRemaining !== "") {
                msgLow += " Time to empty: " + formattedTimeRemaining + "."
            }
            msgLow += " Please plug in your charger!"

            sendNotification("Low Battery Warning", msgLow, "critical" )
            lowBatteryNotified = true
        } else if (percentage > 20) {
            lowBatteryNotified = false
        }
    }

    onIsReadyChanged: {
        if (isReady && lastPluggedState === null) {
            lastPluggedState = isPluggedIn
        }
    }

    readonly property int activeProfile: PowerProfiles.profile
    readonly property bool hasPerformance: PowerProfiles.hasPerformanceProfile

    function setPowerProfile(newProfile) {
        if (newProfile === PowerProfile.Performance && !hasPerformance) {
            console.warn("BatteryService: Performance profile is not supported on this system.")
            return
        }
        PowerProfiles.profile = newProfile
    }

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
