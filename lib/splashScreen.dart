import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'grocery/groceryMain.dart';
import 'load_bu.dart';
import 'package:root_check/root_check.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Splash extends StatefulWidget {
  @override
  _Splash createState() => _Splash();
}

class _Splash extends State<Splash> with SingleTickerProviderStateMixin{

  void selectType(BuildContext context) async{
    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight:  Radius.circular(10),topLeft:  Radius.circular(10)),
        ),
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height/2.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          Navigator.of(context).push(_foodRoute());
                        },
                        child: Container(
                          width:170,
                          height:170,
                          child: Column(
                            children:[
                              Padding(
                                padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                                child: Image.asset("assets/png/food.png",),
                              ),
                              Text("Food",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          Navigator.of(context).push(_groceryRoute());
                        },
                        child: Container(
                          width:170,
                          height:170,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                                child: Image.asset("assets/png/grocery.png"),
                              ),
                              Text("Grocery",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ),
                      ),


                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future initPlatformState() async {
    bool isRooted = await RootCheck.isRooted;
    if(isRooted == true){
      setState(() {
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: (){
                return null;
              },
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))
                ),
                title: Text("Notice"),
                contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                content: Container(
                  height:50.0, // Change as per your requirement
                  width: 100.0, // Change as per your requirement
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 5.0, 13.0, 5.0),
                    child: Text("Sorry, Alturush will not work in rooted devices."),
                  )
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Close',style: TextStyle(
                      color: Colors.black,
                    ),),
                    onPressed: () async{
                      // Navigator.of(context).pop();
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      });
    }
  }

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/png/logo_raider8.2.png"),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: <Widget>[
                  SizedBox(
                    height: height-400,
                  ),

                    SizedBox(
                        height: 420,
                        width: 30.0,
                        child: Carousel(
                          images: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 40.0,
                                ),
                                Text("Welcome to Alturush",style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black54,
                                    fontSize: 18.0),),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 40.0,
                                ),
                                Text("Choose a restaurant",style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black54,
                                    fontSize: 18.0),),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 40.0,
                                ),
                                Text("Order online",style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black54,
                                    fontSize: 18.0),),
                              ],
                            ),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 40.0,
                                ),
                                Text("Multi store for fixed delivery fee",style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black54,
                                    fontSize: 18.0),),
                              ],
                            ),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 40.0,
                                ),
                                Text("Fast delivery",style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black54,
                                    fontSize: 18.0),),
                              ],
                            ),
                          ],
                          dotSize: 4.0,
                          dotSpacing: 15.0,
                          showIndicator: false,
                          dotColor: Colors.white,
                          indicatorBgPadding: 5.0,
                          dotBgColor: Colors.white,
                          borderRadius: true,
                        )
                    ),
                  ],
                ),
            ),
            Center(
              child:Padding(
                padding: EdgeInsets.fromLTRB(10.0,0.0, 10.0,10.0),
                child: SizedBox(
                  width: width-50,
                  height: 50.0,
                  child:  OutlineButton(
                    highlightedBorderColor: Colors.deepOrange,
                    highlightColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: Colors.red)
                    ),
                    color: Colors.deepOrange,
                    onPressed: (){
                      selectType(context);
//                      Navigator.of(context).push(_createRoute());

                    },
                    child: Text("Get started", style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                        fontSize: 18.0),),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Route _foodRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MyHomePage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.decelerate;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Route _groceryRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GroceryMain(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.decelerate;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
