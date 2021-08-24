import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile/addressMasterFile.dart';
import 'to_deliverFood.dart';
import 'idmasterfile.dart';
import 'package:badges/badges.dart';
import 'profile/changePassword.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:arush/profile_page.dart';

class TrackOrder extends StatefulWidget {
  @override
  _TrackOrder createState() => _TrackOrder();
}

class _TrackOrder extends State<TrackOrder> with SingleTickerProviderStateMixin{
  var isLoading = true;
  final db = RapidA();
  List listGetTicketNoFood = []; //pending list
  List listGetTicketOnTransit = [];
  List listGetTicketOnDelivered = [];
  var firstName;
  var lastName;
  var status;
  var pendingCounter = "";
  var onTransitCounter = "";
  var deliveredCounter = "";

  Future getTicketNoFood() async{
    var res = await db.getTicketNoFood();
    if (!mounted) return;
    setState(() {
      listGetTicketNoFood = res['user_details'];
      pendingCounter = listGetTicketNoFood[0]['count'].toString();
    });
  }


  Future getTicketNoFoodOnTransit() async{
    var res = await db.getTicketNoFoodOnTransit();
    if (!mounted) return;
    setState(() {
      listGetTicketOnTransit = res['user_details'];
      onTransitCounter = listGetTicketOnTransit[0]['count'].toString();
      print(onTransitCounter);
    });
  }

  Future getTicketNoFoodOnDelivered() async{
    var res = await db.getTicketNoFoodOnDelivered();
    if (!mounted) return;
    setState(() {
      listGetTicketOnDelivered = res['user_details'];
      deliveredCounter = listGetTicketOnDelivered[0]['count'].toString();
    });
  }




