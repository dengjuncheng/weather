import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 1.4
import Qt.labs.platform 1.0

Window {
    id: settingWindow
    visible: false
    property var backData:[]
    property alias currentThumb: tab2.currentThumb
    signal fontChange(var font)
    signal fontColorChange(var fontColor)
    signal updated(var data)
    signal autoAchieved()

    Connections{
        target: interactionCenter
        onBackgroundDownloadComplete:{
            console.log("背景图片同步下载完成")
            tab2.startLoadData()
            tab2.busyRun = false
        }
    }

    ListView{
        id: listView
        anchors.left: parent.left;
        anchors.top:parent.top
        height: parent.height
        width: 90
        model: listModel
        delegate: Rectangle{
            width:parent.width
            height: 40
            color: listView.currentIndex == index ? "#E3E3E3" :"#F6F6F6"
            Text{
                anchors.centerIn: parent;
                text: name
                verticalAlignment: Text.AlignVCenter
            }
            MouseArea{
                anchors.fill: parent
                onClicked: listView.currentIndex = index
            }
        }
    }

    ListModel{
        id: listModel
        ListElement{
            name:"通用设置"
        }
        ListElement{
            name:"背景设置"
        }
    }
    TabView{
        id: tabView
        tabsVisible: false
        anchors.left: listView.right
        anchors.top: parent.top
        width:parent.width - listView.width
        height: parent.height
        currentIndex: listView.currentIndex
        Tab{
            id: tab1
            Rectangle{
                anchors.fill: parent;
                Column{
                    id:nameColumn
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 30
                    anchors.topMargin: 10
                    spacing: 10
                    Text{
                        text: "开机启动"
                    }
                    Text{
                        text: "字体"
                    }
                    Text{
                        text: "字体颜色"
                    }
                }
                Column{
                    anchors.left: nameColumn.right
                    anchors.top: nameColumn.top
                    anchors.leftMargin: 20
                    spacing: 13
                    ToggleButton{
                        id: bootbtn
                        leftString: "开"
                        rightString: "关"
                        state: "right"
                    }

                    GeneralButton{
                        id: fontBtn
                        width:70
                        height: bootbtn.height
                        text: interactionCenter.getFont()
                        onClick: fontDialog.visible = true
                    }

                    GeneralButton{
                        id: colorBtn
                        width:70
                        height: bootbtn.height
                        text: interactionCenter.getFontColor()
                        color: interactionCenter.getFontColor()
                        onClick: colorDialog.visible = true
                        border.color: "#000000"
                        border.width: 1
                    }

                    ColorDialog{
                        id:colorDialog
                        onAccepted: {
                            colorBtn.color = currentColor
                            colorBtn.text = currentColor
                            interactionCenter.setFontColor(currentColor)
                            fontColorChange(currentColor)
                        }
                    }

                    FontDialog{
                        id: fontDialog
                        onAccepted:{
                            fontBtn.text = currentFont.family
                            fontChange(fontBtn.text)
                            interactionCenter.setFont(fontBtn.text)
                        }
                    }
                }

                Rectangle{
                    id: line
                    anchors.top: nameColumn.bottom
                    anchors.topMargin: 20
                    color: "red"
                    width:parent.width - 30
                    height: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text{
                    id: text
                    text: "定位设置："
                    anchors.left: nameColumn.left
                    anchors.top: line.bottom
                    anchors.topMargin: 20
                }

                ToggleButton{
                    id: locationBtn
                    leftString: "自动"
                    rightString: "手动"
                    anchors.left: text.left
                    anchors.top:text.bottom
                    anchors.topMargin: 10
                    btnState: interactionCenter.getAutoLocaltion() ? "left" : "right"
                    onBtnStateChanged: {
                        interactionCenter.setAutoLocation("left" === btnState)
                        if(btnState === "left"){
                            autoAchieved()
                        }
                    }
                }
                Rectangle{
                    id: cityRec
                    anchors.top: locationBtn.bottom
                    anchors.topMargin: 10
                    anchors.left: locationBtn.left
                    height: 20
                    width:parent.width
                    visible: locationBtn.btnState === "right"
                    function getAllProvince(){
                        var url = "http://" + interactionCenter.getServerIp() + ":8080" + "/api/weather/v1/city/province"
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
                                          var settingProvinceId = parseInt(interactionCenter.getProvinceId())

                                          var data = jsonResponse.data
                                          var index = 0;
                                          for(var item in data){
                                              var cityId = data[item].id
                                              if(cityId === settingProvinceId){
                                                  index = item
                                              }
                                              provinceBox.model.append({"name":data[item].name, "cityId":cityId})
                                          }
                                          provinceBox.currentIndex = index
                                      }else{
                                          console.log("服务器错误")
                                      }
                                  }

                              }
                          }
                          authReq.send("grant_type=client_credentials")
                    }
                    Component.onCompleted: {
                        getAllProvince()
                    }
                    ComboBox{
                        id: provinceBox
                        anchors.left: parent.left
                        height: parent.height
                        width: 80
                        textRole: "name"
                        model:provinceModel


                        function getCityInfoByProvinceId(id){
                            if(isNaN(id) || id <= 0){
                                return
                            }

                            var url = "http://" + interactionCenter.getServerIp() + ":8080" + "/api/weather/v1/city/child-city/" + id
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
                                              var settingCityId = parseInt(interactionCenter.getCityId())
                                              var data = jsonResponse.data

                                              var index = 0;
                                              for(var item in data){
                                                  var cityId = data[item].id
                                                  if(settingCityId === cityId){
                                                      index = item
                                                  }
                                                  cityBox.model.append({"name":data[item].name, "cityId": cityId})
                                              }
                                              cityBox.currentIndex = index

                                          }else{
                                              console.log("服务器错误")
                                          }
                                      }

                                  }
                              }
                              authReq.send("grant_type=client_credentials")
                        }

                        ListModel{
                            id: provinceModel
                            ListElement{
                                name: "0";
                                cityId: 1
                            }
                        }
                        Component.onCompleted: {
                            provinceModel.clear()
                        }
                        onCurrentIndexChanged: {
                            cityModel.clear()
                            console.log(JSON.stringify(provinceModel.get(currentIndex)))

                            getCityInfoByProvinceId(provinceModel.get(currentIndex).cityId)
                            cityBox.currentIndex = 0
                        }
                    }

                    ComboBox{
                        id: cityBox
                        anchors.left: provinceBox.right
                        anchors.leftMargin: 10
                        height:parent.height
                        width: 80
                        model:cityModel
                        textRole: "name"

                        ListModel{
                            id: cityModel
                            ListElement{
                                name: "121";
                                cityId: 0
                            }
                        }
                        Component.onCompleted: cityModel.clear()
                    }

                    GeneralButton{
                        id: confirmBtn
                        anchors.left: cityBox.right
                        anchors.leftMargin: 10
                        height:parent.height
                        width:50
                        text: "更新"
                        function getWeatherByCityId(id){
                            if(isNaN(id)){
                                return
                            }

                            var url = "http://" + interactionCenter.getServerIp() + ":8080" + "/api/weather/v1/detail/" + id
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
                                              var data = jsonResponse.data
                                              updated(data)
                                          }else{
                                              console.log("服务器错误")
                                          }
                                      }

                                  }
                              }
                              authReq.send("grant_type=client_credentials")
                        }
                        onClick: {
                            var provinceId = provinceModel.get(provinceBox.currentIndex).cityId
                            var cityId = cityModel.get(cityBox.currentIndex).cityId
                            interactionCenter.saveLocalInfo(provinceId, cityId)
                            getWeatherByCityId(cityId)
                        }
                    }
                }
            }
        }
        Tab{
            id: tab2
            property bool busyRun: true
            property string currentThumb: interactionCenter.currentBackground()
            property var currentObj
            property var thumbObjList: []

            function startLoadData(){
                var comp = Qt.createComponent("BackSettingItem.qml")
                console.log(backData.length)
                var rowSpace = 10
                var columnSpace = 10
                var w = 120
                var h = 160
                for(var i = 0 ; i < backData.length ; ++i){
                    if(comp.status === Component.Ready){
                        var current = false;
                        if(interactionCenter.currentBackground() === backData[i]){
                            current = true
                        }

                        //开始创建组件
                        var row = Math.floor(i / 4)
                        var column = i % 4
                        var y = row * h + (row + 1) * rowSpace
                        var x = column * w + (column + 1) * columnSpace
                        var obj = comp.createObject(tab2.item, {"backData":backData[i], "x": x, "y":y,"width":w,"height":h, "current":current})
                        obj.visible = true
                        obj.clicked.connect(onThumbClicked)
                        thumbObjList.push(obj)
                    }
                }
            }

            function onThumbClicked(data){
                currentThumb = data
                thumbObjList.forEach(function(item){
                    if(item.backData === currentThumb){
                        item["current"] = true
                    }else{
                        item["current"] = false
                    }
                })
                interactionCenter.setCurrentThumb(currentThumb)
            }

            Rectangle{
                id: view
                anchors.fill: parent
                BusyIndicator{
                    id: busy
                    anchors.centerIn: parent
                    running: tab2.busyRun
                    visible: tab2.busyRun
                }
            }
            onLoaded: {
                if(visible){
                    var jsonStr = interactionCenter.getAllBackground();
                    console.log(jsonStr)
                    var jsonObj = JSON.parse(jsonStr)
                    if(!jsonObj.success){
                        console.log("获取列表是失败")
                        return
                    }
                    backData = jsonObj.data
                }
            }
        }
    }
}
