import QtQuick 2.0
import QtGraphicalEffects 1.0
Rectangle {
    id: container
    width: 40
    height: 80
    border.width: 1
    border.color: "red"
    signal clicked(var data)
    property string backData
    property bool current: false

    Image{
        id: image
        anchors.fill: parent
        source: "file:" + appDir + "/background/" + backData
    }
    MouseArea{
        anchors.fill: parent
        onClicked: {
            container.clicked(backData)
        }
    }
    DropShadow{
        id: shadow
        anchors.fill: image
        horizontalOffset: 5
        verticalOffset:5
        radius: 8.0
        samples: 16
        color: "#80000000"
        source: image
        fast: true
        visible: current
    }
}
