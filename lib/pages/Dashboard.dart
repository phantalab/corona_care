import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corona_care/pages/CountriesList.dart';
import 'package:corona_care/pages/SubmitSymptoms.dart';
import 'package:corona_care/stless/CardGraph.dart';
import 'package:device_info/device_info.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class Dashboard extends StatefulWidget {
  static String id = 'Dashboard';

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  ///color of the total gradient
  List<Color> totalGradientColors = [
    const Color(0xff283593),
    const Color(0xff1a237e),
  ];
  ///color of the active gradient
  List<Color> activeGradientColors = [
    const Color(0xfff9a825),
    const Color(0xfff57f17),
  ];
  ///color of the recovered gradient
  List<Color> recoveredGradientColors = [
    const Color(0xff2e7d32),
    const Color(0xff1b5e20),
  ];
  ///color of the deaths gradient
  List<Color> deathsGradientColors = [
    const Color(0xffc62828),
    const Color(0xffb71c1c),
  ];
  ///will query from firebase if we need to show the "symptoms near by card"
  bool isNearByEnabled = false;
  ///statistics display values
  var casesFound = {
    "lastUpdate": "~",
    "total": "~",
    "confirmed": "~",
    "deaths": "~",
    "recovered": "~"
  };
  ///country selected using the dropdown
  String selectedCountry = 'India';

  ///
  var lineGraphDataPoints = {
    "total": {
      "maxY": 0.0,
      "minY": 0.0,
      "maxX": 0.0,
      "points": <FlSpot>[FlSpot(0, 0)]
    },
    "active": {
      "maxY": 0.0,
      "minY": 0.0,
      "maxX": 0.0,
      "points": <FlSpot>[FlSpot(0, 0)]
    },
    "recovered": {
      "maxY": 0.0,
      "minY": 0.0,
      "maxX": 0.0,
      "points": <FlSpot>[FlSpot(0, 0)]
    },
    "deaths": {
      "maxY": 0.0,
      "minY": 0.0,
      "maxX": 0.0,
      "points": <FlSpot>[FlSpot(0, 0)]
    }
  };

  @override
  void initState() {
    super.initState();
    getCountry();
    checkDeviceId();
    surveyCheck();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            color: Colors.grey.shade50,
            child: ListView(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: 20, top: 22, bottom: 12),
                        child: Text(
                          "Current outbreak",
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.left,
                        )),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCountry,
                          icon: Icon(Icons.keyboard_arrow_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.25),
                          onChanged: (String newValue) {
                            setState(() {
                              selectedCountry = newValue;
                              setCountry(newValue);
                              casesFound = {
                                "lastUpdate": "1",
                                "confirmed": "~",
                                "total": "~",
                                "deaths": "~",
                                "recovered": "~"
                              };
                              getNumberOfCases(newValue);
                            });
                          },
                          items: countries
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Container(
                                  width: MediaQuery.of(context).size.width * 0.75,
                                  padding: EdgeInsets.all(4),
                                  child: Text(value)),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 20, bottom: 16, top: 12),
                      child: Text(
                        casesFound["lastUpdate"].toString().length == 1
                            ? "~"
                            : DateFormat.yMEd().add_jms().format(DateTime.parse(
                                casesFound["lastUpdate"].toString())),
                        style:
                            TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            casesFound = {
                              "lastUpdate": "1",
                              "confirmed": "~",
                              "total": "~",
                              "deaths": "~",
                              "recovered": "~"
                            };
                          });
                          getNumberOfCases(selectedCountry);
                        },
                        child: Icon(
                          Icons.update,
                          color: Colors.grey.shade400,
                          size: 24,
                        )),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: 20, top: 16, bottom: 8),
                        child: Text(
                          "COVID-19 Latest Update",
                          style: TextStyle(
                              color: Colors.grey.shade900, fontSize: 18),
                          textAlign: TextAlign.left,
                        )),
                  ],
                ),
                //Cards
                statisticsCards(),
                isNearByEnabled && selectedCountry=="India"
                    ? whatSymptomsYouRFacing()
                    : SizedBox(
                        width: 0,
                      ),
                preventionCard(),
                comparisonCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialogComparison() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: Container(
              child: Image.asset("images/cold_vs_flu_vs_coronavirus.jpg")),
        );
      },
    );
  }

  Widget comparisonCard() {
    return GestureDetector(
      onTap: () {
        getDeviceInfo();
        _showDialogComparison();
      },
      child: Container(
        margin: EdgeInsets.only(left: 20, bottom: 16),
        child: Card(
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: 15,
                  left: 20,
                  child: Opacity(
                    opacity: 0.8,
                    child: Transform.rotate(
                        angle: pi / 35, child: Image.asset("images/v1.png")),
                  )),
              Positioned(
                  bottom: 4,
                  left: 34,
                  child: Opacity(
                    opacity: 0.5,
                    child: Transform.rotate(
                        angle: -pi / 4, child: Image.asset("images/v3.png")),
                  )),
              Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        left: 16, top: 24, bottom: 16, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'COVID -19 vs Flu vs Cold',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 36, bottom: 24, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            'COVID-19 and the flu can cause similar symptoms. However, there are several differences between them. The novel strain of coronavirus (SARS-CoV-2) causes coronavirus disease 19 (COVID-19).\n\nBoth COVID-19 and the flu are respiratory illnesses that spread from person to person.\n\nClick to understand the differences between COVID-19 and the flu.',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget preventionCard() {
    return Container(
      margin: EdgeInsets.only(top: 16, left: 20, bottom: 16),
      child: Card(
        child: Stack(
          children: <Widget>[
//                      Image.asset("images/virus.png"),
            Stack(
              children: <Widget>[
                Positioned(
                    bottom: 4, right: 4, child: Image.asset("images/v2.png")),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          left: 16, top: 24, bottom: 16, right: 8),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'How to prevent spread of virus?',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 36, bottom: 24, right: 8),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                              'Wash your hands frequently\nMaintain social distancing\nAvoid touching eyes, nose and mouth\nIf you have fever, cough and difficulty breathing, seek medical care early',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget statisticsCards() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CardGraph(Icons.add_circle, casesFound["total"], "Total",
                Colors.indigo.shade900, lineGraphDataPoints["total"], totalGradientColors),
            CardGraph(
                Icons.add_circle,
                casesFound["confirmed"],
                "Infected",
                Colors.yellow.shade900,
                lineGraphDataPoints["active"],
                activeGradientColors),
            CardGraph(
                Icons.favorite,
                casesFound["recovered"],
                "Recovered",
                Colors.green.shade800,
                lineGraphDataPoints["recovered"],
                recoveredGradientColors),
            CardGraph(Icons.error, casesFound["deaths"], "Deaths",
                Colors.red.shade900, lineGraphDataPoints["deaths"], deathsGradientColors)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[],
        ),
      ],
    );
  }

  Widget whatSymptomsYouRFacing() {
    return Container(
      margin: EdgeInsets.only(top: 16, left: 20),
      child: Card(
        child: Stack(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Positioned(
                  top: -40,
                  left: -20,
                  child: Transform.rotate(
                    angle: pi / 4,
                    child: Image.asset("images/v3.png"),
                  ),
                ),
                Positioned(
                    bottom: -40,
                    left: 20,
                    child: Opacity(
                        opacity: 0.4,
                        child: Transform.rotate(
                            angle: -pi / 6,
                            child: Image.asset("images/v3.png")))),
                Positioned(
                    top: -40,
                    right: -20,
                    child: Opacity(
                        opacity: 0.2,
                        child: Transform.rotate(
                            angle: -pi / 3,
                            child: Image.asset("images/v3.png")))),
                Positioned(
                    bottom: -40,
                    right: 20,
                    child: Opacity(
                        opacity: 0.7,
                        child: Transform.rotate(
                            angle: -pi / 6,
                            child: Image.asset("images/v3.png")))),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      margin: EdgeInsets.only(
                          left: 16, top: 24, bottom: 16, right: 8),
                      child: Text(
                        'See what symptoms people have near-by on map!',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.pushNamed(context, SubmitSymptoms.id);
                          },
                          color: Colors.white,
                          child: Text(
                            "Lets do it!",
                            style:
                                TextStyle(color: Color.fromRGBO(34, 43, 69, 1)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void getNumberOfCases(String country) async {
    var url = 'https://covid-193.p.rapidapi.com/history?country=' +
        country.replaceAll(" ", "%20");
    print(url);
    Map<String, String> requestHeaders = {
      "x-rapidapi-host": "covid-193.p.rapidapi.com",
      "x-rapidapi-key": "b12bc6f83amshc447880da074af6p183963jsn94eaab8fbda4"
    };
    var response = await http.get(url, headers: requestHeaders);

    var jsonRes = json.decode(response.body);
//    print(jsonRes);
    var obj = {
      "total": {
        "maxY": 0.0,
        "minY": double.maxFinite,
        "maxX": 0.0,
        "points": <FlSpot>[]
      },
      "active": {
        "maxY": 0.0,
        "minY": double.maxFinite,
        "maxX": 0.0,
        "points": <FlSpot>[]
      },
      "recovered": {
        "maxY": 0.0,
        "minY": double.maxFinite,
        "maxX": 0.0,
        "points": <FlSpot>[]
      },
      "deaths": {
        "maxY": 0.0,
        "minY": double.maxFinite,
        "maxX": 0.0,
        "points": <FlSpot>[]
      }
    };

    double count = 0.0, mx = -1, mn = double.maxFinite;
    String lastTotal, lastActive, lastRec, lastDeath, timestamp = "";

    lastTotal = jsonRes["response"][0]["cases"]["total"].toString();
    lastActive = jsonRes["response"][0]["cases"]["active"].toString();
    lastRec = jsonRes["response"][0]["cases"]["recovered"].toString();
    lastDeath = jsonRes["response"][0]["deaths"]["total"].toString();
    timestamp = jsonRes["response"][0]["time"].toString();

    for (var key in jsonRes["response"]) {
      (obj["total"]["points"] as List<FlSpot>).insert(
          0,
          FlSpot((jsonRes["response"] as List).length * 1.0 - count - 1.0,
              key["cases"]["total"] * 1.0));

      (obj["active"]["points"] as List<FlSpot>).insert(
          0,
          FlSpot((jsonRes["response"] as List).length * 1.0 - count - 1.0,
              key["cases"]["active"] * 1.0));

      (obj["recovered"]["points"] as List<FlSpot>).insert(
          0,
          FlSpot((jsonRes["response"] as List).length * 1.0 - count - 1.0,
              key["cases"]["recovered"] * 1.0));

      (obj["deaths"]["points"] as List<FlSpot>).insert(
          0,
          FlSpot((jsonRes["response"] as List).length * 1.0 - count - 1.0,
              key["deaths"]["total"] * 1.0));

      obj["total"]["maxY"] =
          max(key["cases"]["total"] * 1.0, obj["total"]["maxY"]);
      obj["total"]["minY"] =
          min(key["cases"]["total"] * 1.0, obj["total"]["minY"]);

      obj["active"]["maxY"] =
          max(key["cases"]["active"] * 1.0, obj["active"]["maxY"]);
      obj["active"]["minY"] =
          min(key["cases"]["active"] * 1.0, obj["active"]["minY"]);

      obj["recovered"]["maxY"] =
          max(key["cases"]["recovered"] * 1.0, obj["recovered"]["maxY"]);
      obj["recovered"]["minY"] =
          min(key["cases"]["recovered"] * 1.0, obj["recovered"]["minY"]);

      obj["deaths"]["maxY"] =
          max(key["deaths"]["total"] * 1.0, obj["deaths"]["maxY"]);
      obj["deaths"]["minY"] =
          min(key["deaths"]["total"] * 1.0, obj["deaths"]["minY"]);

      obj["total"]["maxX"] = (obj["total"]["maxX"] as double) + 1.0;
      obj["active"]["maxX"] = (obj["active"]["maxX"] as double) + 1.0;
      obj["recovered"]["maxX"] = (obj["recovered"]["maxX"] as double) + 1.0;
      obj["deaths"]["maxX"] = (obj["deaths"]["maxX"] as double) + 1.0;
      count++;
    }

    obj["total"]["maxX"] = (obj["total"]["maxX"] as double) - 1.0;
    obj["active"]["maxX"] = (obj["active"]["maxX"] as double) - 1.0;
    obj["recovered"]["maxX"] = (obj["recovered"]["maxX"] as double) - 1.0;
    obj["deaths"]["maxX"] = (obj["deaths"]["maxX"] as double) - 1.0;

//    print((obj["total"]["points"] as List)[0].y);

    mx = max(
        obj["total"]["maxY"],
        max(obj["active"]["maxY"],
            max(obj["recovered"]["maxY"], obj["deaths"]["maxY"])));
    mn = min(
        obj["total"]["minY"],
        min(obj["active"]["minY"],
            min(obj["recovered"]["minY"], obj["deaths"]["minY"])));

    obj["total"]["maxY"] = mx;
    obj["total"]["minY"] = mn;

    obj["active"]["maxY"] = mx;
    obj["active"]["minY"] = mn;

    obj["recovered"]["maxY"] = mx;
    obj["recovered"]["minY"] = mn;

    obj["deaths"]["maxY"] = mx;
    obj["deaths"]["minY"] = mx;

    setState(() {
      casesFound["total"] = lastTotal;
      casesFound["confirmed"] = lastActive;
      casesFound["recovered"] = lastRec;
      casesFound["deaths"] = lastDeath;
      casesFound["lastUpdate"] = timestamp;
      lineGraphDataPoints = obj;
    });
  }

  void getCountry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('country') == null ||
        prefs.getString('country').isEmpty) {
      Toast.show("Please select your prefered country 🙂", context,
          duration: Toast.LENGTH_LONG, backgroundColor: Colors.red.shade900);
    }
    setState(() {
      selectedCountry = prefs.getString('country') ?? "India";
      getNumberOfCases(selectedCountry);
    });
  }

  void setCountry(String country) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('country', country);
  }

  void checkDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('id') == null || prefs.getString('id').isEmpty) {
      getDeviceInfo();
    }
  }

  void getDeviceInfo() async {
    //Get a unique ID for Android
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', androidInfo.fingerprint.replaceAll("/", "#"));
    print("got id");
  }

  void surveyCheck() async {
    Firestore.instance
        .collection("config")
        .document("survey")
        .get()
        .then((var doc) {
      setState(() {
        print(doc.data);
        isNearByEnabled = doc.data["near_by"];
      });
    });
  }
}
