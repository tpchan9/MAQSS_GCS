import QtQuick 2.7
import QtPositioning 5.3
import QtLocation 5.4
import QtGraphicalEffects 1.0

// functions as datacontainer for data about 1 quadcopter (an array of these is stored)
MapQuickItem {
    id: quadcopter

    property var coordLLA: [0, 0, 0]
    property string name
    property int idNumber: -1 // this probably shouldnt be working
    property string status
    property int role: 0 // 0 is quick search, 1 is detailed search
    property var roles: ["Quick","Detailed"]
    property var availableColors: ["dark blue", "green", "red", "blue", "violet","yellow","black","white"]
    property string iconColor: "black"

    // automatically set the name when idNumber changes
    onIdNumberChanged: name = "Quad" + String.fromCharCode('A'.charCodeAt() + idNumber)


    sourceItem: Image {
        id: image
        source: "images/quadcopter.png"
//        source: "https://cdn3.iconfinder.com/data/icons/cars-and-delivery/512/quadcopter-512.png"
//        source: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Northrop_Grumman.svg/2000px-Northrop_Grumman.svg.png"
        scale: 0.1
        height: 30
        width: 30
    }

    ColorOverlay {
        anchors.fill: parent
        color: iconColor
        source: image
    }

    anchorPoint.x: image.width/2
    anchorPoint.y: image.height/2

}
