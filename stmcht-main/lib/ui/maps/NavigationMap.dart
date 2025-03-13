import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/maps.dart';
import 'package:mapsforge_flutter/marker.dart';
import 'package:stmcht/bluetoothProvider/bluetoothConnectionprovider.dart';
import 'package:stmcht/dataPreferences/DataProvider.dart';

class NavigationMap extends StatefulWidget {

  final String? message;
  final String? lat;
  final String? long;

   NavigationMap({super.key,this.message,this.lat,this.long});

  @override
  State<NavigationMap> createState() => _NavigationMapState();
}

class _NavigationMapState extends State<NavigationMap> {



  ViewModel? _viewModel;
  final displayModel = DisplayModel(deviceScaleFactor: 2,);
  // Create the cache for assets
  final symbolCache = FileSymbolCache();
  // Bonus: A markerstore
  final MarkerDataStore markerDataStore = MarkerDataStore();

  @override
  void initState() {


  //  debugPrint(widget.long);
  //  debugPrint(widget.lat);
 //   debugPrint(widget.message);


    // TODO: implement initState
    super.initState();
  }

  Future<MapModel> _createMapModel() async {

    // Load the mapfile which holds the openstreetmap® data. Use either MapFile.from() or load it into memory first (small files only) and use MapFile.using()
    ByteData content = await rootBundle.load('assets/maps/world.map');
    final mapFile =
    await MapFile.using(content.buffer.asUint8List(), null, null);
    // Create the render theme which specifies how to render the informations
    // from the mapfile.
    final renderTheme = await RenderThemeBuilder.create(
      displayModel,
      'assets/render_themes/mapsforge_default.xml',
    );
    // Create the Renderer
    final jobRenderer = MapDataStoreRenderer(mapFile, renderTheme, symbolCache, true,useIsolate: true);
   // final jobRenderer = MapOnlineRenderer();
    // Glue everything together into two models, the mapModel here and the viewModel below.
    MapModel mapModel = MapModel(
      displayModel: displayModel,
      renderer: jobRenderer,
      symbolCache: symbolCache,
    );
    // Bonus: Add MarkerDataStore to hold added markers
    mapModel.markerDataStores.add(markerDataStore);

    //_mapModel = mapModel;
    return mapModel;
  }

  Future<ViewModel> _createViewModel() async {
    ViewModel viewModel = ViewModel(displayModel: displayModel, );
    // set the initial position
   // viewModel.noPositionView= Text("");

    viewModel.setMapViewPosition(50.840747, 12.926675);
    // set the initial zoomlevel
    viewModel.setZoomLevel(12);
    // viewModel.observePosition.listen((event) {
    //   debugPrint(event.toString());
    //
    //   viewModel.setMapViewPosition(event.latitude!,event.longitude!);
    // });

    if(widget.message!=null && widget.long!=null && widget.lat!=null){

      double lat = ((double.parse(widget.lat!)/360000)*6);
      double long = ((double.parse(widget.long!)/360000)*6);
      PoiMarker? _marker=   PoiMarker(
        displayModel: displayModel,
        width: 50,height: 50,rotation: 0,
        src: 'assets/icons/message.svg', latLong: LatLong( lat,long),
      );


      _marker.initResources(symbolCache).then((value) {
        markerDataStore.addMarker(_marker);
        markerDataStore.setRepaint();

      });

    }



    double lat = 12.23423;
    double long =50.23;

     String? lat1  = await  DataProvider().getData(DataProvider.latitude);
     String? long1 = await  DataProvider().getData(DataProvider.longitude);

     if(lat1 !=null){

       lat =  ((double.parse(lat1.split("=")[3])/360000)*6);

     }
     if(long1 !=null){
      lat =  ((double.parse(long1.split("=")[3])/360000)*6);
     }
    PoiMarker? _marker=   PoiMarker(
      displayModel: displayModel,
      width: 50,height: 50,rotation: 0,
      src: 'assets/icons/marker.svg', latLong: LatLong( lat,long),
    );


    _marker.initResources(symbolCache).then((value) {
      markerDataStore.addMarker(_marker);
      markerDataStore.setRepaint();

    });

    markerDataStore.setRepaint();
    if(widget.lat!=null &&widget.long!=null && widget.message!=null){


      viewModel.observeTap.listen((event) {
        // PoiMarker? _marker=   PoiMarker(
        //   displayModel: displayModel,
        //   width: 50,height: 50,rotation: 0,
        //   src: 'assets/icons/marker.svg', latLong:event,
        // );

        _marker.initResources(symbolCache).then((value) {
          markerDataStore.addMarker(_marker);
          markerDataStore.setRepaint();

        });
      });
    }



    //  viewModel.addOverlay(FlutterMapView(mapModel: _mapModel!,viewModel: viewModel,));
   viewModel.addOverlay(ZoomOverlay(viewModel));

    viewModel.addOverlay(DistanceOverlay(viewModel));

    _viewModel = viewModel;
    return viewModel;
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(appBar: AppBar(),body: MapviewWidget(displayModel: displayModel,  createViewModel: _createViewModel, createMapModel:_createMapModel),);
  }


}
