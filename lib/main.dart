import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_map_app/detail.dart';
import 'package:google_map_app/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

// google map API key
// AIzaSyC8bAiI8yDk5YEQS8VDzMIC-e0E5y446-s

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
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
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> markers = {};

  LatLng _center = const LatLng(45.521563, -122.677433);

  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    // final myMarker1 = Marker(markerId: MarkerId("_myMarkerId"), 
    // infoWindow: InfoWindow(title: "Hello Info"),
    // icon: BitmapDescriptor.defaultMarker,
    // position: _position1
    // );
    // final myMarker2 = Marker(markerId: MarkerId("_myMarkerId2"), 
    // infoWindow: InfoWindow(title: "Another marker"),
    // icon: BitmapDescriptor.defaultMarker,
    // position: _position2
    // );
    return Scaffold(
      appBar: AppBar(
        title: _buildTextField(),
      ),
      body: Stack(children: [
        Column(children: [
          // _buildTextField(),
          Expanded(
            child: GoogleMap(
              onTap: (position) {
                _customInfoWindowController.hideInfoWindow!();
              },
              onCameraMove: (position) {
                if(_customInfoWindowController.onCameraMove != null) {
                  _customInfoWindowController.onCameraMove!();
                }
              },
              onMapCreated: (GoogleMapController controller) async {
                _customInfoWindowController.googleMapController = controller;
                _onMapCreated(controller);
              },
              // onMapCreated: _onMapCreated,
              markers: markers,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 10.0,
                  ),
              )
          ),],
        ),

        CustomInfoWindow(
            controller: _customInfoWindowController, 
            height: 75, width: 200, offset: 0,)

      ],),
    );
  }

  Widget _buildTextField() {
    return Row(children: [
      Expanded(child: TextFormField(
        style: const TextStyle(color: Colors.white),
        controller: _searchController,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: "Search Places...", hintStyle: TextStyle(color: Colors.white, fontSize: 14),),
      )),
      IconButton(onPressed: () async {
        var places = await LocationService().getPlaces(_searchController.text);
        print("Places found: ${places.length}");

        setState(() {
          markers = {};
          markers.addAll(places.map(_generateMarker));

          print(markers.length);

          if(markers.isNotEmpty) {
            _updateCenter(places[0]);
          }
        });
      }, icon: const Icon(Icons.search))
    ],);
  }

  Marker _generateMarker(dynamic input) {
    return Marker(
    consumeTapEvents: true,
    markerId: MarkerId(input['place_id']), 
    infoWindow: InfoWindow(title: input['name'], snippet: input['formatted_address']),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(input['geometry']['location']['lat'], input['geometry']['location']['lng']),
    onTap: () {
      if (_customInfoWindowController.addInfoWindow == null) return;

      _customInfoWindowController.addInfoWindow!(
        Container(
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.blueAccent)),
          padding: const EdgeInsets.all(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Image.network(input['icon'], width: 50, height: 10,),
            Text(input['name'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 1,),
            Expanded(child: Text(input['formatted_address'].toString().trim(), style: const TextStyle(fontSize: 8, color: Colors.black),),),
            Container(
              height: 15,
              width: 80,
              child: ElevatedButton(onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => PlaceDetails(placeId: input['place_id'])));
              }, child: const Center(child: Text("View Details", style: TextStyle(fontSize: 8)) ,))
            ,),
            const SizedBox(height: 2,),
      ],),), 
      LatLng(input['geometry']['location']['lat'], input['geometry']['location']['lng']));
    }
    );
  }

  _updateCenter(dynamic place) {
    _center = LatLng(place['geometry']['location']['lat'], place['geometry']['location']['lng']);
     mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
              target: _center,
              zoom: 12.0,
                )));
  }
}
