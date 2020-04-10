import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';

class MapView extends StatefulWidget {
  static String id = 'MapView';

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  List peopleList = [];
  Geoflutterfire geo = Geoflutterfire();
  Firestore _firestore = Firestore.instance;
  Completer<GoogleMapController> _controller = Completer();
  Location location = new Location();
  LatLng myLoc = new LatLng(0.0, 0.0);
  Set<Marker> markers = Set();

  void _onMapCreated(GoogleMapController mapController) async {
    _controller.complete(mapController);
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).cardColor,
        ),
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Theme.of(context).cardColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 8, top: 22),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 42,
                          )),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                          "Symptoms near-by",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    onTap: (ll){
                      submit(ll);
                    },
                    markers: markers,
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(0.0, 0.0),
                      zoom: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
//      floatingActionButton: FloatingActionButton(
//        child: Icon(Icons.update),
//        onPressed: () {
//          _getLocation();
//        },
//      ),
    );
  }

  void _getLocation() async {
    LocationData locationData = await location.getLocation();
    setState(() {
      myLoc = LatLng(locationData.latitude, locationData.longitude);
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: myLoc, zoom: 17)));

    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: _firestore.collection("data_symptoms"))
        .within(center: geo.point(latitude: myLoc.latitude, longitude: myLoc.longitude), radius: 5, field: 'position');
    stream.listen((List<DocumentSnapshot> documentList) {
      int i=0;
      print("\n\n\n\n");
      print(documentList.length);
      setState(() {
        documentList.forEach((f){
          print(f.data["id"]);
          markers.add(Marker(markerId:MarkerId((i++).toString()),position: new LatLng(f.data["lat"], f.data["lng"]),infoWindow: InfoWindow(title: f.data["symptoms"].toString())));
        });
      });
    });

  }

  void submit(LatLng ll) async{
//    GeoFirePoint myLocation = geo.point(
//        latitude: ll.latitude, longitude: ll.longitude);
//    _firestore.collection('data_symptoms').add({
//      'id': "sad",
//      'symptoms': ["Fever","Stomach Pain","Headache"],
//      'position': myLocation.data,
//      'lat': myLocation.latitude,
//      'lng': myLocation.longitude,
//      'timestamp': new DateTime.now().millisecondsSinceEpoch
//    }).then((onValue) {
//      Toast.show(
//        "Done!! Thank You for your contribution 🎉🎉",
//        context,
//        duration: Toast.LENGTH_LONG,
//      );
//    });
  }
}
