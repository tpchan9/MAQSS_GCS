import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

Rectangle {
    property int vehicleStatusPadding: 10

    property string title: "Vehicle Monitor"
    property bool titleBold: true
    property int titleFontSize: 13

    property var labels: ["Vehicle","Status","Role"]
    property bool labelBold: true
    property int labelFontSize: 12

    property int vehicleFontSize: 12

    signal updateStatus(bool update)

    id: vehicleStatusBox
    TextField {
        id: vehicleStatusTitle
        anchors {
            top: vehicleStatusBox.top
            left: vehicleStatusBox.left
        }

        background: Rectangle {
            implicitWidth: vehicleStatusBox.width
            implicitHeight: vehicleStatusBox.height/6
            color: "transparent"
            border.color: "transparent"
        }
        text: title

        font {
            bold: titleBold
            pointSize: titleFontSize
        }

        readOnly: true
        selectByMouse: false
    }

    onUpdateStatus: {
        var i1 = 0

        // create new ListElements if they dont exist
        while (vehicleModel.count < quadcopters.length) {
            vehicleModel.append({name: quadcopters[i1].name, status: quadcopters[i1].status})
        }

        // update vehicle status display
        for (i1 = 0; i1< quadcopters.length; i1++ ) {
            vehicleModel.set(i1, {name: quadcopters[i1].name, status: quadcopters[i1].status, arrayNdx: i1})
            vehicleModel.set(i1, {role: quadcopters[i1].roles[quadcopters[i1].role], vehicleID: quadcopters[i1].idNumber})
        }
    }

    TextField {
        id: vehicleStatusLabels
        anchors {
            top: vehicleStatusTitle.bottom
            left: vehicleStatusBox.left
        }

        background: Rectangle {
            implicitWidth: vehicleStatusBox.width
            implicitHeight: vehicleStatusBox.height/8
            color: "transparent"
            border.color: "transparent"
        }

        text: labels[0] + " \t" + labels[1] + " \t" + labels[2]
        font {
            bold: labelBold
            pointSize: labelFontSize
        }
        readOnly: true
        selectByMouse: false

    }

    ListModel {
        id: vehicleModel
    }

    Component {
        id: vehicleComponent
        Item {
            property int vehicleID
            property int arrayNdx // index of vehicle inside quadcopters array
            Text {
                id: statusText
                text: name + " \t" + status + " \t"

                font {
                    pointSize: vehicleFontSize
                }
            }

            Button {
                id: roleToggle
                state: "Quick"
                anchors {
                    left: statusText.right
                }

                text: role
                height: statusText.height
                highlighted: false
                checkable: true

                states: State {
                    name: "Detailed"; when: roleToggle.checked
                    PropertyChanges {target:roleToggle; text: qsTr("Detailed")}
                }

                onClicked: {
                    if (roleToggle.state === "Detailed") {
                        quadcopters[arrayNdx].role = 1;
                        console.log("Set Vehicle ID: ", vehicleID, " at ndx: ", arrayNdx, ", role: ", quadcopters[arrayNdx].role)
                        console.log(roleToggle.state)
                    }
                    else {
                        quadcopters[arrayNdx].role = 0;
                        console.log("Set Vehicle ID: ", vehicleID, quadcopters[arrayNdx].role)
                        console.log(roleToggle.state)
                    }
                }
            }
        }
    }

    ListView {
        id: vehicleStatusList
        anchors {
            top: vehicleStatusLabels.bottom
            left: vehicleStatusLabels.left
            leftMargin: vehicleStatusPadding
            bottom: vehicleStatusBox.bottom
        }
        model: vehicleModel
        delegate: vehicleComponent
        spacing: 4
    }
}
