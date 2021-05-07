import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'load_store.dart';
import 'db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'load_cart.dart';
import 'create_account_signin.dart';
import 'track_order.dart';
import 'package:sleek_button/sleek_button.dart';
import 'dart:async';
import 'package:intl/intl.dart';
class LoadTenants extends StatefulWidget {
  final buCode;
  final buLogo;
  final buName;
  LoadTenants({Key key, @required this.buLogo,this.buName,this.buCode}) : super(key: key);
  @override
  _LoadTenants createState() => _LoadTenants();
}

class _LoadTenants extends State<LoadTenants> {
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final db = RapidA();
  List loadTenants;
  int gridCount;
  List listCounter;
  var isLoading = true;
  var cartLoading = true;
  var cartCount;
  List listSubtotal;
  var subtotal;

  Future loadTenant() async {
//    var res = await db.getTenants(widget.buCode);
    var res = await db.getTenantsCi(widget.buCode);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      loadTenants = res['user_details'];
    });
  }

  Future getCounter() async {
    var res = await db.getCounter();
    if (!mounted) return;
    setState(() {
      cartLoading = false;
      listCounter = res['user_details'];
      cartCount = listCounter[0]['num'];
    });
  }

  String status;
  Future loadProfile() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status  = prefs.getString('s_status');
  }

  void selectCategory(BuildContext context ,buCode,logo,tenantId, tenantName) async{
    List categoryData;
    var res = await db.selectCategory(tenantId);
    if (!mounted) return;
    setState(() {
      categoryData = res['user_details'];
    });

    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight:  Radius.circular(10),topLeft:  Radius.circular(10)),
        ),
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height/2,
            child: Scrollbar(
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: categoryData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(_loadStore(categoryData[index]['category_id'],buCode,logo,tenantId,tenantName));
                              },
                              child:Container(
                                height: 120.0,
                                width: 30.0,
                                child: Card(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      ListTile(
                                        leading:Container(
                                          width: 60.0,
                                          height: 60.0,
                                          decoration: new BoxDecoration(
                                            image: new DecorationImage(
                                              image: new NetworkImage(categoryData[index]['image']),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                            border: new Border.all(
                                              color: Colors.black54,
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        title: Text(categoryData[index]['category'].toString(),style: GoogleFonts.openSans(color: Colors.black54,fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 22.0),),
                                      ),
                                    ],
                                  ),
                                  elevation: 0,
                                  margin: EdgeInsets.all(3),
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getCounter();
    loadTenant();
    loadProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    screenWidth <= 400 ? gridCount = 2 : gridCount = 3;
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return true;
        },
    child: Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.1,
        iconTheme: new IconThemeData(color: Colors.black),
        title: Row(
          children: [
            Container(
              width: 30.0,
              height: 30.0,
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new NetworkImage(widget.buLogo),
                  fit: BoxFit.cover,
                ),
                borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                border: new Border.all(
                  color: Colors.black54,
                  width: 0.5,
                ),
              ),
            ),
            SizedBox(
              width: 5.0,
            ),
            Text("Select tenant",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          status == null ? TextButton(
            onPressed: () async {
              await Navigator.of(context).push(_signIn());
              getCounter();
              loadProfile();
            },
            child: Text("Login",style: GoogleFonts.openSans(color:Colors.deepOrange,fontWeight: FontWeight.bold,fontSize: 18.0),),
          ): IconButton(
              icon: Icon(Icons.person, color: Colors.black),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String username = prefs.getString('s_customerId');
                if(username == null){
                  await Navigator.of(context).push(_signIn());
                  getCounter();
                  loadProfile();
                }else{
                  await Navigator.of(context).push(_profilePage());
                  getCounter();
                  loadProfile();
                }
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
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadTenant,
                child: Scrollbar(
                  child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      SizedBox(
                        height: 150.0,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(25, 20, 25, 5),
                          child: Card(
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ListTile(
                                  leading:Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: new BoxDecoration(
                                      image: new DecorationImage(
                                        image: new NetworkImage(widget.buLogo),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                      border: new Border.all(
                                        color: Colors.black54,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  title: Text(widget.buName,
                                    style: GoogleFonts.openSans(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 15.0),
                                  ),
                                  subtitle: Text(
                                    'Select from our top tenants below',
                                    style: GoogleFonts.openSans(
                                        color: Colors.black,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 13.0),
                                  ),
                                  dense: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
//
                      SizedBox(
                        height: 20.0,
                      ),
                      ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: loadTenants == null ? 0 : loadTenants.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                selectCategory(context,widget.buCode,loadTenants[index]['logo'], loadTenants[index]['tenant_id'], loadTenants[index]['d_tenant_name']);
                                // Navigator.of(context).push(_loadStore(widget.buCode,loadTenants[index]['logo'], loadTenants[index]['tenant_id'], loadTenants[index]['d_tenant_name']));

                              },
                              child:Container(
                                height: 120.0,
                                width: 30.0,

                                child: Card(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      ListTile(
                                        leading:Container(
                                          width: 60.0,
                                          height: 60.0,
                                          decoration: new BoxDecoration(
                                            image: new DecorationImage(
                                              image: new NetworkImage(loadTenants[index]['logo']),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                            border: new Border.all(
                                              color: Colors.black54,
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        title: Text(loadTenants[index]['d_tenant_name'].toString(),style: GoogleFonts.openSans(color: Colors.black54,fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 22.0),),
                                      ),
                                    ],
                                  ),
                                  elevation: 0,
                                  margin: EdgeInsets.all(3),
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                ),

            ),
          ),
          Visibility(
            visible: cartCount == 0 ? false : true,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: SleekButton(
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String username = prefs.getString('s_customerId');
                        if(username == null){
                          await Navigator.of(context).push(_signIn());
                          getCounter();
                        }else{
                          await Navigator.of(context).push(_loadCart());
                          getCounter();
                        }
                      },
                      style: SleekButtonStyle.flat(
                        color: Colors.deepOrange,
                        inverted: false,
                        rounded: false,
                        size: SleekButtonSize.big,
                        context: context,
                      ),
                      child: Center(
                        child: cartLoading
                            ? Center(
                          child:Container(
                            height:16.0 ,
                            width: 16.0,
                            child: CircularProgressIndicator(
//                                          strokeWidth: 1,
                              valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ) :  Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("View cart  ${cartCount.toString()}",style: TextStyle(
                                shadows: [
                                  Shadow(
                                    blurRadius: 1.0,
                                    color: Colors.black54,
                                    offset: Offset(1.0, 1.0),
                                  ),
                                ],
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0),),
//                            Text("₱ ${oCcy.format(num.parse(subtotal.toString()))}",style: TextStyle(
//                                shadows: [
//                                  Shadow(
//                                    blurRadius: 1.0,
//                                    color: Colors.black54,
//                                    offset: Offset(1.0, 1.0),
//                                  ),
//                                ],
//                                fontStyle: FontStyle.normal,
//                                fontWeight: FontWeight.bold,
//                                fontSize: 13.0),),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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


Route _loadCart() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => LoadCart(),
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


Route _profilePage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => TrackOrder(),
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

Route _loadStore(categoryId,buCode, storeLogo, tenantCode, tenantName) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => LoadStore(categoryId:categoryId, buCode:buCode, storeLogo:storeLogo, tenantCode:tenantCode, tenantName:tenantName),
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

Route _signIn() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => CreateAccountSignIn(),
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
