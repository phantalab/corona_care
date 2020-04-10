import 'package:corona_care/pages/Dashboard.dart';
import 'package:corona_care/pages/MapView.dart';
import 'package:corona_care/pages/Splash.dart';
import 'package:corona_care/pages/SubmitSymptoms.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(34, 43, 69, 1),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Montserrat-SemiBold',
        cardColor: Color.fromRGBO(34, 43, 69, 1),
        textTheme: TextTheme(
          body1: TextStyle(fontSize: 16.0,color: Colors.white),
          body2: TextStyle(fontSize: 16.0, ),
        ),
      ),
      initialRoute: Splash.id,
      routes: {
        Splash.id: (context) => Splash(),
        Dashboard.id: (context) => Dashboard(),
        SubmitSymptoms.id:(context)=>SubmitSymptoms(),
        MapView.id:(context)=>MapView()
      },
    );
  }
}