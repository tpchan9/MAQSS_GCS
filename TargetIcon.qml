import QtQuick 2.7
import QtPositioning 5.3
import QtLocation 5.4
import QtGraphicalEffects 1.0

// icon for displaying target locations
MapQuickItem {
    id: icon

    property var coordLLA: [0,0,0]
    property bool verified: false

    sourceItem: Image {
        id: image
//        source: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Button_Icon_Red.svg/120px-Button_Icon_Red.svg.png"
        source: "images/target.png"
        height: 5
        width: 5
    }

    onVerifiedChanged {
        image.height: 15
        image.width: 15
    }

    anchorPoint.x: image.width/2
    anchorPoint.y: image.height/2
}
