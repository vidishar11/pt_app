import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_6.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_9.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stmcht/bluetoothProvider/CommandHandler.dart';
import 'package:stmcht/bluetoothProvider/bluetoothConnectionprovider.dart';
import 'package:stmcht/dataPreferences/DataProvider.dart';
import 'package:stmcht/main.dart';
import 'package:uuid/uuid.dart';

import '../../bluetoothProvider/bluetoothSerialCommandsProvider.dart';
class ChatDetails extends StatefulWidget {

  final String address;
   ChatDetails({super.key,required this.address});

  @override
  State<ChatDetails> createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  BluetoothConnection? connection;
  List<String> messages =[];
  BluetootlSerialProvider serialProvider = BluetootlSerialProvider();
  List<String> tempmessages =[];
  String _messageBuffer='';
  List<MessageDet> mmessgaestoadd =[];

  TextEditingController editingController = TextEditingController();
  List<String> contacts=[];
  List<types.Message> _messages = [];
  // List<MessageDet> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );
  final _usercd = const types.User(
    id: '82093408-a484-4a89-ae75-a22bf8d6f3ac',
  );
  @override
  void initState() {
    super.initState();
   //

    DataProvider().getData(widget.address).then((value) {

      if(value==null){
        return;
      }
      mmessgaestoadd =  messageDetListFromJson(value);
    //  mmessgaestoadd = mmessgaestoadd.reversed.toList();
     // mmessgaestoadd.removeWhere((element) => !element.message.contains("SIN") && !element.message.contains("MIN") && !element.message.contains("val"));
      setState(() {

      });

    });

  }

  Future<void> _addMessage(types.Message message) async {


   // serialProvider.disconnect();

    DataProvider().getData(DataProvider.bt_c).then((value){

      if(value!=null){
        serialProvider.connectToDevice(BluetoothDevice(address: value)).then((value) async {
          if(value){
            String textmessage = editingController.text;
            String destination = widget.address=="CS"?"":"1234";
            String transmissionMode = widget.address=="CS"?"cs":"de";
            String cmd = "sendMOM \"$textmessage\" \"$destination\" \"$transmissionMode\"\r\n";
            mmessgaestoadd.insert(0,MessageDet(type: "send",time: DateTime.now().toString(),userId:widget.address,message: editingController.text));
            await  DataProvider().box.write(widget.address, messageDetListToJson(mmessgaestoadd.toList()));
            serialProvider.sendCommand(cmd);
            editingController.clear();
            setState(() {
            });
          }else{

          }
        });


      }
    });


  }


  @override
  void dispose() {

    mmessgaestoadd = [];
 //   DataProvider().box.write(widget.address, json.encode(mmessgaestoadd.toList()));
    // TODO: implement dispose
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return  Scaffold(appBar: AppBar(title: Text(widget.address=="CS"?"Control Station":widget.address),),

      body: Column(

       crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(physics: ScrollPhysics(),reverse: true,itemCount: mmessgaestoadd.length, itemBuilder: (BuildContext context, int index) {

                debugPrint(mmessgaestoadd.elementAt(index).toJson().toString());
                return GestureDetector(
                  onTap: (){
                    if(mmessgaestoadd.elementAt(index).type!="send"){

                    //    debugPrint(mmessgaestoadd.elementAt(index).message.split("=")[3].split("\$")[4]);
                    //   debugPrint(mmessgaestoadd.elementAt(index).message.split("=")[3].split("\$")[8]);
                    //  debugPrint(mmessgaestoadd.elementAt(index).message.split("=")[3].split("\$")[10]);
                      context.pushNamed(navigation,queryParameters:{"name":mmessgaestoadd.elementAt(index).message.split("=")[3].split("\$")[4],"long":mmessgaestoadd.elementAt(index).message.split("=")[3].split("\$")[8],"lat":mmessgaestoadd.elementAt(index).message.split("=")[3].split("\$")[10]} );
                    //  context.pushNamed(navigation,queryParameters:{"name":mmessgaestoadd.elementAt(index).message.split("=")[3].split("\$")[4],"lat":"12.927633","long":"50.850311"} );
                    }
                  },
                  child: mmessgaestoadd.elementAt(index).type=="send"?
                  ChatBubble(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.all(20),
                    elevation: 5,
                    child: Text(
                      mmessgaestoadd.elementAt(index).type == "send"
                          ? mmessgaestoadd.elementAt(index).message
                          : mmessgaestoadd.elementAt(index).message.split("=")[3].isNotEmpty
                          ? mmessgaestoadd.elementAt(index).message.split("=")[3].split("\$")[6]
                          : "",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backGroundColor: Colors.indigo,
                    clipper: ChatBubbleClipper6(
                      type: mmessgaestoadd.elementAt(index).type == "send"
                          ? BubbleType.sendBubble
                          : BubbleType.receiverBubble,
                    ),
                  ):
                  ChatBubble(
                    elevation: 5,
                    child: Text(
                      mmessgaestoadd.elementAt(index).type == "send"
                          ? mmessgaestoadd.elementAt(index).message
                          : mmessgaestoadd.elementAt(index).message.split("=").length > 3 &&
                          mmessgaestoadd.elementAt(index).message.split("=")[3].isNotEmpty
                          ? mmessgaestoadd
                          .elementAt(index)
                          .message
                          .split("=")[3]
                          .split("\$")
                          .length > 6
                          ? mmessgaestoadd
                          .elementAt(index)
                          .message
                          .split("=")[3]
                          .split("\$")[6]
                          : ""
                          : "",
                      style: TextStyle(color: Colors.white),
                    ),
                    backGroundColor: Colors.indigo,
                    clipper: ChatBubbleClipper6(
                      type: mmessgaestoadd.elementAt(index).type == "send"
                          ? BubbleType.sendBubble
                          : BubbleType.receiverBubble,
                    ),
                  ),
                );

              },),
            ),
          ),
           SizedBox(
             height: 100,
             child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Container(

              decoration: BoxDecoration(color: Colors.grey.shade100),// Customize the background color
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  // Add your custom widgets here

                  Expanded(
                    child: TextFormField(
                      maxLength: 60,
                      controller: editingController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.send),
                      onPressed: (){

                        final textMessage = types.TextMessage(
                          author: _user,
                          createdAt: DateTime.now().millisecondsSinceEpoch,
                          id: const Uuid().v4(),
                          text: editingController.text,
                        );


                          _addMessage(textMessage);
                        // editingController.clear();
                      }

                  ),
                ],
              ),
          ),
        ),
      ),
           )
        ],
      ),
    );
  }


}
