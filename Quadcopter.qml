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

    // automatically set the name when idNumber changes
    onIdNumberChanged: name = "Quad" + String.fromCharCode('A'.charCodeAt() + idNumber)



}
