import QtQuick 2.0

Rectangle{
    id:fontBtn
    property alias text: nameText.text
    radius: 12
    color: "#5796F8"
    opacity: mouseA.containsMouse ? 0.7 : 1
    signal click()

    Text{
        id: nameText
        anchors.centerIn: parent
        width: 60
        color: "white"
        font.pointSize: 10
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenterOffset: mouseA.containsMouse ? 0.5 : 0
        anchors.verticalCenterOffset: mouseA.containsMouse ? 0.5 : 0
        elide: Text.ElideRight
    }
    MouseArea{
        id:mouseA
        anchors.fill: parent
        onClicked: click()
    }
}
