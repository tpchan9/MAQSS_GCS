import QtQuick 2.7
import QtPositioning 5.3
import QtLocation 5.4
import QtGraphicalEffects 1.0

// icon for displaying target locations
MapQuickItem {
    id: validicon

    property var coordLLA: [0,0,0]
    property bool verified: false

    sourceItem: Image {
        id: image
        source: "images/valid.png"
        height: 50
        width: 50
    }

    //Figure out what this does
    /*onVerifiedChanged {
        image.height: 15
        image.width: 15
    }*/

    anchorPoint.x: image.width/2
    anchorPoint.y: image.height/2
}
