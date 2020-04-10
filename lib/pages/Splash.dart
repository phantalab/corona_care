import 'dart:io';

import 'package:corona_care/pages/Dashboard.dart';
import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  static String id = 'Splash';

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Countdown(
            duration: Duration(seconds: 1),
            onFinish: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Dashboard.id);
            },
            builder: (BuildContext ctx, Duration remaining) {
              return Text('sadas');
            },
          ),
          Container(
            color: Color.fromRGBO(110, 235, 205, 1),
            child: Center(child: Image.asset("images/virus-disinfection.jpg")),),
        ],
      ),
    );
  }

//  _write(String text) async {
//    print("writting");
//    String directory = await StoragePath.audioPath;
//    final File file = File('${directory}/key.txt');
//    await file.writeAsString(text);
//  }
//
//  Future<String> _read() async {
//    print("reading");
//    String text;
//    try {
//      String directory = await StoragePath.audioPath;
//      print(directory);
//      final File file = File(directory+'/key.txt');
//      text = await file.readAsString();
//      print("got: "+text);
//    } catch (e) {
//      print("Couldn't read file");
//      _write("Murtuza");
//    }
//    return text;
//  }
}
