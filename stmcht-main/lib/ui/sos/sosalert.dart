import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../bluetoothProvider/bluetoothSerialCommandsProvider.dart';
import '../../dataPreferences/DataProvider.dart';
import '../../main.dart';

class SosAlert extends StatefulWidget {

  final String address;
   SosAlert({super.key,required this.address});

  @override
  State<SosAlert> createState() => _SosAlertState();
}

class _SosAlertState extends State<SosAlert> {
  BluetootlSerialProvider bluetootlSerialProvider = BluetootlSerialProvider();
  bool connection = true;
  List<String> messages =[];
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return  Scaffold(appBar: AppBar(title: Text("SOS"),),
    body: ListView(
        children: [
         connection?const Center(child: Padding(
           padding: EdgeInsets.all(8.0),
           child: CircularProgressIndicator(),
         ),): Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            child: Card(  elevation: 2,  shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(color: Colors.grey)
              // Adjust the radius as needed
            ),
              child: ListView.builder(physics: NeverScrollableScrollPhysics(),shrinkWrap: true,itemCount: messages.length, itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(messages.elementAt(index).split(" ")[1].contains("model")?"Model":messages.elementAt(index).split(" ")[1].contains("mobileID")?"Mobile Id":messages.elementAt(index).split(" ")[1].contains("satState")?"Satilite Status":messages.elementAt(index).split(" ")[1].contains("firmwareRevision")?"Version":messages.elementAt(index).split(" ")[1].contains("speed")?"Speed":messages.elementAt(index).split(" ")[1].contains("altitude")?"Altitude":messages.elementAt(index).split(" ")[1].contains("fixType")?"FixType":messages.elementAt(index).split(" ")[1].contains("longitude")?"Longitude":messages.elementAt(index).split(" ")[1].contains("latitude")?"Latitude":""),
                    Text(messages.elementAt(index).split(" ")[2].split("=")[1].toString().replaceAll('"', "")),
                  ],
                ),
              );

            },),),
          ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: CardWid(size, "assets/icons/sos.svg", "Click To Send SOS Alert", connection==null?null: () {

          bluetootlSerialProvider.connectToDevice(BluetoothDevice(address: widget.address)).then((value) async {
            bluetootlSerialProvider.sendCommand('sendMOM "sos" "" ""cs');
            await Future.delayed(Duration(seconds: 1));
      ///      connection!.output.add(Uint8List.fromList(utf8.encode('sendMOM "sos" "" ""cs')));
       //     connection!.output.allSent;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SOS Sent")));
            context.pushReplacementNamed(dashboard);
          });


        }),
      ),

    ]),);
  }

  Widget CardWid(Size size,String asste,String name,Function()? ontap){

    return    GestureDetector(
      onTap:  ontap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: Colors.grey)
          // Adjust the radius as needed
        ),

        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              SizedBox(height: 10,),
              SizedBox(
                height: size.height*0.1,
                width: size.width*0.9,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SvgPicture.asset(
                    asste,
                    semanticsLabel: 'Acme Logo',color: Colors.indigo,
                    height:20.0,
                    width: 20.0,
                  ),
                ),
              ),
              Text(
                name.isNotEmpty ? name : "Unnamed",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 20,)

            ],
          ),
        ),
      ),
    );
  }



  @override
  void initState() {


    bluetootlSerialProvider.connectToDevice(BluetoothDevice(address: widget.address)).then((value) {
   //   connection = value;

      debugPrint("connected");
      setState(() {

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
          messages.add(value!);
        }); DataProvider().getData(DataProvider.latitude).then((value) {
          messages.add(value!);
        });
        DataProvider().getData(DataProvider.speed).then((value) {
          messages.add(value!);
        });
        DataProvider().getData(DataProvider.satstate).then((value) {
          messages.add(value!);
        });

        connection = false;
        setState(() {

        });


      });

    });
    // TODO: implement initState
    super.initState();
  }


  @override
  void dispose() {



    // TODO: implement dispose
    super.dispose();
  }
}

