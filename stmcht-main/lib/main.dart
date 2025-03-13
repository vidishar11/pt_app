import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_secure_storage/get_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:stmcht/dataPreferences/DataProvider.dart';
import 'package:stmcht/ui/batterystatus/batterStatus.dart';
import 'package:stmcht/ui/chat/chatdetails.dart';
import 'package:stmcht/ui/chat/messages.dart';
import 'package:stmcht/ui/deviceProfile/adddevice.dart';
import 'package:stmcht/ui/deviceProfile/deviceProfile.dart';
import 'package:stmcht/ui/maps/NavigationMap.dart';
import 'package:stmcht/ui/sos/sosalert.dart';
import 'bagroundProvider/BackgroundProvider.dart';
import 'bluetoothProvider/CommandHandler.dart';
import 'bluetoothProvider/bluetoothConnectionprovider.dart';
import 'bluetoothProvider/bluetoothSerialCommandsProvider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetSecureStorage.init(password: 'strongpassword');
  runApp(

      MultiProvider(providers: [
        //    ChangeNotifierProvider(create: (_) => BluetoothConnectionProvider()),
        ChangeNotifierProvider(create: (_) => BluetootlSerialProvider()),
        ChangeNotifierProvider(create: (_) => BackgroundProvider()),

      ],child: MyApp(),));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key) {
    _initLogging();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: false,
      ),
      //   home: const MyHomePage(title: 'Dashboard'),
    );
  }

  void _initLogging() {
    // Print output to console.
    Logger.root.onRecord.listen((LogRecord r) {
      print('${r.time}\t${r.loggerName}\t[${r.level.name}]:\t${r.message}');
    });

    // Root logger level.
    Logger.root.level = Level.FINEST;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _bluetoothClassicPlugin = BluetoothClassic();
  BluetootlSerialProvider bluetootlSerialProvider = BluetootlSerialProvider();
  late BackgroundProvider backgroundProvider;
  String? address;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
        backgroundColor: Colors.indigo,
        appBar: AppBar(
          elevation: 0,
          leading: const Icon(Icons.menu, size: 40),
          actions: [
            GestureDetector(
              onTap: () {
                context.pushNamed(addDevice);
              },
              child: SizedBox(
                height: 50,
                width: 50,
                child: SvgPicture.asset(

                  "assets/icons/Satellite-Base-Station.svg",
                  semanticsLabel: 'Acme Logo', color: Colors.white,

                ),
              ),
            )

          ],
          backgroundColor: Colors.indigo,

          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          //    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          // title: Text(widget.title),
        ),
        body: Column(

            children: [
              Container(height: size.height * 0.1,
                decoration: const BoxDecoration(color: Colors.indigo,),
                child: const Align(alignment: Alignment.centerLeft, child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text("Dashboard", style: TextStyle(color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),),
                )),),
              Expanded(
                  child: Container(decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(50),
                          topLeft: Radius.circular(50))),

                    child: ListView(children: [
                      const SizedBox(height: 50,),

                      Row(

                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [

                          cardWid(size, "assets/icons/backpack.svg",
                              "Device Profile", () => pustScreen(1)),

                          cardWid(size, "assets/icons/battery-status.svg",
                              "Battery Status", () => pustScreen(2)),

                        ],),
                      const SizedBox(height: 20,),
                      Row(

                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [

                          cardWid(size, "assets/icons/map-navigation.svg",
                              "Navigation Map", () => pustScreen(3)),
                          cardWid(size, "assets/icons/message.svg",
                              "Chat Messenger", () => pustScreen(4)),

                        ],),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: cardWid(
                            size, "assets/icons/sos.svg", "SOS Alert", () =>
                            pustScreen(5)),

                           //Text(     context.watch<BackgroundProvider>().value2.toString()),

                            // context.watch<BluetoothProvider>().bluetoothConnection==null? Container(height: 30,color:Colors.red.shade400,child: Center(child: Text("Device Not Connected",style: TextStyle(color: Colors.white),)),):  Container(height: 30,color:context.read<BluetoothProvider>().bluetoothConnection!.isConnected? Colors.green.shade400:Colors.red.shade400,child: Center(child: Text(context.read<BluetoothProvider>().bluetoothConnection!.isConnected?" Devive  Connected":"Device  Not Connected",style: TextStyle(color: Colors.white),)),)

                      ),

                    ],
                    ),))
              // This trailing comma makes auto-formatting nicer for build methods.
            ]));
  }


  @override
  void initState() {
    // TODO: implement initState


    _bluetoothClassicPlugin.initPermissions().then((value) {
      // DataProvider().getData(DataProvider.bt_c).then((value) {
      //   if(value!=null) {
      //     context.read<BluetoothConnectionProvider>()
      //         .checkConnection(value)
      //         .then((value) {
      //       debugPrint(value.toString());
      //     });
      //   }
      // });

    }).catchError((err) {
      debugPrint("All redy Connecteds");
      debugPrint(err.toString());
    });


    DataProvider().getData(DataProvider.bt_c).then((value) async {
      if (value != null) {
        address = value;
        bluetootlSerialProvider.connectToDevice(BluetoothDevice(address: value)).then((value1) async {

          final commandHandler = CommandHandler([


            "prop get idp satState\r\n",
            "prop get position speed\r\n",
            "prop get position altitude\r\n",
            "prop get position longitude\r\n",
            "prop get position latitude\r\n",
            "prop get 132 220\r\n",
            "readMTM \r\n",], bluetootlSerialProvider,value,true);
          await commandHandler.runPeriodicCommands();
          //   bluetootlSerialProvider.sendCommand("readMTM \r\n");
          //  bluetootlSerialProvider.sendCommand("readMTM \r\n");

        });



        //  final commandHandler = CommandHandler(dynamicCommands, bluetoothService);
        // await commandHandler.runPeriodicCommands();

        //  context.read<BluetoothConnectionProvider>().startTimeer(true);
        //   context.read<BluetoothConnectionProvider>().checkConnection(value).then((value) {
        //
        //     if(value){
        //
        //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //         backgroundColor: Colors.indigo,
        //         content: Text("Device Connected"),
        //         duration: Duration(minutes: 2),
        //       ));
        //     }
        //     else {
        //
        //
        //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //         backgroundColor: Colors.indigo,
        //         content: Text("Device Not Connected Trying to Connected"),
        //         duration: Duration(seconds: 2),
        //       ));
        //     }
        //
        //   });

        //  context.read<BackgroundProvider>().startTimer();
        //  debugPrint(value.toString());
        debugPrint(value.toString());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.indigo,
          content: const Text("No Device Registred "),
          duration: const Duration(minutes: 2),
          action: SnackBarAction(
              label: "Click To Connect", textColor: Colors.red, onPressed: () {
            context.pushNamed(addDevice);
          }),));
        debugPrint(value.toString());
      }
    });

    super.initState();
  }

  Future<void> pustScreen(int index) async {
    await DataProvider().getData(DataProvider.bt_c).then((value) {
      if (value != null) {
        if (index == 1) {

          context.pushNamed(deviceprofile, queryParameters: {"address": value});
        } else if (index == 2) {
          context.pushNamed(batterystatus, queryParameters: {"address": value});

        } else if (index == 3) {
          context.pushNamed(navigation,);
        } else if (index == 4) {
          context.pushNamed(chatlist, queryParameters: {"address": value});
        } else if (index == 5) {
          context.pushNamed(sosalert, queryParameters: {"address": value});
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.indigo,
          content: const Text("Not Devices Registred "),
          duration: const Duration(minutes: 2),
          action: SnackBarAction(
              label: "Click To Connect", textColor: Colors.red, onPressed: () {
            context.pushNamed(addDevice);
          }),));
      }
    });
  }

  Widget cardWid(Size size, String asste, String name, Function() ontap) {
    return GestureDetector(
      onTap: ontap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Colors.grey)
          // Adjust the radius as needed
        ),

        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              const SizedBox(height: 10,),
              SizedBox(
                height: size.height * 0.1,
                width: size.width / 2.5,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SvgPicture.asset(
                    asste,
                    semanticsLabel: 'Acme Logo', color: Colors.indigo,
                    height: 20.0,
                    width: 20.0,
                  ),
                ),
              ),
              Text(name, style: const TextStyle(fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),),
              const SizedBox(height: 20,)

            ],
          ),
        ),
      ),
    );
  }
}