  Future toRefresh() async{
    getTicketNoFood(); //pending request
    getTicketNoFoodOnTransit(); //on transit request
    getTicketNoFoodOnDelivered(); // on delivered
    isLoading = false;
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
                          Navigator.of(context).push(changePassword());
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Change password",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
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
    toRefresh();
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, () {
          setState(() {

          });
        });
        return true;
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            elevation: 0.0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text("Profile",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
            actions: [
              InkWell(
                customBorder: CircleBorder(),
                onTap: (){
                  Navigator.of(context).push(profile());
                },
                child: Container(
                  width: 70.0,
                  height: 70.0,
                  child: Padding(
                    padding:EdgeInsets.all(5.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage("https://coachpennylove.com/wp-content/uploads/2019/08/facetune_29-07-2019-02-58-10.jpg"),
                    ),
                  ),
                ),
              ),

              // IconButton(
              //     icon: Icon(Icons.more_vert_outlined, color: Colors.black54),
              //     onPressed:(){
              //         moreOptions();
              //     }
              // ),
            ],
            bottom: TabBar(
              indicatorWeight: 2.0,
              indicatorColor: Colors.deepOrange,
              labelColor: Colors.black87,
              tabs: [
                Tab(child: Badge( badgeColor: Colors.white70,position: BadgePosition.topEnd(top: -16, end: -15),badgeContent: Text('$pendingCounter',style: TextStyle(fontSize: 15.0),), child: Text("Pending",style: TextStyle(fontWeight: FontWeight.bold),))),
                Tab(child: Badge( badgeColor: Colors.white70,position: BadgePosition.topEnd(top: -16, end: -15),badgeContent: Text('$onTransitCounter',style: TextStyle(fontSize: 15.0),), child: Text("On transit",style: TextStyle(fontWeight: FontWeight.bold),))),
                Tab(child: Badge( badgeColor: Colors.white70,position: BadgePosition.topEnd(top: -16, end: -15),badgeContent: Text('$deliveredCounter',style: TextStyle(fontSize: 15.0),), child: Text("Delivered",style: TextStyle(fontWeight: FontWeight.bold),))),
                Tab(child: Badge( badgeColor: Colors.white70,position: BadgePosition.topEnd(top: -16, end: -15),badgeContent: Text('$onTransitCounter',style: TextStyle(fontSize: 15.0),), child: Text("Cancelled",style: TextStyle(fontWeight: FontWeight.bold),))),
              ],
            ),
          ),
            body: isLoading
                ? Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
            ): TabBarView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: toRefresh,
                        child: Scrollbar(
                          child: ListView(
                            children: [
                            Padding(
                                padding:EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                              child:ListView.builder(
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: listGetTicketNoFood == null ? 0 : listGetTicketNoFood.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    String type = "";
                                    if(listGetTicketNoFood[index]['order_type_stat'] == '0'){
                                      type = "assets/svg/fast-food.svg";
                                    }else{
                                      type = "assets/svg/basket.svg";
                                    }
                                    return Padding(
                                      padding:EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
                                      child: InkWell(
                                        onTap:(){
                                          if(listGetTicketNoFood[index]['order_type_stat'] == '0'){
                                            Navigator.of(context).push(viewUpComingFood(1,listGetTicketNoFood[index]['d_ticket_id'],listGetTicketNoFood[index]['d_mop'],listGetTicketNoFood[index]['order_type_stat']));
                                          }
                                          else{
                                            Navigator.of(context).push(viewUpComingFood(1,listGetTicketNoFood[index]['d_ticket_id'],listGetTicketNoFood[index]['d_mop'],listGetTicketNoFood[index]['order_type_stat']));
                                          }
                                          // viewInside(listGetTicketNoFood[index]['d_ticket_id'],listGetTicketNoFood[index]['d_customerId']);
                                        },
                                        child: Container(
                                          height: 80.0,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            elevation: 0.0,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 5.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children:<Widget>[
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text('${listGetTicketNoFood[index]['d_mop']}',style: TextStyle(color: Colors.black),),
                                                          Text('Ticket # ${listGetTicketNoFood[index]['d_ticket_id']}',style: TextStyle(fontSize: 20.0,color: Colors.black54, fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                      Container(
                                                        height: screenHeight/15,
                                                        width: screenWidth/15,
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
                                  }),

                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: toRefresh,
                        child: Scrollbar(
                          child: ListView(
                            children: [
                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                                child:ListView.builder(
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    itemCount: listGetTicketOnTransit == null ? 0 : listGetTicketOnTransit.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      String type = "";
                                      if(listGetTicketOnTransit[index]['order_type_stat'] == '0'){
                                        type = "assets/svg/fast-food.svg";
                                      }else{
                                        type = "assets/svg/basket.svg";
                                      }
                                      return Padding(
                                        padding:EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
                                        child: InkWell(
                                          onTap:(){
                                            if(listGetTicketOnTransit[index]['order_type_stat'] == '0'){
                                              Navigator.of(context).push(viewUpComingFood(0,listGetTicketOnTransit[index]['d_ticket_id'],listGetTicketOnTransit[index]['d_mop'],listGetTicketOnTransit[index]['order_type_stat']));
                                            }
                                            else{
                                              Navigator.of(context).push(viewUpComingFood(0,listGetTicketOnTransit[index]['d_ticket_id'],listGetTicketOnTransit[index]['d_mop'],listGetTicketOnTransit[index]['order_type_stat']));
                                            }
                                            // viewInside(listGetTicketNoFood[index]['d_ticket_id'],listGetTicketNoFood[index]['d_customerId']);
                                          },
                                          child: Container(
                                            height: 80.0,
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              elevation: 0.0,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 5.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children:<Widget>[
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Text('${listGetTicketOnTransit[index]['d_mop']}',style: TextStyle(color: Colors.black),),
                                                            Text('Ticket # ${listGetTicketOnTransit[index]['d_ticket_id']}',style: TextStyle(fontSize: 20.0,color: Colors.black54, fontWeight: FontWeight.bold)),
                                                          ],
                                                        ),
                                                        Container(
                                                          height: screenHeight/15,
                                                          width: screenWidth/15,
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
                                    }),

                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: toRefresh,
                        child: Scrollbar(
                          child: ListView(
                            children: [
                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                                child:ListView.builder(
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    itemCount: listGetTicketOnDelivered == null ? 0 : listGetTicketOnDelivered.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      String type = "";
                                      if(listGetTicketOnDelivered[index]['order_type_stat'] == '0'){
                                        type = "assets/svg/fast-food.svg";
                                      }else{
                                        type = "assets/svg/basket.svg";
                                      }
                                      return Padding(
                                        padding:EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
                                        child: InkWell(
                                          onTap:(){
                                            if(listGetTicketOnDelivered[index]['order_type_stat'] == '0'){
                                              Navigator.of(context).push(viewUpComingFood(0,listGetTicketOnDelivered[index]['d_ticket_id'],listGetTicketOnDelivered[index]['d_mop'],listGetTicketOnDelivered[index]['order_type_stat']));
                                            }
                                            else{
                                              Navigator.of(context).push(viewUpComingFood(0,listGetTicketOnDelivered[index]['d_ticket_id'],listGetTicketOnDelivered[index]['d_mop'],listGetTicketOnDelivered[index]['order_type_stat']));
                                            }
                                            // viewInside(listGetTicketNoFood[index]['d_ticket_id'],listGetTicketNoFood[index]['d_customerId']);
                                          },
                                          child: Container(
                                            height: 80.0,
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              elevation: 0.0,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 5.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children:<Widget>[
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Text('${listGetTicketOnDelivered[index]['d_mop']}',style: TextStyle(color: Colors.black),),
                                                            Text('Ticket # ${listGetTicketOnDelivered[index]['d_ticket_id']}',style: TextStyle(fontSize: 20.0,color: Colors.black54, fontWeight: FontWeight.bold)),
                                                          ],
                                                        ),
                                                        Container(
                                                          height: screenHeight/15,
                                                          width: screenWidth/15,
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
                                    }),

                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.directions_car, size: 350),
              ],
            ),
          ),
      ),
    );
  }
}

Route viewUpComingFood(pend,ticketNo,dmop,type) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ToDeliverFood(pend:pend,ticketNo:ticketNo,dmop:dmop,type:type),
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

Route changePassword() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ChangePassword(),
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

Route profile(){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
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

