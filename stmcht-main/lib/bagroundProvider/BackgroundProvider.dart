import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:stmcht/dataPreferences/DataProvider.dart';

class BackgroundProvider extends ChangeNotifier{


  BluetoothConnection? bluetoothConnection;
  String value = "2";
  int _value2 = 1;

  List<String> messages = List<String>.empty(growable: true);

  String _messageBuffer = '';
  int get value2 => _value2;

  Timer? _timer;

  void stopTimer(){

    _timer!.cancel();
    notifyListeners();
  }
  void startTimer() {
    // Create a timer that runs a function every 5 seconds


    _timer = Timer.periodic(Duration(seconds: 30), (timer) {

      if(bluetoothConnection==null){

      }else{
        sleep(Duration(seconds: 3));
        bluetoothConnection!.finish();
        bluetoothConnection!.close();
      }
      messages = [];

      DataProvider().getData(DataProvider.bt_c).then((value) {

        if(value!=null){
          BluetoothConnection.toAddress(value).then((value) async {

            bluetoothConnection = value;

            value.input!.listen(_onDataReceived);
            List<String> commands = [
              "readMTM \r\n",
           //   "prop get idp model\r\n",
            //  "prop get idp mobileID\r\n",
            //  "prop get idp satState\r\n",
           //   "prop get idp firmwareRevision\r\n",
            //  "prop get position speed\r\n",
           //   "prop get position altitude\r\n",
           //   "prop get position fixType\r\n",
          //    "prop get position longitude\r\n",
          //    "prop get position latitude\r\n"
            ];


            for(int i=0;i<commands.length;i++){

              value.output.add(Uint8List.fromList(utf8.encode(commands.elementAt(i))));
              await value.output.allSent;
              sleep(const Duration(milliseconds: 1000));

            }


            //
            //  value.output.add(Uint8List.fromList(utf8.encode("prop get idp model\r\n")));
            //  await value.output.allSent;
            //
            //  value.output.add(Uint8List.fromList(utf8.encode("prop get idp mobileID\r\n")));
            //  value.output.add(Uint8List.fromList(utf8.encode("prop get position fixType\r\n")));
            //  await value.output.allSent;
            //  sleep(Duration(milliseconds: 2000));
            //  value.output.add(Uint8List.fromList(utf8.encode("prop get idp firmwareRevision\r\n")));
            //  value.output.add(Uint8List.fromList(utf8.encode("prop get position speed\r\n")));
            //  await value.output.allSent;
            //  sleep(Duration(milliseconds: 1000));
            //  value.input!.listen(_onDataReceived);
            //  value.output.add(Uint8List.fromList(utf8.encode("prop get idp satState\r\n")));
            //  value.output.add(Uint8List.fromList(utf8.encode("prop get position altitude\r\n")));
            //  await value.output.allSent;
            //  sleep(Duration(milliseconds: 1000));
            //  value.output.add(Uint8List.fromList(utf8.encode("prop get position longitude\r\n")));
            //  value.output.add(Uint8List.fromList(utf8.encode( "prop get position latitude\r\n")));
            //
            // await value.output.allSent;
            // List<Uint8List> j =[];

          }).catchError((error){
            debugPrint(error.toString());
          });
        }


      });
      // Put the code you want to run periodically here

    });
  }


  void _onDataReceived(Uint8List data) {
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
    // if(dataString=="^"){
    //
    //   bluetoothConnection!.finish();
    //
    // }
    int index = buffer.indexOf(13);
    if (~index != 0) {

      messages.add(backspacesCounter > 0
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
    if(messages.isNotEmpty) {
      messages.removeWhere((element) =>
      !element.contains("SIN") && !element.contains("MIN") &&
          !element.contains("val"));
    }


  //  debugPrint(messages.toString());

  }



}