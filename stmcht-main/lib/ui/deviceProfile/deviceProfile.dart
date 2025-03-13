import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:get_secure_storage/get_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stmcht/bluetoothProvider/bluetoothConnectionprovider.dart';
import 'package:stmcht/dataPreferences/DataProvider.dart';

import '../../bagroundProvider/BackgroundProvider.dart';
import '../../bluetoothProvider/CommandHandler.dart';
import '../../bluetoothProvider/bluetoothSerialCommandsProvider.dart';

class SiVal{

  String name;
  String value;

  SiVal(this.name, this.value);
}
class DeviceProfile extends StatefulWidget {

  final String address;

   DeviceProfile({super.key,required this.address});

  @override
  State<DeviceProfile> createState() => _DeviceProfileState();
}

class _DeviceProfileState extends State<DeviceProfile> {
  BluetoothConnection? connection;
  BluetootlSerialProvider bluetootlSerialProvider = BluetootlSerialProvider();
 List<String> messages = List<String>.empty(growable: true);
 List<SiVal> filanlist = List<SiVal>.empty(growable: true);
 String _messageBuffer = '';
 bool device = false;
 bool type = true;
 bool battery = true;
 bool software = true;
 bool datetime = true;
 bool gpsfix = true;
 bool latitude = true;
 bool longitide = true;
 bool distance = true;
 bool speed = true;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(appBar: AppBar(title: Text("Device Details"),),bottomNavigationBar: messages.length>7? Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(onPressed: () {

        DataProvider().setData(DataProvider.bt_c, widget.address).then((value) async {

          if(device){


            bluetootlSerialProvider.disconnect();
              DataProvider().box.erase().then((value) {
              SnackBar(content: Text("Device Removed"));
            // context.read<BluetoothConnectionProvider>().timer==null?null: context.read<BluetoothConnectionProvider>().stopTimer();
              context.pop();

            });
          }
          else
          {



            // for(int i=0;i<messages.length;i++){
            //
            //   debugPrint(messages.elementAt(i).toString());
            //
            //   if(messages.elementAt(i).contains("satState")!="Active"){
            //
            //     ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text("Device Not Connected ")));
            //
            //     return;
            //     return;
            //
            //   }
            // }



            bluetootlSerialProvider.connectToDevice(BluetoothDevice(address:widget.address )).then((value) async {

              final commandHandler = CommandHandler([
                "prop get idp model\r\n",
                "prop get idp mobileID\r\n",
                "prop get idp satState\r\n",
                "prop get idp firmwareRevision\r\n",
                "prop get position speed\r\n",
                "prop get position altitude\r\n",
                "prop get position fixType\r\n",
                "prop get position longitude\r\n",
                "prop get position latitude\r\n",
                "prop get 132 220\r\n",
                "readMTM \r\n",], bluetootlSerialProvider,widget.address,true);
              await commandHandler.runPeriodicCommands();
            });
            await DataProvider().setData(DataProvider.contactsList,json.encode(["CS"])).then((value) async {
           //   context.read<BluetoothConnectionProvider>().startTimeer(true);

              debugPrint(DataProvider().getData(DataProvider.contactsList).toString());

            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Device Added")));



            for(int i=0;i<messages.length;i++){


              if(messages.elementAt(i).contains("model")){
                await DataProvider().setData(DataProvider.model, messages.elementAt(i));
              }else  if(messages.elementAt(i).contains("mobileID")){
                await DataProvider().setData(DataProvider.mobie_id, messages.elementAt(i));
              }else  if(messages.elementAt(i).contains("satState")){
                await DataProvider().setData(DataProvider.satstate, messages.elementAt(i));
              }else  if(messages.elementAt(i).contains("speed")){
                await DataProvider().setData(DataProvider.speed, messages.elementAt(i));
              }else  if(messages.elementAt(i).contains("altitude")){
                await DataProvider().setData(DataProvider.altitude, messages.elementAt(i));
              }else  if(messages.elementAt(i).contains("fixType")){
                await DataProvider().setData(DataProvider.fixType, messages.elementAt(i));
              }else  if(messages.elementAt(i).contains("longitude")){
                await DataProvider().setData(DataProvider.longitude, messages.elementAt(i));
              }else  if(messages.elementAt(i).contains("latitude")){
                await DataProvider().setData(DataProvider.latitude, messages.elementAt(i));
              }else  if(messages.elementAt(i).contains("firmwareRevision")){
                await DataProvider().setData(DataProvider.frimwareRevision, messages.elementAt(i));
              }
            }
            context.pop();
            context.pop();



          }
        });
      },child:Text(device?"DeRegister Device":"Register Device"),),
    ):SizedBox.shrink(),
        
        body:messages.isEmpty?const Center(child: CircularProgressIndicator(),): Card(
          child: ListView.builder(padding: EdgeInsets.symmetric(horizontal: 15),itemCount: messages.length, itemBuilder: (BuildContext context, int index) {

    //  print(messages.elementAt(index));
      return Card(child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(messages.elementAt(index).split(" ")[1].contains("model")?"Model":messages.elementAt(index).split(" ")[1].contains("mobileID")?"Mobile Id":messages.elementAt(index).split(" ")[1].contains("satState")?"Satilite Status":messages.elementAt(index).split(" ")[1].contains("firmwareRevision")?"Version":messages.elementAt(index).split(" ")[1].contains("speed")?"Speed":messages.elementAt(index).split(" ")[1].contains("altitude")?"Altitude":messages.elementAt(index).split(" ")[1].contains("fixType")?"FixType":messages.elementAt(index).split(" ")[1].contains("longitude")?"Longitude":messages.elementAt(index).split(" ")[1].contains("latitude")?"Latitude":""),
              Text(( messages.elementAt(index).split(" ")[1].contains("longitude") ||messages.elementAt(index).split(" ")[1].contains("latitude")  ) ?( (int.parse(messages.elementAt(index).split(" ")[2].split("=")[1].toString().replaceAll('"', ""))/360000)*6 ).toString():  messages.elementAt(index).split(" ")[2].split("=")[1].toString().replaceAll('"', "")),
            ],
          ),
      ),);
    },),
        )
    );
  }

  @override
  void initState() {


    isDevice();


    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    if(connection!=null) {
      connection!.close();
      connection!.dispose();



    }
    // TODO: implement dispose
    super.dispose();
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
   debugPrint(dataString);
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
     !element.contains("SIN") &&!element.contains("PIN") && !element.contains("val"));
   }

   if(dataString==">"){
     setState(() {

     });
   }


 }

  Future<void> isDevice() async {

    await DataProvider().getData(DataProvider.bt_c).then((value) {

      if(value!=null){
        device= true;

        DataProvider().getData(DataProvider.model).then((value) {
          messages.add(value!);
        });
      DataProvider().getData(DataProvider.mobie_id).then((value) {
          messages.add(value!);
        });

     DataProvider().getData(DataProvider.frimwareRevision).then((value) {
          messages.add(value!);
        });

      DataProvider().getData(DataProvider.fixType).then((value) {
          messages.add(value!);
        });   DataProvider().getData(DataProvider.speed).then((value) {
          messages.add(value!);
        });
        DataProvider().getData(DataProvider.longitude).then((value) {
          debugPrint(value);
          messages.add(value!);
        }); DataProvider().getData(DataProvider.latitude).then((value) {
          debugPrint(value);
          messages.add(value!);
        });
     DataProvider().getData(DataProvider.speed).then((value) {
          messages.add(value!);
        });
     DataProvider().getData(DataProvider.satstate).then((value) {
          messages.add(value!);
        });

        setState(() {

        });



      }else{



        BluetoothConnection.toAddress(widget.address).then((value) async {

      //   context.read<BluetoothConnectionProvider>().timer==null?null:context.read<BluetoothConnectionProvider>().startTimeer(true);

          connection =value;

          value.input!.listen(_onDataReceived);
          List<String> commands = [
            "prop get idp model\r\n",
            "prop get idp mobileID\r\n",
            "prop get idp satState\r\n",
            "prop get idp firmwareRevision\r\n",
            "prop get position speed\r\n",
            "prop get position altitude\r\n",
            "prop get position fixType\r\n",
            "prop get position longitude\r\n",
            "prop get position latitude\r\n"
          ];

          for(int i=0;i<commands.length;i++){

              value.output.add(Uint8List.fromList(utf8.encode(commands.elementAt(i))));
              await value.output.allSent;
              sleep(Duration(milliseconds: 1100));

          }


        }).catchError((error){



        });
      }

    });
  }

}
