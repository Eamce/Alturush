import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
// import 'package:flutter_map/flutter_map.dart';
// import "package:latlong/latlong.dart" as latLng;
import 'package:geolocator/geolocator.dart';
import 'package:arush/chat/chat.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewOrderStatus extends StatefulWidget {
  final ticketNo;
  ViewOrderStatus({Key key, @required this.ticketNo}) : super(key: key);
  @override
  _ViewOrderStatus createState() => _ViewOrderStatus();
}

class _ViewOrderStatus extends State<ViewOrderStatus>{
  final db = RapidA();
  List riderList = [];
  Position position;
  var lat;
  var long;
  bool _isGettingLocation = true;
  double currentZoom = 13.0;
  // MapController mapController = MapController();
  String firstName = "";
  String lastName = "";
  String motorBrand = "";
  String motorDesc = "";
  String riderPhoto = "";
  String riderVehiclePhoto = "";
  String riderPlateNo = "";
  String riderMobileNo = "";

  Future loadRiderPage() async{
    _isGettingLocation = true;
    var res = await db.loadRiderPage(widget.ticketNo);
    if (!mounted) return;
    setState(() {
      _isGettingLocation = false;
      riderList = res['user_details'];
      firstName = riderList[0]['r_firstname'];
      lastName = riderList[0]['r_lastname'];
      motorBrand = riderList[0]['rm_brand'];
      motorDesc = riderList[0]['rm_color'];
      riderPhoto = riderList[0]['r_picture'];
      riderVehiclePhoto = riderList[0]['rm_picture'];
      riderPlateNo = riderList[0]['rm_plate_no'];
      riderMobileNo = riderList[0]['rm_mobile_no'];
    });
  }

  // void _zoomOut() async{
  //   try {
  //     Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  //     position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  //     lat = position.latitude;
  //     long = position.longitude;
  //     var newLatLang = latLng.LatLng(lat,long);
  //     currentZoom = currentZoom - 1;
  //     mapController.move(newLatLang, currentZoom);
  //   }
  //   on PlatformException catch (e) {
  //       print(e);
  //   }
  // }

  // void _zoomIn() async{
  //   try {
  //     Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  //     position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  //     lat = position.latitude;
  //     long = position.longitude;
  //     var newLatLang = latLng.LatLng(lat,long);
  //     currentZoom = currentZoom + 1;
  //     mapController.move(newLatLang, currentZoom);
  //   }
  //   on PlatformException catch (e) {
  //     print(e);
  //   }
  // }

  // void locateYourLocation() async{
  //   try {
  //     Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  //     position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  //     if (!mounted) return;
  //     setState(() {
  //       lat = position.latitude;
  //       long = position.longitude;
  //       var newLatLang = latLng.LatLng(lat,long);
  //       double zoom = 15.0; //the zoom you want
  //       mapController.move(newLatLang,zoom);
  //     });
  //   } on PlatformException catch (e) {
  //     print(e);
  //   }
  //
  // }

//   void locateRiderLocation() async{
//     try {
//       if (!mounted) return;
//       setState(() {
// //        lat = position.latitude;
// //        long = position.longitude;
//         //get
//         var newLatLang = latLng.LatLng(9.647111411110227, 123.86350931891319);
//         double zoom = 15.0; //the zoom you want
//         mapController.move(newLatLang,zoom);
//       });
//     }
//     on PlatformException catch (e) {
//       print(e);
//     }
//
//   }

//  void getUserLocation() async{
//    try {
//      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
//      position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
//      if (!mounted) return;
//      setState(() {
//        lat = position.latitude;
//        long = position.longitude;
//        _isGettingLocation = false;
//      });
//    } on PlatformException catch (e) {
//      print(e);
////      return null;
//    }
//  }

  @override
  void initState() {
//    getUserLocation();
    loadRiderPage();
    super.initState();
  }
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Rider detail",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
        actions: [
          IconButton(
              icon: Icon(Icons.chat_bubble, color: Colors.black54),
              onPressed: () {
                Navigator.of(context).push(chartRoute(firstName,lastName));
              }
          ),
        ],
      ),
      body:_isGettingLocation ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
      ) : RefreshIndicator(
        onRefresh: loadRiderPage,
        child: Scrollbar(
          child: ListView(
            // shrinkWrap: true,
            children: [
              // Padding(
              //   padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
              //   child: Card(
              //     elevation: 0.0,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20.0),
              //     ),
              //     child: Column(
              //       crossAxisAlignment:CrossAxisAlignment.center,
              //       children: [
              //         Padding(
              //             padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
              //             child: Text("Delivery fee",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 12.0),)
              //         ),
              //          Padding(
              //              padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
              //              child: Text("120.00",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 17.0),)
              //          ),
              //       ],
              //     ),
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 0.0,
                  child: Column(
                  crossAxisAlignment:CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Container(
                        height: 120.0,
                        width: 120.0,
                        child: CircleAvatar(
                          radius: 30.0,
                          backgroundImage: NetworkImage(riderPhoto),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Text("$firstName $lastName",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 17.0),),
                     ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0.0, 25, 20),
                      child:OutlinedButton.icon(
                        icon: Icon(Icons.phone,color: Colors.black87,),
                        style: TextButton.styleFrom(
                          primary: Colors.black,
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        ),
                        onPressed: (){
                          launch("tel://$riderMobileNo");
                        },
                        label:Text("Call rider",style: GoogleFonts.openSans(color:Colors.deepOrange,fontWeight: FontWeight.bold,fontSize: 15.0),),
                      ),
                    ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(20, 10.0, 20, 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 0.0,
                  child: Column(
                    crossAxisAlignment:CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Container(
                          height: 120.0,
                          width: 120.0,
                          child: CircleAvatar(
                            radius: 30.0,
                            backgroundImage: NetworkImage(riderVehiclePhoto),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Row(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 0.0),
                                  child: Text("Vehicle",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 12.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0.0, 20, 20),
                                  child: Text("$motorBrand",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 17.0),),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment:CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 0.0),
                                  child: Text("Plate No.",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 12.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0.0, 20, 20),
                                  child: Text("$riderPlateNo",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 17.0),),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 20.0),
                        child:Row(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 0.0),
                                  child:Text("Vehicle description",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 12.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0.0, 20, 20),
                                  child:Text("$motorDesc",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 17.0),),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment:CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 0.0),
                                  child:Text("Mobile number",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 12.0),),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0.0, 20, 5),
                                  child:Text("$riderMobileNo",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 17.0),),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

Route chartRoute(firstName,lastName) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Chat(firstName:firstName,lastName:lastName),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
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