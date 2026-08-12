import QtQuick

Item {
    id: root

    implicitWidth: 144
    implicitHeight: 32

    AnimatedImage {
        id: myIcon
        source: "../../eye.gif"
        height: 20

        anchors.centerIn: parent

        fillMode: Image.PreserveAspectFit

        playing: true
    }
}
