import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';
import 'package:stmcht/bluetoothProvider/bluetoothProvider.dart';
import 'package:stmcht/dataPreferences/DataProvider.dart';

class BatterStatus extends StatefulWidget {
  const BatterStatus({super.key});

  @override
  State<BatterStatus> createState() => _BatterStatusState();
}

class _BatterStatusState extends State<BatterStatus> {
  TextStyle head = TextStyle(fontWeight: FontWeight.bold,fontSize: 18);
  TextStyle subs = TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.indigo);
  String batttery = "1";
  String deviceName = "";
  @override
  Widget build(BuildContext context)  {
    return  Scaffold(appBar: AppBar(title:Text("Battery Status") ),body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(elevation: 5,child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [


                SizedBox(height: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                Text("Device Id",style: head,),
                Text(deviceName,style: subs,),
              ],),
                SizedBox(height: 10,),
                Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                Text("Type ",style: head,),
                Text("Personal Tracker",style: subs,),
              ],),
                SizedBox(height: 10,),
                Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                Text("Battery ",style: head,),
                Text(batttery,style: subs,),
              ],),
                SizedBox(height: 10,),
                Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                Text("Running",style: head,),
                Text(GetTimeAgo.parse(DateTime.now().subtract(Duration(days: 2,hours: 3,minutes: 2))),style: subs,),
              ],),
                SizedBox(height: 10,),


                Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Text("DateTime",style: head,),
                Text(TimeOfDay.now().hour.toString()+ " : "+TimeOfDay.now().minute.toString(),style: subs,),
              ],),


            ],),
          )),
        ),
      ],
    ),);
  }

  @override
  void initState() {
    getDevice();

    // TODO: implement initState
    super.initState();
  }

  getDevice() async {
    await DataProvider().getData(DataProvider.batterylevel).then((value) {

      if(value!=null){
        batttery= value.toString().split("=")[3];
      }
    });
    await DataProvider().getData(DataProvider.mobie_id).then((value) {

      if(value!=null){
        deviceName= "PT"+value.toString().split("=")[3].replaceAll("\"", "").substring(11,15);
      }
    });

    setState(() {

    });
    // if(   context.read<BluetoothProvider>().bluetoothConnection!=null ){
    //
    //   if( context.read<BluetoothProvider>().bluetoothConnection!.isConnected) {
    //     context
    //         .read<BluetoothProvider>()
    //         .bluetoothConnection!
    //         .output
    //         .add(Uint8List.fromList(utf8.encode("prop get idp mobileID\r\n")));
    //     await context
    //         .read<BluetoothProvider>()
    //         .bluetoothConnection!
    //         .output
    //         .allSent;
    //     //  var d =await    context.read<BluetoothProvider>().bluetoothConnection!.input!.toList();
    //
    //     //  debugPrint(d.toString());
    //
    //
    //   }
    // }

  }
}
