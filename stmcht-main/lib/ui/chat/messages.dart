import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get_secure_storage/get_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stmcht/bluetoothProvider/bluetoothConnectionprovider.dart';
import 'package:stmcht/dataPreferences/DataProvider.dart';
import 'package:stmcht/main.dart';

import '../../bagroundProvider/BackgroundProvider.dart';

class Messages extends StatefulWidget {
  final String address;
   Messages({super.key,required this.address});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {

  List<String>  contacts = [];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(appBar: AppBar(title: Text("Messages"),),body: ListView.builder(padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),itemCount: contacts.length, itemBuilder: (BuildContext context, int index) {
      return Card(
        elevation: 2,
        child: ListTile(tileColor: Colors.grey.shade100,textColor: Colors.indigo,titleTextStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),onTap: (){

          context.pushNamed(chatmessage,queryParameters: {"address":contacts.elementAt(index)});

        },leading: Container(decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.indigo),child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            contacts.elementAt(index) == "CS"
                ? "CS"
                : contacts.elementAt(index).toString().isNotEmpty
                ? contacts.elementAt(index).toString().substring(0, 1)
                : "",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        )),title: Text(contacts.elementAt(index)=="CS"?"Control Station":contacts.elementAt(index)),
        //   trailing: Container(decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.indigo),child: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Text(index.toString(),style: TextStyle(color: Colors.white),),
        // )),

        ),
      );
    },),);
  }


  @override
  void initState() {
    // TODO: implement initState

    DataProvider().getData(DataProvider.contactsList).then((value) {


      List<String> contatcs =   jsonDecode(value!).cast<String>();
  //    contacts.add();

      contatcs.forEach((element) {
        contacts.add(element);
      });

      setState(() {

      });
    });



    super.initState();
  }




  @override
  void dispose() {

    // TODO: implement dispose
    super.dispose();
  }
}
