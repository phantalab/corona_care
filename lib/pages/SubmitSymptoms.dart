import 'package:carousel_slider/carousel_slider.dart';
import 'package:corona_care/pages/MapView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:location_permissions/location_permissions.dart' as lp;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:location/location.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubmitSymptoms extends StatefulWidget {
  static String id = 'SubmitSymptoms';

  @override
  _SubmitSymptomsState createState() => _SubmitSymptomsState();
}

class _SubmitSymptomsState extends State<SubmitSymptoms> {
  List<String> symptomsList1 = [
    "Sore throat",
    "Sneezing",
    "Runny nose",
    "Cough",
    "Weakness",
    "Fever",
    "Aches"
  ];
  List<String> symptomsList2 = [
    "Chills",
    "Headache",
    "Shortness of breath",
    "Nausea",
    "Vomitting",
    "Diarrhea",
    "Stomach pain"
  ];

  List<String> mySymptoms = [];
  Geoflutterfire geo = Geoflutterfire();
  Firestore _firestore = Firestore.instance;
  bool showMap = false;

  @override
  void initState() {
    super.initState();
    checkPermission();
    buttonShowLogic();
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
            child: ListView(
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
                CarouselSlider(
                  height: MediaQuery.of(context).size.height * 0.23,
                  items: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Card(
                        color: Colors.white,
                        child: InkWell(
                          splashColor: Colors.blue.withAlpha(30),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            margin: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'What do we see on map?',
                                  style: TextStyle(
                                      color: Theme.of(context).cardColor,
                                      fontWeight: FontWeight.w900),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Symptoms people are facing in different areas, with this information you can avoid travelling to the areas which have a high density population with symptoms.',
                                  style: TextStyle(
                                      color: Theme.of(context).cardColor,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Card(
                        color: Colors.white,
                        child: InkWell(
                          splashColor: Colors.blue.withAlpha(30),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            margin: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'What is the use of the app?',
                                  style: TextStyle(
                                      color: Theme.of(context).cardColor,
                                      fontWeight: FontWeight.w900),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Well of course you will get the latest updates about the COVID 19 but apart from that this app help "flatten the curve" by helping you from not getting infected.',
                                  style: TextStyle(
                                      color: Theme.of(context).cardColor,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Card(
                        color: Colors.white,
                        child: InkWell(
                          splashColor: Colors.blue.withAlpha(30),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            margin: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'How can you contribute?',
                                  style: TextStyle(
                                      color: Theme.of(context).cardColor,
                                      fontWeight: FontWeight.w900),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'You will be able to view the map only if you honestly submit the symptoms you are facing along with your GPS location.',
                                  style: TextStyle(
                                      color: Theme.of(context).cardColor,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Card(
                        color: Colors.white,
                        child: InkWell(
                          splashColor: Colors.blue.withAlpha(30),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            margin: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'What if I submit false symptoms?',
                                  style: TextStyle(
                                      color: Theme.of(context).cardColor,
                                      fontWeight: FontWeight.w900),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Well in that case this pandemic will ONLY be remembered for its catastrophe!',
                                  style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ].map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return i;
                      },
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 16,
                ),
                showMap == false
                    ? Column(
                        children: <Widget>[
                          Text(
                            "Which symptoms do you have?",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              getButtonsFrom(symptomsList1),
                              getButtonsFrom(symptomsList2),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 12),
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.yellow)),
                              child: Text(
                                "Submit",
                                style: TextStyle(color: Colors.yellow),
                              ),
                              onPressed: () {
                                _showDialogTandC();
                              },
                            ),
                          ),
                        ],
                      )
                    : Container(
                        margin:
                            EdgeInsets.only(left: 50, right: 50, bottom: 16),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.yellow)),
                          child: Text(
                            "Open map",
                            style: TextStyle(color: Colors.yellow),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, MapView.id);
                            Toast.show("Waiting for you location...", context,
                                duration: Toast.LENGTH_LONG);
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialogTandC() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text('Do you accept to share?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Your symptoms and GPS location will be shared publically on our platform, do you accept to share it with out?\n'),
                Text(
                    'This information will be anynomised by adding some error.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Regret'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Accept'),
              onPressed: () {
                Navigator.of(context).pop();
                _showDialogTruth();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialogTruth() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text('Did you select the symptoms correctly?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'We request you to select the symptoms you are facing  truthfully!\n'),
                Text(
                  'Otherwise this pandemic will ONLY be remembered for its worst catastrophe!',
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Sorry no'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yeah!'),
              onPressed: () {
                Navigator.of(context).pop();

                _submitInfo();
              },
            ),
          ],
        );
      },
    );
  }

  void buttonShowLogic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastSubmitted = prefs.getString('lastSubmitted') ?? "";

    if (lastSubmitted.isNotEmpty &&
        DateTime.now().difference(DateTime.parse(lastSubmitted)).inDays < 2) {
      Toast.show(
          "You have already submitted, please submit an update after " +
              (2 -
                  DateTime.now()
                          .difference(DateTime.parse(lastSubmitted))
                          .inDays)
                  .toString() +
              " days :)",
          context,
          duration: Toast.LENGTH_LONG);
      setState(() {
        showMap = true;
      });
    }
  }

  Widget getButtonsFrom(List<String> syms) {
    List<Widget> lst = [];
    for (String sym in syms) {
      lst.add(FlatButton(
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(18.0),
            side: BorderSide(
                color: mySymptoms.contains(sym) ? Colors.red : Colors.white)),
        child: Text(
          sym,
          style: TextStyle(
              color: mySymptoms.contains(sym) ? Colors.red : Colors.white),
        ),
        onPressed: () {
          if (mySymptoms.contains(sym))
            setState(() {
              mySymptoms.remove(sym);
            });
          else
            setState(() {
              mySymptoms.add(sym);
            });
        },
      ));
    }
    return Column(
      children: lst,
    );
  }

  void _submitInfo() async {
    Toast.show(
      "Please wait ⌛",
      context,
      duration: Toast.LENGTH_LONG,
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString('id');

    Location location = new Location();
    LocationData _locationData = await location.getLocation();

    print(_locationData.latitude.toString() +
        ", " +
        _locationData.longitude.toString());
    GeoFirePoint myLocation = geo.point(
        latitude: _locationData.latitude, longitude: _locationData.longitude);

    await prefs.setString(
        'lastSubmitted', new DateTime.now().toIso8601String());

    _firestore.collection('data_symptoms').add({
      'id': deviceId,
      'symptoms': mySymptoms,
      'position': myLocation.data,
      'lat': myLocation.latitude,
      'lng': myLocation.longitude,
      'timestamp': new DateTime.now().millisecondsSinceEpoch
    }).then((onValue) {
      setState(() {
        showMap = true;
      });
      Toast.show(
        "Done!! Thank You for your contribution 🎉🎉",
        context,
        duration: Toast.LENGTH_LONG,
      );
    });
  }

  void checkPermission() async {
    lp.PermissionStatus permission =
        await lp.LocationPermissions().checkPermissionStatus();
    print(permission);
    if (permission == lp.PermissionStatus.restricted) {
      Toast.show("Location permission is required to continue...", context);
      await lp.LocationPermissions().openAppSettings();
    } else if (permission == lp.PermissionStatus.denied ||
        permission == lp.PermissionStatus.unknown) {
      permission = await lp.LocationPermissions().requestPermissions();
    }

    if (permission != lp.PermissionStatus.granted) {
      Toast.show("Please grant permission from app settings...", context,
          duration: Toast.LENGTH_LONG, backgroundColor: Colors.red.shade900);
      Navigator.pop(context);
      return;
    }
  }
}
