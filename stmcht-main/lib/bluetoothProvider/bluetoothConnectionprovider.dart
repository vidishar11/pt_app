// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:stmcht/dataPreferences/DataProvider.dart';
//
// // To parse this JSON data, do
// //
// //     final message = messageFromJson(jsonString);
// // To parse this JSON data, do
// //
// //     final messageDet = messageDetFromJson(jsonString);
//
import 'dart:convert';

List<MessageDet> messageDetListFromJson(String str) =>
    List<MessageDet>.from(json.decode(str).map((x) => MessageDet.fromJson(x)));

String messageDetListToJson(List<MessageDet> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
MessageDet messageDetFromJson(String str) =>
    MessageDet.fromJson(json.decode(str));

String messageDetToJson(MessageDet data) => json.encode(data.toJson());

class MessageDet {
  String userId;
  String message;
  String time;
  String type;

  MessageDet(
      {required this.userId,
      required this.message,
      required this.time,
      required this.type});

  factory MessageDet.fromJson(Map<String, dynamic> json) => MessageDet(
        userId: json["userId"],
        time: json["time"],
        type: json['type'],
        message: json["message"],
      );

  Map<String, dynamic> toJson() =>
      {"userId": userId, "message": message, "type": type, "time": time};
}
//
// class BluetoothConnectionProvider extends ChangeNotifier {
//   List<MessageDet> messages = [];
//   List<String> tempmessages = [];
//   List<String> batterystatus = [];
//   List<String> deviceinfo = [];
//   List<String> matterystatus = [];
//   List<String> cordiantesbroadcast = [];
//   BluetoothConnection? _bluetoothConnection;
//   String _messageBuffer = '';
//   Timer? timer;
//   BluetoothConnection? get bluetoothConnection => _bluetoothConnection;
//
//   set bluetoothConnection(BluetoothConnection? value) {
//     _bluetoothConnection = value;
//   }
//
//   Future<bool> checkConnection(String address) {
//     return FlutterBluetoothSerial.instance.isConnected.then((value) => value);
//   }
//
//   Future<BluetoothConnection> connetDevice(String address) {
//     return BluetoothConnection.toAddress(address)
//         .then((value) => value)
//         .catchError((error) {
//       startTimeer(true);
//     });
//   }
//
//   Future<void> sendMessages(String cmds, String type) async {
//     _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode(cmds)));
//     _bluetoothConnection!.output.allSent;
//   }
//
//   Future<void> lisitienMessages(String type) async {
//     if (_bluetoothConnection!.isConnected) {
//       _bluetoothConnection!.input!.listen(_onDataReceivedMessages).onDone(() {
//         messages = [];
//         List<MessageDet> newmessages = [];
//         tempmessages.forEach((element) {
//           if (element.contains("MIN")) {
//             newmessages.add(MessageDet(
//                 type: "received",
//                 time: DateTime.now().toString(),
//                 userId: "received",
//                 message: element));
//
//           } else if (element.contains("batterylevel")) {
//             batterystatus.add(element);
//           } else if (element.contains("PIN")) {
//             deviceinfo.add(element);
//           }
//          // debugPrint(element);
//         });
//
//         newmessages.isEmpty?null:saveMessages(newmessages);
//        // debugPrint("Messages lenght" + messages.length.toString());
//        // debugPrint("Battery Level lenght" + batterystatus.length.toString());
//         if (timer == null) {
//           startTimeer(false);
//         }
//       //  debugPrint("At Done");
//       });
//     }
//   }
//
//   void stopTimer() {
//   //  debugPrint("stoooper Cancled");
//     timer!.cancel();
//     notifyListeners();
//   }
//
//   void startTimeer(bool first) {
//     if (first) {
//       DataProvider().getData(DataProvider.bt_c).then((address) {
//         if (address != null) {
//           checkConnection(address).then((connected) {
//             if (connected) {
//           //    debugPrint("Already connected");
//             } else {
//               connetDevice(address).then((value) {
//                 debugPrint("request connected");
//                 _bluetoothConnection = value;
//
//                 List<String> deviceCommands = [
//                   "prop get idp model\r\n",
//                   "prop get idp mobileID\r\n",
//                   "prop get idp satState\r\n",
//                   "prop get idp firmwareRevision\r\n",
//                   "prop get position speed\r\n",
//                   "prop get position altitude\r\n",
//                   "prop get position fixType\r\n",
//                   "prop get position longitude\r\n",
//                   "prop get position latitude\r\n",
//                   "readMTM\r\n",
//                   "prop get 132 220\r\n"
//                 ];
//
//                 List<String> messages = [
//                   "readMTM\r\n",
//                 ];
//                 List<String> battery = [
//                   "prop get 132 220\r\n",
//                 ];
//                 lisitienMessages("DeviceInfo");
//
//                 //  sendMessages(battery[0], "DeviceInfo");
//                 //  sleep(Duration(seconds: 2));
//                 sendMessages(messages[0], "Messages");
//                 sleep(Duration(seconds: 2));
//
//                 //  value.output.add(Uint8List.fromList(utf8.encode("prop get idp model\r\n")));
//                 //   value.output.allSent;
//                 //   lisitienMessages("DeviceInfo");
//               });
//             }
//           });
//         }
//       });
//     } else {
//      // debugPrint("listiner Periodic Started");
//       if (_bluetoothConnection != null) {
//         _bluetoothConnection!.finish();
//         _bluetoothConnection!.close();
//       }
//       timer = Timer.periodic(Duration(minutes: 2), (timer) {
//      //   debugPrint(timer.toString());
//      //   debugPrint("listiner Periodic at False Started");
//         DataProvider().getData(DataProvider.bt_c).then((address) {
//           if (address != null) {
//             checkConnection(address).then((connected) {
//               if (connected) {
//              //   debugPrint("Already connected");
//               } else {
//                 connetDevice(address).then((value) {
//                   debugPrint("request connected");
//                   _bluetoothConnection = value;
//
//                   List<String> deviceCommands = [
//                     "prop get idp model\r\n",
//                     "prop get idp mobileID\r\n",
//                     "prop get idp satState\r\n",
//                     "prop get idp firmwareRevision\r\n",
//                     "prop get position speed\r\n",
//                     "prop get position altitude\r\n",
//                     "prop get position fixType\r\n",
//                     "prop get position longitude\r\n",
//                     "prop get position latitude\r\n"
//                   ];
//
//                   List<String> messages = [
//                     "readMTM\r\n",
//                   ];
//                   List<String> battery = [
//                     "prop get 132 220\r\n",
//                   ];
//
//                   tempmessages = [];
//                   lisitienMessages("DeviceInfo");
//                   sendMessages(battery[0], "DeviceInfo");
//                   sleep(Duration(seconds: 3));
//                   sendMessages(messages[0], "Messages");
//                   sleep(Duration(seconds: 2));
//                 }).catchError((error) {
//                   debugPrint("DeviceConnecting erro at Timer Call");
//                 });
//               }
//             });
//           }
//         });
//       });
//     }
//   }
//
//   void _onDataReceivedMessages(Uint8List data) {
//     // Allocate buffer for parsed data
//     int backspacesCounter = 0;
//     data.forEach((byte) {
//       if (byte == 8 || byte == 127) {
//         backspacesCounter++;
//       }
//     });
//     Uint8List buffer = Uint8List(data.length - backspacesCounter);
//     int bufferIndex = buffer.length;
//
//     // Apply backspace control character
//     backspacesCounter = 0;
//     for (int i = data.length - 1; i >= 0; i--) {
//       if (data[i] == 8 || data[i] == 127) {
//         backspacesCounter++;
//       } else {
//         if (backspacesCounter > 0) {
//           backspacesCounter--;
//         } else {
//           buffer[--bufferIndex] = data[i];
//         }
//       }
//     }
//     // Create message if there is new line character
//     String dataString = String.fromCharCodes(buffer);
//    // debugPrint(dataString);
//     if (dataString.contains("^")) {
//       _bluetoothConnection!.finish();
//     }
//     int index = buffer.indexOf(13);
//     if (~index != 0) {
//       tempmessages.add(
//         backspacesCounter > 0
//             ? _messageBuffer.substring(
//                 0, _messageBuffer.length - backspacesCounter)
//             : _messageBuffer + dataString.substring(0, index),
//       );
//       _messageBuffer = dataString.substring(index);
//     } else {
//       _messageBuffer = (backspacesCounter > 0
//           ? _messageBuffer.substring(
//               0, _messageBuffer.length - backspacesCounter)
//           : _messageBuffer + dataString);
//     }
//
//     if (tempmessages.isNotEmpty) {
//       tempmessages.removeWhere(
//           (element) => !element.contains("SIN") && !element.contains("val"));
//     }
//
//     //  debugPrint(messages.length.toString());
//
//     //   debugPrint(tempmessages.toString());
//   }
//
//   saveMessages(List<MessageDet> newmessages) {
//     if (newmessages.isNotEmpty) {
//       DataProvider().getData(DataProvider.contactsList).then((value) async {
//         List<String> contatcs = jsonDecode(value!).cast<String>();
//         List<String> regularmessages = [];
//
//         newmessages.forEach((element) {
//           try {
//             contatcs.add(
//                 element.message.split("=")[3].split('\$')[4].toString());
//           }
//           catch(err){}
//         });
//
//         List<String> noDuplicates = contatcs.toSet().toList();
//         noDuplicates.forEach((element) async {
//           var d = await DataProvider().getData(element);
//           if (d != null) {
//             var list = messageDetListFromJson(d);
//             debugPrint(list.toString());
//             list.forEach((element) {
//            //   debugPrint("listiner");
//             //  debugPrint(element.toJson().toString());
//               messages.add(MessageDet(
//                   type: element.type,
//                   time: element.time,
//                   userId: element.userId,
//                   message: element.message));
//             //  debugPrint("listiner");
//             });
//           }
//
//
//           newmessages.forEach((element) {
//             messages.add(element);
//           });
//
//        //   debugPrint(messages.length.toString());
//           await DataProvider().box.write(
//               element,
//               messageDetListToJson(messages
//                   .where((element1) =>
//                       element1.message.contains(element) ||
//                       element1.userId.contains(element))
//                   .toList()));
//         });
//         await DataProvider()
//             .setData(DataProvider.contactsList, json.encode(noDuplicates));
//       //  debugPrint(noDuplicates.toString());
//       });
//     }
//   }
// }
