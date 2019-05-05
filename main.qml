import QtQuick 2.10
import QtQuick.Window 2.10

Window {
    id:mainWindow
    visible: true
    width: 240
    height: 320
//    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "#00000000"
    Component.onCompleted: {
        var pos = interactionCenter.getCoordinate().split(",")
        console.log(pos)
        x = parseInt(pos[0])
        y = parseInt(pos[1])
    }

    Rectangle{
        id: centroView
        anchors.fill: parent;
        radius: 5
        color: "#00000000"
        property var weatherInfo
        property string font: interactionCenter.getFont()
        property string fontColor: interactionCenter.getFontColor()

        onWeatherInfoChanged: {
            nameText.value = weatherInfo.cityName
            temperatureText.value = weatherInfo.temperature
            humidityText.value = weatherInfo.humidity
            vaneText.value = weatherInfo.vane
            rayText.value = weatherInfo.uiRay
            airText.value = weatherInfo.airQuality
            weatherText.value = weatherInfo.roughWeather
            pmText.value = weatherInfo.pm
            sunText.value = weatherInfo.sunrise
            sunText.value1 = weatherInfo.sunset
        }

        Image{
            id:back
            anchors.fill: parent
            source: "file:" + appDir + "/background/" + settingWindow.currentThumb
            opacity: 0.8
        }
        MouseArea{
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            property point clickPos: "0,0"
            onPressed: {
                clickPos = Qt.point(mouse.x, mouse.y)
            }
            onPositionChanged: {
                //鼠标偏移量
                var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                mainWindow.setX(mainWindow.x + delta.x)
                mainWindow.setY(mainWindow.y + delta.y)
            }
            onClicked: {
                settingWindow.setVisible(true)
            }
        }
        Text {
            id: nameText
            text: qsTr(value)
            font.pixelSize: 30
            font.family: centroView.font
            color: centroView.fontColor
            anchors.left: parent.left
            anchors.top:parent.top
            anchors.leftMargin: 10
            anchors.topMargin: 10
            property var value: "未获取"
            width: 50
            height: 30
        }

        Text{
            id: temperatureText
            anchors.left: parent.left
            anchors.top: nameText.bottom
            anchors.leftMargin: 20
            anchors.topMargin: 20
            font.pixelSize: 15
            font.family: centroView.font
            property string prefix: "温度："
            property var value: "未获取"
            text: qsTr(prefix + value)
            color: centroView.fontColor
        }

        Text{
            id: humidityText
            anchors.left: temperatureText.left
            anchors.top: temperatureText.bottom
            anchors.topMargin: 10
            font.pixelSize: 15
            font.family: centroView.font
            property string suffix: "%"
            property string prefix: "湿度："
            property var value: "未获取"
            text: qsTr(prefix + value + suffix)
            color: centroView.fontColor
        }
        Text{
            id: vaneText
            anchors.left: temperatureText.left
            anchors.top: humidityText.bottom
            anchors.topMargin: 10
            font.pixelSize: 15
            font.family: centroView.font
            property string prefix: "风向："
            property var value: "未获取"
            text: qsTr(prefix + value)
            color: centroView.fontColor
        }

        Text{
            id: rayText
            anchors.left: temperatureText.left
            anchors.top: vaneText.bottom
            anchors.topMargin: 10
            font.pixelSize: 15
            font.family: centroView.font
            property string prefix: "紫外线："
            property var value: "未获取"
            text: qsTr(prefix + value)
            color: centroView.fontColor
        }

        Text{
            id: airText
            anchors.left: temperatureText.left
            anchors.top: rayText.bottom
            anchors.topMargin: 10
            font.pixelSize: 15
            font.family: centroView.font
            property string prefix: "空气质量："
            property var value: "未获取"
            text: qsTr(prefix + value)
            color: centroView.fontColor
        }
        Text{
            id: weatherText
            anchors.left: temperatureText.left
            anchors.top: airText.bottom
            anchors.topMargin: 10
            font.pixelSize: 15
            font.family: centroView.font
            property string prefix: "天气："
            property var value: "未获取"
            text: qsTr(prefix + value)
            color: centroView.fontColor
        }

        Text{
            id: pmText
            anchors.left: temperatureText.left
            anchors.top: weatherText.bottom
            anchors.topMargin: 10
            font.pixelSize: 15
            font.family: centroView.font
            property string prefix: "pm："
            property int value: 0
            text: qsTr(prefix + "93")
            color: centroView.fontColor
        }

        Text{
            id: sunText
            anchors.left: temperatureText.left
            anchors.top: pmText.bottom
            anchors.topMargin: 10
            font.pixelSize: 15
            font.family: centroView.font
            property string prefix: "日出："
            property string suffix: "  日落："
            property var value: "00:00"
            property var value1: "00:00"
            text: qsTr(prefix + value + suffix + value1)
            color: centroView.fontColor
        }
        Component.onCompleted: {
            var auto = interactionCenter.getAutoLocaltion()
            if(auto){
                getWeatherInfo(-1)
            }else{
                var cityId = interactionCenter.getCityId()
                getWeatherInfo(cityId)
            }
        }

    }

    function getWeatherInfo(id){
        var url = "http://" + interactionCenter.getServerIp() + ":8080" + "/api/weather/v1/detail"
        if(id > 0){
            url = url +  "/" + id
        }

        var authReq = new XMLHttpRequest;
          authReq.open("GET", url);
          authReq.setRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8");
          authReq.setRequestHeader("Authorization", "Basic ");
          authReq.onreadystatechange = function() {
              if (authReq.readyState === XMLHttpRequest.DONE) {
                  var jsonResponse = JSON.parse(authReq.responseText);
                  if (jsonResponse.errors !== undefined)
                      console.log("Authentication error: " + jsonResponse.errors[0].message)
                  else{
                      if(jsonResponse.success){
                          centroView.weatherInfo = jsonResponse.data
                      }else{
                          console.log("服务器错误")
                      }
                  }

              }
          }
          authReq.send("grant_type=client_credentials")
    }

    SettingWindow{
        id:settingWindow
        width:640
        height:480
        onFontChange: {
            centroView.font = font
            interactionCenter.setFont(font)
        }
        onFontColorChange: {
            centroView.fontColor = fontColor
            interactionCenter.setFontColor(fontColor)
        }
        onUpdated:{
            centroView.weatherInfo = data
        }
        onAutoAchieved: {
            getWeatherInfo(-1)
        }
    }

    Connections{
        target: interactionCenter
        onReadyExit: {
            var coordinate = mainWindow.x + "," + mainWindow.y
            interactionCenter.saveConfig(coordinate)
        }
    }
}