const   String dashboard = 'dashboard';
const   String navigation = 'navigation';
const   String chatlist = 'chatlist';
const   String chatmessage = 'chatmessage';
const   String deviceprofile = 'deviceprofile';
const   String batterystatus = 'batterystatus';
const   String sosalert = 'sosalert';
const   String addDevice = 'addDevice';


final _router = GoRouter(
  routes: [
    GoRoute(
      name: dashboard,
      path: '/',
      builder: (context, state) => const MyHomePage(title: 'DashBoard',),
    ),
    GoRoute(
      name: sosalert,
      path: '/sos',
      builder: (context, state) => SosAlert(address: state.uri.queryParameters["address"]!),
    ),
    GoRoute(
      name: addDevice,
      path: '/addDevice',
      builder: (context, state) => const AddDevice(),
    ),
    GoRoute(
      name: navigation,
      path: '/navigation',
      builder: (context, state) =>  NavigationMap(message: state.uri.queryParameters['name'],lat: state.uri.queryParameters['lat'] ,long: state.uri.queryParameters['long'] ,),
    ),

    GoRoute(
      name: chatmessage,
      path: '/chatmessage',
      builder: (context, state) => ChatDetails(address: state.uri.queryParameters["address"]!),
    ),
    GoRoute(
      name: chatlist,
      path: '/chatlist',
      builder: (context, state) => Messages(address: state.uri.queryParameters["address"]!),
    ),
    GoRoute(
      name: batterystatus,
      path: '/batterystatus',
      builder: (context, state) => const BatterStatus(),
    ),
    GoRoute(
      name: deviceprofile,
      path: '/deviceprofile',
      builder: (context, state) => DeviceProfile(address: state.uri.queryParameters["address"]!),
    ),
  ],
);