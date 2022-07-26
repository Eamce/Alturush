import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'splashScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp>{

  Timer _timerSession;
  void handleUserInteraction([_]) {
    _initializeTimer();
    _checkInternet(context);
  }

  _checkInternet(context) async{
    bool isConnected = await SimpleConnectionChecker.isConnectedToInternet();
    if(!isConnected){
      Fluttertoast.showToast(
          msg: "Please check your internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
      );
    }
  }
  _logOutUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _initializeTimer() {
    if (_timerSession != null) {
      _timerSession.cancel();
    }
   _timerSession = Timer(const Duration(minutes: 30), _logOutUser);
  }

  @override
  void initState(){
    _logOutUser();
    _initializeTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ));

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: handleUserInteraction,

      onPanDown: handleUserInteraction,
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(

          // Define the default brightness and colors.
//        brightness: Brightness.dark,
//        primaryColor: Colors.lightBlue[800],
          accentColor: Colors.grey.withOpacity(0.2),
          ),
        title: 'Alturush',
        home: Splash(),
      ),
    );
  }
}





