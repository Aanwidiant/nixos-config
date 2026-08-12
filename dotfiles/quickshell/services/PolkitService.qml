pragma Singleton
import QtQuick
import Quickshell.Services.Polkit

Item {
    id: root

    property bool hasRequest: false
    property string message: ""
    property string iconName: ""
    property string inputPrompt: ""
    property bool responseVisible: false
    property bool isResponseRequired: false
    property bool isProcessing: false

    property string supplementaryMessage: ""
    property bool isError: false

    readonly property alias currentFlow: agent.flow

    signal requestStarted()
    signal requestFinished(bool success)
    signal requestCancelled()

    PolkitAgent {
        id: agent

        onFlowChanged: {
            if (flow) {
                root._flowReadyTriggered = false
                root.updateFromFlow(flow)
            } else {
                var isSuccess = root._lastSuccess && !root.isError
                var wasCancelled = root._lastCancelled

                root.resetState()

                if (wasCancelled) {
                    root.requestCancelled()
                } else {
                    root.requestFinished(isSuccess)
                }
            }
        }
    }

    Connections {
        target: agent.flow

        function onIsResponseRequiredChanged() {
            if (agent.flow) root.updateFromFlow(agent.flow)
        }

        function onInputPromptChanged() {
            if (agent.flow) root.updateFromFlow(agent.flow)
        }

        function onSupplementaryMessageChanged() {
            if (agent.flow && root.hasRequest) {
                root.supplementaryMessage = agent.flow.supplementaryMessage || ""
                root.isError = agent.flow.failed || agent.flow.supplementaryIsError
                root.isProcessing = false 
            }
        }

        function onFailedChanged() {
            if (agent.flow && root.hasRequest) {
                root.isError = agent.flow.failed
                root.isProcessing = false 

                if (agent.flow.failed && (!agent.flow.supplementaryMessage || agent.flow.supplementaryMessage === "")) {
                    root.supplementaryMessage = "Incorrect password, please try again."
                } else {
                    root.supplementaryMessage = agent.flow.supplementaryMessage || ""
                }
            }
        }
    }

    function updateFromFlow(f) {
        if (!f) return

        root.message = f.message || "Authentication Required"
        root.iconName = f.iconName || "dialog-password"
        root.inputPrompt = f.inputPrompt || "Password:"
        root.responseVisible = f.responseVisible || false
        root.isResponseRequired = f.isResponseRequired

        root.isError = f.failed || f.supplementaryIsError
        root.supplementaryMessage = f.supplementaryMessage || ""

        if (f.isResponseRequired) {
            root.isProcessing = false
        }

        if (f.isResponseRequired && !root._flowReadyTriggered) {
            root._flowReadyTriggered = true
            root.hasRequest = true
            root._lastSuccess = false
            root._lastCancelled = false
            root.requestStarted()
        }
    }

    function submitPassword(password) {
        if (agent.flow && agent.flow.isResponseRequired) {
            root.isProcessing = true
            root.supplementaryMessage = "Authenticating..."
            root.isError = false
            root._lastSuccess = true
            root._lastCancelled = false

            agent.flow.submit(password)
        } else {
            console.warn("[PolkitService] Flow tidak valid atau tidak membutuhkan respon.")
        }
    }

    function cancelRequest() {
        root._lastSuccess = false
        root._lastCancelled = true

        if (agent.flow) {
            agent.flow.cancelAuthenticationRequest()
        } else {
            root.resetState()
            root.requestCancelled()
        }
    }

    function resetState() {
        root.hasRequest = false
        root.isProcessing = false
        root.supplementaryMessage = ""
        root.isError = false
        root.message = ""
        root.iconName = ""
        root.inputPrompt = ""
        root.responseVisible = false
        root.isResponseRequired = false
        root._lastSuccess = false
        root._lastCancelled = false
        root._flowReadyTriggered = false
    }

    property bool _lastSuccess: false
    property bool _lastCancelled: false
    property bool _flowReadyTriggered: false
}
