import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'grocery/groceryMain.dart';
import 'load_bu.dart';
import 'package:root_check/root_check.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';

class Splash extends StatefulWidget {
  @override
  _Splash createState() => _Splash();
}

class _Splash extends State<Splash> with SingleTickerProviderStateMixin{
  final db = RapidA();
  List globalCat;

  void selectType(BuildContext context ,width ,height) async{
    getGlobalCat();
    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight:  Radius.circular(10),topLeft:  Radius.circular(10)),
        ),
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height/2.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Padding(
                    padding: EdgeInsets.fromLTRB(12, 10, 10, 5),
                    child: Text("Please select",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),)
                ),
                Expanded(
                  child:Container(
                    height: 400.0, // Change as per your requirement
                    // width: 300.0, // Change as per your requirement
                    child: Scrollbar(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount:  globalCat == null ? 0 : globalCat.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              if(globalCat[index]['id'] == '1'){
                                Navigator.of(context).push(_foodRoute(globalCat[index]['id']));
                              }if(globalCat[index]['id'] == '2'){
                                Navigator.of(context).push(_groceryRoute(globalCat[index]['id']));
                              }if(globalCat[index]['id'] == '3'){
                                Navigator.of(context).push(_foodRoute(globalCat[index]['id']));
                              }
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Image.network(globalCat[index]['cat_picture']),
                              ),
                              title: Text(globalCat[index]['category'],style: TextStyle(color: Colors.black87,fontSize: 17,fontWeight: FontWeight.bold),),
                            ),
                          );
                        },
                      ),
                    ),
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


  Future getGlobalCat() async{
    var res = await db.getGlobalCat();
    if (!mounted) return;
    setState(() {
      globalCat = res['user_details'];
    });
  }

  @override
  void initState() {
    initPlatformState();
    getGlobalCat();
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
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage("assets/png/logo_raider8.2.png"),
            fit: BoxFit.scaleDown
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
                  child:  OutlinedButton(
                    style: TextButton.styleFrom(
                      primary: Colors.black, // foreground
                      // backgroundColor: Colors.deepOrange,
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    ),
                    onPressed: (){
                      selectType(context ,width, height);
                    },
                    child: Text("Get started", style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                        fontSize: 20.0),),
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

Route _foodRoute(_globalCatID) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MyHomePage(globalCatID:_globalCatID),
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

Route _groceryRoute(_groceryRoute) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GroceryMain(groceryRoute:_groceryRoute),
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
