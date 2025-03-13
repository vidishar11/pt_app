// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:permission_handler/permission_handler.dart';
// class Message {
//
//   String text;
//   String text;
//
//   Message(this.text);
// }
// class BluetoothProvider extends ChangeNotifier {
//   List<BluetoothDevice> _pairedDevices = [];
//   BluetoothConnection? _bluetoothConnection ;
//   BluetoothState? _bluetoothState;
//   Timer? _timer;
//   String _s = "N";
//   List<String> messages = List<String>.empty(growable: true);
//   String _messageBuffer = '';
//   BluetoothConnection? get bluetoothConnection => _bluetoothConnection;
//   String get s => _s;
//
//
//   Future<bool> initState() {
//   return  FlutterBluetoothSerial.instance.isEnabled.then((value) async {
//  if (value == false) {
//         FlutterBluetoothSerial.instance.requestEnable().then((value) {
//           if (value!) {
//             initState();
//           } else {
//             FlutterBluetoothSerial.instance.openSettings();
//            // initState();
//           }
//         });
//         return false;
//       } else {
//
//
//         var status = await Permission.bluetooth.status;
//
//         if(!status.isGranted){
//
//        //   await Permission.bluetooth.request();
//           await Permission.bluetoothConnect.request();
//         }else{
//
//         }
//
//         notifyListeners();
//
//       }
//       return value!;
//     });
//
//   }
//
//   void startListiner(){
//     debugPrint("Listen Started");
//     FlutterBluetoothSerial.instance.onStateChanged().listen((event) {
//       debugPrint("Listen Started");
//       if (event.isEnabled == false) {
//        // initState();
//       }else{
//      //   getPairedDevices();
//       }
//       _bluetoothState = event;
//       notifyListeners();
//     });
//   }
//
//   Future<List<BluetoothDevice>> getPairedDevices() {
//
//     return FlutterBluetoothSerial.instance.getBondedDevices().then((value) async {
//       if (value.isEmpty) {
//       } else {
//         _pairedDevices.addAll(value);
//       var pariedList =  value.where((element) => element.name!.contains("ESP") || element.name!.contains("PT")).toList();
//       if(pariedList.isNotEmpty){
//         debugPrint(pariedList.first.name);
//
//        await  BluetoothConnection.toAddress(pariedList.first.address).then((value2) async {
//
//      //    notifyListeners();
//          _s = "YY";
//            debugPrint("At Connected");
//
//            _bluetoothConnection = value2;
//
//            _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("prop get idp model\r\n")));
//            _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("prop get idp mobileID\r\n")));
//       //   _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("prop get idp model\r\n")));
//        //  _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("prop get idp mobileID\r\n")));
//          _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("prop get position speed\r\n")));
//        //  _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("prop get position altitude\r\n")));
//        //  _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("prop get position fixType\r\n",)));
//        //  _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode( "prop get position longitude\r\n")));
//        //  _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode( "prop get position latitude\r\n")));
//        //  _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("prop get idp satState\r\n")));
//        //  _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("readMTM\r\n")));
//            _bluetoothConnection!.output.allSent;
//          //  getMEssagesListiner();
//            Uint8List _data = Uint8List(0);
//
//          dynamic even =[];
//
//
//
//         _bluetoothConnection!.input!.listen(_onDataReceived).onDone(() {
//           // Example: Detect which side closed the connection
//           // There should be `isDisconnecting` flag to show are we are (locally)
//           // in middle of disconnecting process, should be set before calling
//           // `dispose`, `finish` or `close`, which all causes to disconnect.
//           // If we except the disconnection, `onDone` should be fired as result.
//           // If we didn't except this (no flag set), it means closing by remote.
//           // if (isDisconnecting) {
//              print('Disconnecting locally!');
//           // } else {
//           //   print('Disconnected remotely!');
//           // }
//           // if (this.mounted) {
//           //   setState(() {});
//           // }
//         });
//
//           // _bluetoothConnection = value;
//
//          //  notifyListeners();
//            notifyListeners();
//            return value2;
//          });
//       }else{
//         notifyListeners();
//       }
//       }
//
//     //  debugPrint(_bluetoothConnection!.isConnected.toString());
//   //    notifyListeners();
//       return value;
//     });
//   }
//
//
//   void getMEssagesListiner(){
//
//
//     _timer = Timer.periodic(Duration(seconds: 5), (timer) {
//       // Put the code you want to run periodically here
//    ///   "prop get idp satState\r\n",
//     ///  "prop get position latitude\r\n",
//     ///  "prop get position longitude\r\n",
//     ///  "prop get idp model\r\n",
//      /// "prop get idp firmwareRevision\r\n",
//     ///  "prop get idp satState\r\n",
//     //  "prop get position fixType\r\n",
//      /// "prop get position altitude\r\n",
//      /// "prop get position speed\r\n",
//       //"prop get system systemTime\r\n",
//       //"prop get system terminalUptime\r\n",
//       //"prop get power extPowerVoltage\r\n",
//      /// "prop get idp mobileID\r\n",
//       _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("prop get idp model\r\n")));
//       _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("prop get idp mobileID\r\n")));
//       _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("prop get position speed\r\n")));
//       _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("prop get position altitude\r\n")));
//       _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("prop get position fixType\r\n",)));
//       _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode( "prop get position longitude\r\n")));
//       _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode( "prop get position latitude\r\n")));
//       _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("prop get idp satState\r\n")));
//       _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("readMTM\r\n")));
//       _bluetoothConnection!.output.allSent;
//       notifyListeners();
//       notifyListeners();
//
//       print("This code runs every 1 seconds");
//     });
//
//
//   }
//
//   BluetoothState? get bluetoothState => _bluetoothState;
//
//
//
//
//   void _onDataReceived(Uint8List data) {
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
//
//     // Create message if there is new line character
//     String dataString = String.fromCharCodes(buffer);
//     int index = buffer.indexOf(13);
//     if (~index != 0) {
//
//         messages.add(backspacesCounter > 0
//                 ? _messageBuffer.substring(
//                 0, _messageBuffer.length - backspacesCounter)
//                 : _messageBuffer + dataString.substring(0, index),
//
//         );
//         _messageBuffer = dataString.substring(index);
//
//     } else {
//       _messageBuffer = (backspacesCounter > 0
//           ? _messageBuffer.substring(
//           0, _messageBuffer.length - backspacesCounter)
//           : _messageBuffer + dataString);
//     }
//
//    messages.forEach((element) {
//
//      debugPrint(element);
//
//    });
//     debugPrint(messages.length.toString());
//
//   }
//
//
// }
//
