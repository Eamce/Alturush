import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
// import 'package:flutter_map/flutter_map.dart';
// import "package:latlong/latlong.dart" as latLng;
import 'package:geolocator/geolocator.dart';
import 'package:arush/chat/chat.dart';
import 'package:sleek_button/sleek_button.dart';

class ViewOrderStatus extends StatefulWidget {
  final ticketNo;
  ViewOrderStatus({Key key, @required this.ticketNo}) : super(key: key);
  @override
  _ViewOrderStatus createState() => _ViewOrderStatus();
}

class _ViewOrderStatus extends State<ViewOrderStatus>{
  final db = RapidA();
  List riderList;
  List loadTotalData = [];
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

  Future loadRiderPage() async{
    var res = await db.loadRiderPage(widget.ticketNo);
    if (!mounted) return;
    setState(() {
      riderList = res['user_details'];
      firstName = riderList[0]['r_firstname'];
      lastName = riderList[0]['r_lastname'];
      motorBrand = riderList[0]['rm_brand'];
      motorDesc = riderList[0]['rm_color'];
      riderPhoto = riderList[0]['r_picture'];
      riderVehiclePhoto = riderList[0]['rm_picture'];
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

  void getTotalFee() async{
    var res = await db.getTotalFee(widget.ticketNo);
    if (!mounted) return;
    setState(() {
      loadTotalData = res['user_details'];
      print(loadTotalData);
    });
  }

  void getUserLocation() async{
    try {
      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      if (!mounted) return;
      setState(() {
        lat = position.latitude;
        long = position.longitude;
        _isGettingLocation = false;
      });
    } on PlatformException catch (e) {
      print(e);
//      return null;
    }
  }

  @override
  void initState() {
    getUserLocation();
    loadRiderPage();
    getTotalFee();
    print(widget.ticketNo);
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
      ) :Column(
        children:[
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadRiderPage,
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 10, 5, 5),
                         child: new Text('Your rider: $firstName $lastName', overflow: TextOverflow.clip, style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 18.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 10, 5, 5),
                        child: new Text('Vehicle: $motorBrand $motorDesc', overflow: TextOverflow.clip, style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 18.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 10, 5, 5),
                        child: new Text('Rider fee: $motorBrand $motorDesc', overflow: TextOverflow.clip, style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 18.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 10, 5, 5),
                        child: new Text('Total: $motorBrand $motorDesc', overflow: TextOverflow.clip, style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 18.0),
                        ),
                      ),
                     ],
                   ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 25, 20, 5),
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: width / 2.4,
                          height: height / 4,
                          decoration: new BoxDecoration(
                            image: new DecorationImage(
                              image: new NetworkImage(riderPhoto),
                              fit: BoxFit.contain,
                            ),
                            border: new Border.all(
                              color: Colors.black54,
                              width: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          width: width/2.4,
                          height: height/4,
                          decoration: new BoxDecoration(
                            image: new DecorationImage(
                              image: new NetworkImage(riderVehiclePhoto),
                              fit: BoxFit.contain,
                            ),
                            // borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                            border: new Border.all(
                              color: Colors.black54,
                              width: 0.5,
                            ),
                          ),
                        ),
                      ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),



          // Container(
          //   height: height/2,
          //   child: FlutterMap(
          //     mapController: mapController,
          //     options: new MapOptions(
          //       boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(8.0)),
          //       center: latLng.LatLng(lat,long),
          //       maxZoom: 25.0,
          //       minZoom: 10.0,
          //     ),
          //     layers: [
          //       new TileLayerOptions(
          //           urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          //           subdomains: ['a', 'b', 'c']
          //       ),
          //       new MarkerLayerOptions(
          //         markers: [
          //           new Marker(
          //             width: 45.0,
          //             height: 45.0,
          //             point: new latLng.LatLng(lat,long),
          //             builder: (context) => new Container(
          //               child: IconButton(
          //                 tooltip: "My location",
          //                 icon:Icon(Icons.location_on),
          //                 color: Colors.blue,
          //                 iconSize: 70.0,
          //                 onPressed: (){
          //
          //                 },
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //       new MarkerLayerOptions(
          //         markers: [
          //           new Marker(
          //             width: 45.0,
          //             height: 45.0,
          //             point: new latLng.LatLng(9.647111411110227, 123.86350931891319),
          //             builder: (context) => new Container(
          //               child: IconButton(
          //                 tooltip: "your rider",
          //                 icon:Icon(Icons.location_on),
          //                 color: Colors.deepOrange,
          //                 iconSize: 70.0,
          //                 onPressed: (){
          //
          //                 },
          //               ),
          //             ),
          //           ),
          //         ],
          //       )
          //     ],
          //   ),
          // ),
        ],
      ),
      // floatingActionButton:
      // Visibility (
      //   visible : _isGettingLocation == false,
      //    child: Stack(
      //     children: <Widget>[
      //       Positioned(
      //         bottom: 220.0,
      //         right: 10.0,
      //         child: FloatingActionButton(
      //           onPressed: () {
      //             _zoomIn();
      //           },
      //           heroTag: 'Zoom in',
      //           child: Icon(Icons.add),
      //           tooltip: "Zoom in",
      //           backgroundColor: Colors.white60,
      //         ),
      //       ),
      //
      //       Positioned(
      //         bottom: 150.0,
      //         right: 10.0,
      //         child: FloatingActionButton(
      //           onPressed: () {
      //             _zoomOut();
      //           },
      //           heroTag: 'Zoom out',
      //           child: Icon(Icons.remove),
      //           tooltip: "Zoom out",
      //           backgroundColor: Colors.white60,
      //         ),
      //       ),
      //
      //       Positioned(
      //         bottom: 80.0,
      //         right: 10.0,
      //         child: FloatingActionButton(
      //           onPressed: () {
      //             locateRiderLocation();
      //           },
      //           heroTag: 'Locate you rider location',
      //           child: Icon(Icons.motorcycle),
      //           tooltip: "Locate you rider location",
      //           backgroundColor: Colors.white60,
      //         ),
      //       ),
      //       Positioned(
      //         bottom: 10.0,
      //         right: 10.0,
      //         child: FloatingActionButton(
      //           onPressed: () {
      //             locateYourLocation();
      //           },
      //           heroTag: 'My location',
      //           child: Icon(Icons.my_location),
      //           tooltip: "My location",
      //           backgroundColor: Colors.white60,
      //         ),
      //       ),
      //     ],
      // ),
      //  ),
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