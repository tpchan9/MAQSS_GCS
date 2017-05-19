/* Collection of functions to work with XbeeInterface string messages

  Assumes incoming messages have the form:
  NEWMSG,TYPE,QX,DATAXXXXXXXX

  Currently supported incoming types are:
  UPDT - Indicates an status update from one of the vehicles
  TGT - Indicates  a point of interest is found or target has been confirmed

  Assumes outgoing messages have the form:
  NEWMSG,TYPE,QX,DATAXXXXXXX

  Currently supported outgoing types are:
  MSN - Sends a new search chunk mission to vehicle
  START - Sends a START signal to vehicle
  STOP - Sends a STOP signal to vehicle
  POI - Sends point of interest information to vehicle
*/
.import "Utils.js" as Utils

function handleGenericMsg(msg) {
    /* High level function to handle a new incoming string message from XbeeInterface
      Call this function from MainPage.qml

      Will perform the following operations:
      1. Split the msg based on ',' delimiter
      2. Validate the msg. Throw out if invalid msg
      3. Determine the msg type
      4. Interpret msg based on type
      5. Update GUI

    */

    // split msg based on known delimiter
    var delim = ",";
    var split_msg = msg.split(delim);
    var valid_msg = true;
    var vehicle_ID = " ";
    var msg_container = {
        msgType:"INVALID",
        vehicleID:-1,
        vehicleLocation:[0,0,0],
        vehicleStatus:"OFFLINE",
        vehicleRole:-1,
        targetLocation:[0,0,0],
        validLocation:[0,0,0]
    }

    // Make sure msg is valid
    if (split_msg[0] !== "NEWMSG") valid_msg = false;
    else {
        msg_container.msgType = split_msg[1];
    }

    // Check msg type
    if (valid_msg && (msg_container.msgType === "UPDT" || msg_container.msgType === "TGT" || msg_container.msgType === "VLD")) {

        // Interpret
        console.log("Handle UPDT Msg");
        msg_container.vehicleID = parseInt(split_msg[2][1]);
        msg_container.vehicleLocation = Utils.strToFloat((split_msg[3].substr(1)).split(" "));
        msg_container.vehicleStatus = split_msg[4].substr(1);
        msg_container.vehicleRole = parseInt(split_msg[5][1]);
        console.log("Reported Role: " , msg_container.vehicleRole);

        // TODO: Change this to POI and make a TGT for verified targets
        // if msg is a TGT type, append target location information
        if (msg_container.msgType === "TGT") {
            console.log("Handle TGT Msg");
            msg_container.targetLocation = Utils.strToFloat((split_msg[6].substr(1)).split(" "))
        }
        else if (msg_container.msgType === "VLD") {
            console.log("Handle VLD Msg");
            msg_container.validLocation = Utils.strToFloat((split_msg[6].substr(1)).split(" "))
        }

    }
    else valid_msg = false;

    if (!valid_msg) {
        console.log("Invalid Msg Ignored: ",msg);
        msg_container.msgType = "INVALID";
    }

    // Return msg information for update
    return msg_container;
}

function generatePOIMsg(msg_container, targetQuad) {
    // NEWMSG,POI,QX,P35.123456 120.123456
    // check msgType is correct

    var msg;
    // check targetQuad is not msg_container.vehicleID (quick vehicle cannot also be detailed vehicle)
    if (msg_container.vehicleID !== targetQuad)
     msg = "NEWMSG,POI,Q" + targetQuad + ",P" + msg_container.targetLocation[0] + " " + msg_container.targetLocation[1]

    return msg;
}

