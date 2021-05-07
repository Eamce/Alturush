import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile/addressMasterFile.dart';
import 'to_deliverFood.dart';
import 'idmasterfile.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrackOrder extends StatefulWidget {
  @override
  _TrackOrder createState() => _TrackOrder();
}

class _TrackOrder extends State<TrackOrder> with SingleTickerProviderStateMixin{
  var isLoading = true;
  final db = RapidA();
  List listGetTicketNoFood;
  var firstName;
  var lastName;

  Future getTicketNoFood() async{
    var res = await db.getTicketNoFood();
    if (!mounted) return;
    setState(() {
      listGetTicketNoFood = res['user_details'];
      isLoading = false;
    });
  }

  Future toRefresh() async{
    getTicketNoFood();
  }

  moreOptions() {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          title: Text("Options"),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          content: Container(
            height:250.0, // Change as per your requirement
            width: 100.0, // Change as per your requirement
            child: Scrollbar(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () async{
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          // Navigator.of(context).push(logout());
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.clear();
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Log out",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                            ],
                          ),
                       ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.of(context).pop();
                          Navigator.of(context).push(viewIds());
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Avail discount",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                            ],
                          ),
                          //                       child: Text('$f. ${lGetAmountPerTenant[index]['d_bu_name']} - ${lGetAmountPerTenant[index]['d_tenant']}  ₱${oCcy.format(double.parse(lGetAmountPerTenant[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.of(context).pop();
                          Navigator.of(context).push(addressMasterFileRoute());
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Add secondary address",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                            ],
                          ),
                          //                       child: Text('$f. ${lGetAmountPerTenant[index]['d_bu_name']} - ${lGetAmountPerTenant[index]['d_tenant']}  ₱${oCcy.format(double.parse(lGetAmountPerTenant[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.of(context).pop();
                          //wish list
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Your wish list",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                            ],
                          ),
                          //                       child: Text('$f. ${lGetAmountPerTenant[index]['d_bu_name']} - ${lGetAmountPerTenant[index]['d_tenant']}  ₱${oCcy.format(double.parse(lGetAmountPerTenant[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.of(context).pop();
                          //acct setting
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Account settings",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                            ],
                          ),
                          //                       child: Text('$f. ${lGetAmountPerTenant[index]['d_bu_name']} - ${lGetAmountPerTenant[index]['d_tenant']}  ₱${oCcy.format(double.parse(lGetAmountPerTenant[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

 void  getUserName() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName =  prefs.getString('s_firstname');
      lastName = prefs.getString('s_lastname');
    });
  }

  @override
  void initState() {
    getUserName();
//    loadProfile();
    getTicketNoFood();
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, () {
          setState(() {});
        });
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Profile",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
          actions: [
            IconButton(
                icon: Icon(Icons.more_vert_outlined, color: Colors.black54),
                onPressed: () {
                    moreOptions();
                }
            ),
          ],
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ):  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: toRefresh,
                  child: Scrollbar(
                    child: ListView(
                     // physics:  BouncingScrollPhysics(),
                      // shrinkWrap: true,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              child: Card(
                                // elevation: 0.1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 20.0),
                                      child: new Stack(
                                          fit: StackFit.loose,
                                          children: <Widget>[
                                            new Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[
                                                new Container(
                                                    width: 120.0,
                                                    height: 120.0,
                                                    decoration: new BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: new DecorationImage(
                                                        image: new ExactAssetImage(
                                                            'assets/png/as.png'),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                ),
                                              ],
                                            ),
                                            // Padding(
                                            //     padding: EdgeInsets.only(top: 90.0, right: 90.0),
                                            //     child: new Row(
                                            //       mainAxisAlignment:
                                            //       MainAxisAlignment.center,
                                            //       children: <Widget>[
                                            //         GestureDetector(
                                            //             onTap: () {
                                            //
                                            //             },
                                            //             child: new CircleAvatar(
                                            //               backgroundColor: Colors.deepOrange,
                                            //               radius: 20.0,
                                            //               child: new Icon(
                                            //                 Icons.camera_alt,
                                            //                 color: Colors.white,
                                            //               ),
                                            //             )
                                            //         ),
                                            //       ],
                                            //     )),
                                          ]),
                                    ),
                                    Padding(
                                        padding:
                                        EdgeInsets.fromLTRB(5.0, 30.0, 5.0, 15.0),
                                        child: new Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text('$firstName $lastName',
                                              style: GoogleFonts.openSans(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 20.0),
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                child:Column(
                                  children: [
                                   ListView.builder(
                                      shrinkWrap: true,
                                      physics: BouncingScrollPhysics(),
                                      itemCount: listGetTicketNoFood == null ? 0 : listGetTicketNoFood.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        int q = index;
                                        q++;
                                        String type = "";
                                        if(listGetTicketNoFood[index]['order_type_stat'] == '0'){
                                          type = "assets/svg/fast-food.svg";
                                        }else{
                                          type = "assets/svg/basket.svg";
                                        }
                                        return Padding(
                                          padding:EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                                          child: InkWell(
                                            onTap:(){
                                              if(listGetTicketNoFood[index]['order_type_stat'] == '0'){
                                                Navigator.of(context).push(viewUpComingFood(listGetTicketNoFood[index]['d_ticket_id'],listGetTicketNoFood[index]['d_mop'],listGetTicketNoFood[index]['order_type_stat']));
                                              }
                                              else{
                                                Navigator.of(context).push(viewUpComingFood(listGetTicketNoFood[index]['d_ticket_id'],listGetTicketNoFood[index]['d_mop'],listGetTicketNoFood[index]['order_type_stat']));
                                              }
                                             // viewInside(listGetTicketNoFood[index]['d_ticket_id'],listGetTicketNoFood[index]['d_customerId']);
                                            },
                                            child: Container(
                                              height: 93.0,
                                              child: Card(
                                                // elevation: 0.0,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 1.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children:<Widget>[
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Text(listGetTicketNoFood[index]['d_mop'],style: TextStyle(color: Colors.black),),
                                                                Text('$q. Ticket # ${listGetTicketNoFood[index]['d_ticket_id']}',style: TextStyle(fontSize: 20.0,color: Colors.black54, fontWeight: FontWeight.bold)),
                                                              ],
                                                          ),
                                                          Container(
                                                            height: screenHeight/11,
                                                            width: screenWidth/11,
                                                            child: SvgPicture.asset(type),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                            ),
                          ],
                        ),
                     ),
                  ),
                ),
              ],
            ),
//      ),
      ),
    );
  }
}

//
// Route viewUpComingGood(ticketNo,customerId) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) => ToDeliverGood(ticketNo:ticketNo,customerId:customerId),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       var begin = Offset(1.0, 0.0);
//       var end = Offset.zero;
//       var curve = Curves.decelerate;
//       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//       return SlideTransition(
//         position: animation.drive(tween),
//         child: child,
//       );
//     },
//   );
// }

Route viewUpComingFood(ticketNo,dmop,type) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ToDeliverFood(ticketNo:ticketNo,dmop:dmop,type:type),
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

Route viewIds() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => IdMasterFile(),
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

Route addressMasterFileRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AddressMasterFile(),
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

