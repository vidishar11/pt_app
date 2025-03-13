

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stmcht/bluetoothProvider/bluetoothProvider.dart';
import 'package:stmcht/main.dart';

class AddDevice extends StatefulWidget {
  const AddDevice({super.key});

  @override
  State<AddDevice> createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;
  BluetoothConnection? connection;
//  _DiscoveryPage();

  @override
  void initState() {
    super.initState();

    isDiscovering = true;
    if (isDiscovering) {
      _startDiscovery();
    }
  }

  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }



  Future<void> _startDiscovery() async {
    FlutterBluetoothSerial.instance.getBondedDevices().then((value)  {
    //  debugPrint(value.first.toMap().toString());
      });
  // await FlutterBluetoothSerial.instance.requestDisable();
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
          setState(() {
            final existingIndex = results.indexWhere(
                    (element) => element.device.address == r.device.address);
            if (existingIndex >= 0)
              results[existingIndex] = r;
            else
              results.add(r);

          });
        });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  // @TODO . One day there should be `_pairDevice` on long tap on something... ;)

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription?.cancel();

    if(connection!=null) {
      connection!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isDiscovering
            ? Text('Discovering devices')
            : Text('Discovered devices'),
        actions: <Widget>[

        ],
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 5),
              itemCount: results.length,
              itemBuilder: (BuildContext context, index) {
                BluetoothDiscoveryResult result = results[index];
                final device = result.device;
                final address = device.address;
                return BluetoothDeviceListEntry(
                  device: device,
                  rssi: result.rssi,

                  onTap: () async {
                    try {
                      bool bonded = false;
                      if (device.isBonded) {
                          context.pushNamed(deviceprofile,queryParameters: {"address":device.address});
                          //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text( device.name ?? ''+" Device Connected")));
                      } else {
                        print('Bonding with ${device.address}...');
                        bonded = (await FlutterBluetoothSerial.instance
                            .bondDeviceAtAddress(address))!;
                        print(
                            'Bonding with ${device.address} has ${bonded ? 'succed' : 'failed'}.');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text( device.name ?? ''+" Device Paired")));
                        setState(() {

                          results[results.indexOf(result)] = BluetoothDiscoveryResult(
                              device: BluetoothDevice(
                                name: device.name ?? '',
                                address: address,
                                type: device.type,
                                bondState: bonded
                                    ? BluetoothBondState.bonded
                                    : BluetoothBondState.none,
                              ),
                              rssi: result.rssi);
                        });
                      }

                    } catch (ex) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return
                            AlertDialog(
                              title: const Text('Error Occurred While Bonding'),
                              content: Text(
                                ex.toString(),
                                style: const TextStyle(fontSize: 16), // Optional styling for content text
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Close"),
                                ),
                              ],
                            );
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
          isDiscovering
              ? FittedBox(
            child: Container(
              margin: new EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            ),
          )
              :ElevatedButton(onPressed: _restartDiscovery, child: Text("ReScan"))
        ],
      ),
    );
  }
}



class BluetoothDeviceListEntry extends ListTile {
  BluetoothDeviceListEntry({
    required BluetoothDevice device,
    int? rssi,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    bool enabled = true,
  }) : super(
    onTap: onTap,
    onLongPress: onLongPress,
    enabled: enabled,
    leading:
    Icon(Icons.devices), // @TODO . !BluetoothClass! class aware icon
    title: Text(device.name ?? ""),
    subtitle: Text(device.address.toString()),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        device.isConnected
            ? Icon(Icons.import_export)
            : Container(width: 0, height: 0),
        device.isBonded
            ? Icon(Icons.link)
            : Container(width: 0, height: 0),
        rssi != null
            ? Container(
          margin: new EdgeInsets.all(8.0),
          child: DefaultTextStyle(
            style: _computeTextStyle(rssi),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(rssi.toString()),
                Text('dBm'),
              ],
            ),
          ),
        )
            : Container(width: 0, height: 0),

      ],
    ),
  );

  static TextStyle _computeTextStyle(int rssi) {
    /**/ if (rssi >= -35)
      return TextStyle(color: Colors.greenAccent[700]);
    else if (rssi >= -45)
      return TextStyle(
          color: Color.lerp(
              Colors.greenAccent[700], Colors.lightGreen, -(rssi + 35) / 10));
    else if (rssi >= -55)
      return TextStyle(
          color: Color.lerp(
              Colors.lightGreen, Colors.lime[600], -(rssi + 45) / 10));
    else if (rssi >= -65)
      return TextStyle(
          color: Color.lerp(Colors.lime[600], Colors.amber, -(rssi + 55) / 10));
    else if (rssi >= -75)
      return TextStyle(
          color: Color.lerp(
              Colors.amber, Colors.deepOrangeAccent, -(rssi + 65) / 10));
    else if (rssi >= -85)
      return TextStyle(
          color: Color.lerp(
              Colors.deepOrangeAccent, Colors.redAccent, -(rssi + 75) / 10));
    else
      /*code symmetry*/
      return TextStyle(color: Colors.redAccent);
  }
}
