import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import XbeeInterfaceClass 1.0
import "js_resources/Utils.js" as Utils
import "js_resources/Messaging.js" as Messaging

/* Main Page Object
  A single MainPage object is created in the ApplicationWindow


  Creates and Contains Objects:
    -MapContainer.qml
    -VehicleStatus.qml
    -VehicleStatus.qml
    -MessageBox.qml

  Instantiates Singleton Class XbeeInterface to perform async read/write

  */
Item {
    // TODO: Add a caution "Demo" button (makes em dance)
    // TODO: Add area to input baudrate and deviceID
    // TODO: Add timeout functionality to set vehicle status as offline
    property int padding: 25
    property int pointsCaptured: 0  // DO NOT DELETE (Stores UI capture information)
    property int nQuickSearch: 0    // stores number of vehicles in the QuickSearch (Quick Scan) Role
    property int nDetailedSearch: 0 // stores number of vehicles in the DetailedSearch role
    property int baudRate: 57600    // serial interface baudRate

    property string currentMsg      // current message to be written to vehicles


    property bool capture: false    // stores if UI is in capture mode
    property bool missionSet: false // store if mission has been set by user

    property real field_angle: 154
    property var searchAreaCoords: []
    property var searchChunkCoords: [] // javascript array of nQuickSearch elements. Each element is a 5 element array of [lat lon alt] (3D array)
    property var searchChunkMessages: [] // string specifying search chunk
    property var vehicleCoords: [] // array which stores the locations of each active vehicle

    property var quadcopters: [] // array which stores Quadcopter.qml components
    property var targets: [] // array which stores TargetIcon.qml components

    signal startSignal(var object) // signal to indicate the start button has been toggled

    id: mainPage
    width: parent.width
    height: parent.height

    Item {
        id: testRoot
        Component.onCompleted: {
            XbeeInterface.newMsg.connect(handleNewMsg)
            XbeeInterface.baudrate = 57600
            console.log(XbeeInterface.baudrate)
        }
    }

    Rectangle {
        id: background
        anchors.centerIn: parent
        width: parent.width - parent.padding
        height: parent.height - parent.padding
        color: "transparent"

        // Container for the Map
        MapContainer {
            id: mapContainer
            anchors {
                left: parent.left
                top: parent.top
                topMargin: 0
                leftMargin: 0
            }

            mapWidth: parent.width * 0.75
            mapHeight: parent.height * 0.75
        }

        // Container for Vehicle Monitor and Control Buttons
        Rectangle {
            id: statusContainer
            width: parent.width * 0.25

            height: mapContainer.height
            color: "white"
            anchors {
                top: parent.top
                left: mapContainer.right
                topMargin: 0
                leftMargin: 0
            }

            // Vehicle Monitor Box
            VehicleStatus {
                id: vehicleStatusBox
                anchors {
                    top: statusContainer.top
                    topMargin: padding
                    left: statusContainer.left
                    leftMargin: padding
                }
                height: statusContainer.height/2
                width: statusContainer.width - 2 * padding
                color: "transparent"
            }

            // Control Button
            ControlPanel {
                id: controlPanelBox
                anchors {
                    left: statusContainer.left
                    leftMargin: padding
                    bottom: statusContainer.bottom
                    bottomMargin: padding
                }
                color: "transparent"
                height: statusContainer.height/2
                width: statusContainer.width - 2 * padding

            }

            // TODO: Add heading tool

        }
        // Message box
        MessageBox {
            id: messageBox
            fontSize: 12
        }

    }

    // TODO: Move to one of the .js files
    function handleNewMsg(msg) {
        /* Function to handle a new msg received by async read from XbeeInterface

          This function will:
          1. Split the msg
          2. Check if a Quadcopter component exists for the given Vehicle ID
          3. Create a Quadcopter component or update an existing component
          4. Update the VehicleStatus object
          5. Update the MapContainer object and QuadcopterIcon location

          A msg will have the form below:
          Q0,P35.300151 -120.661846 104.636000,SOnline,R0

          QX - Vehicle ID
          PXX.XXXX -XXX.XXXX XXX.XXX - Vehicle GPS Location
          SXXXXXXX - Vehicle Status (Online, Started, Offline, etc.)
          RX - Vehicle Role (0->Quick Scan, 1->Detailed Search)
          */
        var component
        var tmp = new Array; // arrays can have different data types
        var i1;
        var msg_container;
        var done_flag = false
        var nextNdx = quadcopters.length;

        // split the msg for parsing
        msg_container = Messaging.handleGenericMsg(msg);

        if (msg_container.msgType !== "INVALID") {
        // wait for Quadcopter.qml component to be created
        component = Qt.createComponent("Quadcopter.qml")
//        console.log(component.errorString())
        while (component.status !== Component.Ready) {
        }

        // check if quadID already exists
        for (i1 = 0; i1 < quadcopters.length; i1++) {
            if (quadcopters[i1].idNumber === msg_container.vehicleID) {
                quadcopters[i1].coordLLA = msg_container.vehicleLocation
                quadcopters[i1].status = msg_container.vehicleStatus
//                quadcopters[i1].role = msg_container.vehicleRole
                done_flag = true // set flag to indicate frame has been processed
            }
        }

        // else, create a new Quadcopter object
        if (!done_flag && component.status === Component.Ready) {
            quadcopters[nextNdx] = component.createObject(mapContainer, {"idNumber": msg_container.vehicleID, "coordLLA": msg_container.vehicleLocation})

            // warn object creation error
            if (quadcopters[nextNdx] === null) console.log("Error Creating Quadcopter Object")

            // update quadcopter
            quadcopters[nextNdx].status = msg_container.vehicleStatus
            quadcopters[nextNdx].role = msg_container.vehicleRole
            currentMsg = "Vehicle: " + quadcopters[nextNdx].name + " connected with status: " + quadcopters[nextNdx].status
            messageBox.write(currentMsg)

            // increment counter for number of Quick Search/Detailed Search Vehicles
            if (!quadcopters[nextNdx].role) nQuickSearch++ // increment
            else nDetailedSearch++
        }

        // TODO: Change this to handle a POI msg
        // handle a target location msg
        if (msg_container.msgType === "TGT" ) {
            var target_component;
            var next_target_ndx = targets.length;
            target_component = Qt.createComponent("TargetIcon.qml")
            console.log(target_component.errorString())
            while (target_component.status !== Component.Ready) {
            }
            targets[next_target_ndx] = target_component.createObject(mapContainer, {"coordLLA": msg_container.targetLocation});

            // warn object creation error
            if (targets[next_target_ndx] === null) console.log("Error Creating TargetIcon Object")
            currentMsg = "Point of Interest Found at: " + targets[next_target_ndx].coordLLA;
            messageBox.write(currentMsg);
            console.log(currentMsg);

            // loops through quadcopters to search for a detailed search vehicle
            for (i1 = 0; i1 < quadcopters.length; i1++) {

                // if detailed search vehicle available, send POI msg
                if (quadcopters[i1].role) {
                    XbeeInterface.writeMsg(generatePOIMsg(msg_container, i1));
                    currentMsg = "Writing POI Msg to Vehicle" + i1;
                    messageBox.write(currentMsg);
                    console.log(currentMsg)
                    break;
                }
            }
        }

        // TODO: Add handle TGT msg which marks the POI as verified

        // send vehicleStatusBox an updateStatus signal
        vehicleStatusBox.updateStatus(true)
        mapContainer.update()
        }
    }
}
