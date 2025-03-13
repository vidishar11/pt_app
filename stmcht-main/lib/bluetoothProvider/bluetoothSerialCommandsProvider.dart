

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:stmcht/dataPreferences/DataProvider.dart';

import 'bluetoothConnectionprovider.dart';

class BluetootlSerialProvider extends ChangeNotifier{


  BluetoothConnection? _connection;
  Timer? _timeoutTimer;
    List<String> tempmessages = [];
    String _messageBuffer = '';
  List<MessageDet> messages = [];
  List<String> batterystatus = [];
   List<String> deviceinfo = [];

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _startListening();
      return true;
    } catch (e) {
      print('Error connecting to device: $e');
     return connectToDevice(device).then((value) => value);
      return false;
    }
  }

  Future<void> sendCommand(String command) async {
    if (_connection != null && _connection!.isConnected) {
      try {
        _connection!.output.add(Uint8List.fromList(utf8.encode(command)));
        await _connection!.output.allSent;

      } catch (e) {
        print('Error sending command: $e');
      }
    } else {

      DataProvider().getData(DataProvider.bt_c).then((value) {
        if(value!=null) {
          connectToDevice(BluetoothDevice(address: value));
        }
      });
      print('Bluetooth connection is not available.');
    }
  }


  Future<void> _startListening() async {
    _connection!.input!.listen(_onDataReceivedMessages).onDone(() {


              messages = [];
        List<MessageDet> newmessages = [];
        tempmessages.forEach((element) async {
          if (element.contains("MIN") &&element.contains("SIN") && element.contains("\$")) {
            newmessages.add(MessageDet(
                type: "received",
                time: DateTime.now().toString(),
                userId: "received",
                message: element));

          } else if (element.contains("batterylevel")) {
            batterystatus.add(element);
           await DataProvider().setData(DataProvider.batterylevel, element);
          } else if (element.contains("PIN")) {
            deviceinfo.add(element);
          }
          debugPrint(element);
        });

        deviceinfo.forEach((element) async {

          await DataProvider().setData(element.contains("firmwareRevision")?DataProvider.frimwareRevision:element.contains("model")?DataProvider.model:element.contains("mobileID")?DataProvider.mobie_id:element.contains("satState")?DataProvider.satstate:element.contains("speed")?DataProvider.speed:element.contains("altitude")?DataProvider.altitude:element.contains("fixType")?DataProvider.fixType:element.contains("longitude")?DataProvider.longitude:element.contains("latitude")?DataProvider.latitude:"" ,element);

        });
        newmessages.isEmpty?null:saveMessages(newmessages);


    });
  }

  Future<void> disconnect() async {
    if (_connection != null && _connection!.isConnected) {
      await _connection!.finish();
    }
    _cancelTimeout();
  }

  void _resetTimeout() {
    _cancelTimeout();
    _timeoutTimer = Timer(Duration(minutes: 1), () {
      // Disconnect if no messages received for 5 minutes (adjust as needed)
      disconnect();
    });
  }

  void _cancelTimeout() {
    if (_timeoutTimer != null && _timeoutTimer!.isActive) {
      _timeoutTimer!.cancel();
    }
  }


  void _onDataReceivedMessages(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }
    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);

    if (dataString.contains("^")) {
      _connection!.finish();
    }
    int index = buffer.indexOf(13);
    if (~index != 0) {
      tempmessages.add(
        backspacesCounter > 0
            ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
            : _messageBuffer + dataString.substring(0, index),
      );
      _messageBuffer = dataString.substring(index);
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }

   // debugPrint(tempmessages.toString());
    if (tempmessages.isNotEmpty) {
      tempmessages.removeWhere(
          (element) => !element.contains("SIN") && !element.contains("val"));
    }


  }



     saveMessages(List<MessageDet> newmessages) {
    if (newmessages.isNotEmpty) {
      DataProvider().getData(DataProvider.contactsList).then((value) async {
        List<String> contatcs = jsonDecode(value!).cast<String>();
      //  List<MessageDet> regularmessages = [];

        newmessages.forEach((element) {
          try {
            contatcs.add(
                element.message.split("=")[3].split('\$')[4].toString());
          }
          catch(err){}
        });

        List<String> noDuplicates = contatcs.toSet().toList();

        newmessages.forEach((element) {
          messages.add(element);
        });


        noDuplicates.forEach((element) async {
          var d = await DataProvider().getData(element);
          if (d != null) {
            var list = messageDetListFromJson(d);
          //  debugPrint(list.toString());
            list.forEach((element) {
              messages.add(MessageDet(
                  type: element.type,
                  time: element.time,
                  userId: element.userId,
                  message: element.message));
            });

            if(list.isEmpty){

            }
          }

          //
          // for(int i=0;i<=messages.length;i++){
          //   for(int j=0;i<=newmessages.length;j++){
          //
          //     try {
          //       if (messages
          //           .elementAt(i)
          //           .message
          //           .split("=")[3].split("\$")[2] == newmessages
          //           .elementAt(i)
          //           .message
          //           .split("=")[3].split("\$")[2]) {} else {
          //         regularmessages.add(newmessages.elementAt(j));
          //       }
          //     }catch(ryt) {}
          //   }
          // }


       //   debugPrint(messages.length.toString());
          await DataProvider().box.write(
              element,
              messageDetListToJson(messages
                  .where((element1) =>
                      element1.message.contains(element) ||
                      element1.userId.contains(element))
                  .toList()));
        });



        await DataProvider()
            .setData(DataProvider.contactsList, json.encode(noDuplicates));
      //  debugPrint(noDuplicates.toString());
      });
    }
  }
}


