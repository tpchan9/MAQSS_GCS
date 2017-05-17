import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtPositioning 5.3
import QtLocation 5.4
import "js_resources/Coordinates.js" as Coordinates
import "js_resources/GPS.js" as GPS

Rectangle {
    id: mapContainer

    property int mapWidth
    property int mapHeight
    property var searchChunkContainer: []
    property var targetIcons: []
    property real startLat: 35.32796246271536
    property real startLon: -120.75197292670919
    property bool corner1Set: false
    property bool corner2Set: false

    width: mapWidth
    height: mapHeight

    color: "gray"

    // TODO: Configure plugin to use google maps
    // [Initialize Plugin]
    Plugin {
        id: myPlugin
        name: "osm"
    }

    // TODO: Figure out how to cache map data
    Map {
        id: map
        anchors.fill: parent
        plugin: myPlugin;
        center {
            latitude: startLat
            longitude: startLon
        }

        gesture.enabled: true
        zoomLevel: 18.5
        activeMapType: map.supportedMapTypes[5]

        // TODO: Make these not show up before a mission has been set
        // Two marker icons
        MapQuickItem {
            id: mark1
            sourceItem: Image {
                id: image1
//                source: "http://icons.iconarchive.com/icons/paomedia/small-n-flat/128/map-marker-icon.png"
                source: "images/marker.png"
                opacity: .1
                scale: 0.1
                height: 50
                width: 50
            }
            anchorPoint.x: image1.width/2
            anchorPoint.y: image1.height
            coordinate: QtPositioning.coordinate(35.32814040870949, -120.7519096842783, 0)
        }

        MapQuickItem {
            id: mark2
            sourceItem: Image {
                id: image2
//                source: "http://icons.iconarchive.com/icons/paomedia/small-n-flat/128/map-marker-icon.png"
                source: "images/marker.png"
                scale: 0.1
                opacity: .1
                height: 50
                width: 50
            }
            anchorPoint.x: image2.width/2
            anchorPoint.y: image2.height
            coordinate: QtPositioning.coordinate(35.32781726153697, -120.75204994659205, 0)
        }

        // Rectangle between marker icons
        MapPolygon {
            id: mapPolygon
            color: "transparent"
            opacity: 0.5
        }

        MouseArea {
            id: mapMouseArea
            anchors.fill: parent

            // wait for two clicks whenever captureButton is pressed
            onPressed: {
                if (controlPanelBox.captureState) {

                    if (pointsCaptured === 0 ) {
                        mark1.coordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y))
                        image1.opacity = 100
                        mapPolygon.path = []
                    }
                    else if (pointsCaptured === 1) {
                        image2.opacity = 100
                        mark2.coordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y))
                    }
                    pointsCaptured += 1

                    if (pointsCaptured >= 2) {

                        // draw polygon
                        mapContainer.update()

                        currentMsg = "Marker Distance: " + GPS.distance(mark1.coordinate,mark2.coordinate) + ", Marker Bearing: " + GPS.bearing(mark1.coordinate,mark2.coordinate)
                        messageBox.write(currentMsg)

                        controlPanelBox.captureState = false
                        controlPanelBox.state = "Waiting"
                        pointsCaptured = 0
                    }
                }

                else {
                    console.log("Point Capture Not Enabled")
                    var pt = map.toCoordinate(Qt.point(mouse.x, mouse.y));
                    console.log(pt.latitude)
                    console.log(pt.longitude)
                }
            }
        }
    }

    function check() {
        if (controlPanelBox.captureState) {
        if (controlPanelBox.corner1LatSet && controlPanelBox.corner1LongSet) {
            corner1Set = true
            mark1.coordinate = QtPositioning.coordinate(controlPanelBox.corner1Lat, controlPanelBox.corner1Long, 0)
            image1.opacity = 100
            controlPanelBox.corner1LatSet = false
            controlPanelBox.corner1LongSet = false
        }
        if (controlPanelBox.corner2LatSet && controlPanelBox.corner2LongSet) {
            corner2Set = true
            mark2.coordinate = QtPositioning.coordinate(controlPanelBox.corner2Lat, controlPanelBox.corner2Long, 0)
            image2.opacity = 100
            controlPanelBox.corner2LatSet = false
            controlPanelBox.corner2LongSet = false
        }

        if (corner1Set && corner2Set) {
            corner1Set = false
            corner2Set = false
            controlPanelBox.captureState = false
            controlPanelBox.state = "Waiting"
            currentMsg = "Marker Distance: " + GPS.distance(mark1.coordinate,mark2.coordinate) + ", Marker Bearing: " + GPS.bearing(mark1.coordinate,mark2.coordinate)
            messageBox.write(currentMsg)
            update()
        }
        }

    }

    function update() {
        var polygonCoord = Coordinates.calculateCoords(mark1.coordinate, mark2.coordinate, mainPage.field_angle)
        var i1,j1
        var component
        var tmp_coord
        var target_icon_component;

        // Update main search Area
        mapPolygon.path = []
        for (i1 = 0; i1 < 5; i1++) {

            // add corner of search area rectangleS
            searchAreaCoords[i1] = QtPositioning.coordinate(polygonCoord[i1][0], polygonCoord[i1][1], polygonCoord[i1][2])
            mapPolygon.addCoordinate(searchAreaCoords[i1])
        }

        // divide search area and create searchChunk
        searchChunkCoords = Coordinates.divideSearchArea(searchAreaCoords,mainPage.field_angle, nQuickSearch)
        component = Qt.createComponent("SearchChunk.qml")

        // clear old search chunks
        if (searchChunkContainer.length > 0) {
            for (i1 = 0; i1 < searchChunkContainer.length; i1++) {
                searchChunkContainer[i1].destroy()
            }
        }

        // TODO: Implement reuse of MapPolygons instead of destruction (reduce computation time)
        for (i1 = 0; i1< nQuickSearch; i1++) {
            searchChunkContainer[i1] =  component.createObject(map)

            // warn object creation error
            if (searchChunkContainer[i1] === null) {
                console.log("Error Creating SearchChunk Object")
            }

            // Add corners of polygon for each Search Chunk
            searchChunkContainer[i1].path = []
            for (j1 = 0; j1 < 5; j1++) {
                searchChunkContainer[i1].addCoordinate(QtPositioning.coordinate(searchChunkCoords[i1][j1][0], searchChunkCoords[i1][j1][1], searchChunkCoords[i1][j1][2]))
            }

            // Set Search Chunk color
            searchChunkContainer[i1].color = searchChunkContainer[i1].availableColors[i1 % searchChunkContainer[i1].nColors]
            map.addMapItem(searchChunkContainer[i1])

            // update searchChunk messages
        }

        // Display message to indicate new Search Area Calculated
        currentMsg = "Search area added with " + nQuickSearch + " search chunks at " + field_angle + "° heading" +"\n\tCorners at: " + searchAreaCoords[0] + ", " + searchAreaCoords[2]
        messageBox.write(currentMsg)

//        iconComponent = Qt.createComponent("QuadcopterIcon.qml")
        for (i1 = 0; i1 < quadcopters.length; i1++ ) {
//            tt = GPS.midPoint(searchChunkCoords[0][0],searchChunkCoords[0][2])
//            console.log(searchAreaCoords)
//            tmp_coord = QtPositioning.coordinate(tt[0],tt[1],tt[2])
            vehicleCoords[i1] = [quadcopters[i1].coordLLA[0], quadcopters[i1].coordLLA[1], quadcopters[i1].coordLLA[2]]

            // render the quadcopter icon at the starting coord
            tmp_coord = QtPositioning.coordinate(quadcopters[i1].coordLLA[0], quadcopters[i1].coordLLA[1])
            quadcopters[i1].coordinate = tmp_coord
            quadcopters[i1].iconColor = quadcopters[i1].availableColors[quadcopters[i1].idNumber]
            map.addMapItem(quadcopters[i1])
        }

        // Create target icons
        for (i1 = 0; i1 < targets.length; i1++) {
            tmp_coord = QtPositioning.coordinate(targets[i1].coordLLA[0], targets[i1].coordLLA[1], targets[i1].coordLLA[2]);

            targets[i1].coordinate = tmp_coord;
            map.addMapItem(targets[i1]);
        }
    }
}

