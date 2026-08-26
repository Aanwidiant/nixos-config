import QtQuick

Item {
    id: root

    implicitWidth: 156
    implicitHeight: 36

    AnimatedImage {
        id: myIcon
        source: "../../assets/eye.gif"
        height: 28

        anchors.centerIn: parent

        fillMode: Image.PreserveAspectFit

        playing: true
    }
}
