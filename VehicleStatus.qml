import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import XbeeInterfaceClass 1.0

Rectangle {
    property int vehicleStatusPadding: 10

    property string title: "Vehicle Monitor"
    property bool titleBold: true
    property int titleFontSize: 13

    property var labels: ["Vehicle","Status","Role"]
    property bool labelBold: true
    property int labelFontSize: 12

    property int vehicleFontSize: 12
    property bool roleCheckable: true

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
            vehicleModel.set(i1, {name: quadcopters[i1].name, status: quadcopters[i1].status, role: quadcopters[i1].roles[quadcopters[i1].role]});
            vehicleModel.setProperty(i1, "vehicleID", quadcopters[i1].idNumber);
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

            // these arent getting set properly?
            property int indexOfThisDelegate: index
            property int vehicleID
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
                checkable: vehicleStatusBox.roleCheckable

                states: [
                    State {
                        name: "Detailed"; when: roleToggle.checked
                        PropertyChanges {target:roleToggle; text: qsTr("Detailed")}
                    },
                    State {
                        name: "Quick"; when: !roleToggle.checked
                        PropertyChanges {target:roleToggle; text: qsTr("Quick")}
                    }

                ]

                onClicked: {
                    if (roleToggle.state === "Detailed") {
                        console.log(index)
                        quadcopters[index].role = 1;
                        console.log("Set Vehicle ID: ", quadcopters[index].idNumber, " at ndx: ", index, ", role: ", quadcopters[index].role)
                        console.log(roleToggle.state)
                    }
                    else {
                        quadcopters[index].role = 0;
                        console.log("Set Vehicle ID: ", vehicleID, quadcopters[index].role)
                        console.log(roleToggle.state)
                    }

                    if (vehicleStatusBox.roleCheckable) {
                        XbeeInterface.writeMsg("NEWMSG,ROLE,Q" + quadcopters[index].idNumber + ",R" + quadcopters[index].role,quadcopters[index].idNumber)
                    }
                }
            }
            height: roleToggle.height
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
