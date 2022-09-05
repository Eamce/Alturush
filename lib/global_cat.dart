import 'package:arush/profile_page.dart';
import 'package:arush/search.dart';
import 'package:arush/track_order.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_button/sleek_button.dart';

import 'create_account_signin.dart';
import 'db_helper.dart';
import 'grocery/gc_loadStore.dart';
import 'grocery/groceryMain.dart';
import 'load_cart.dart';
import 'load_tenants.dart';


class GlobalCat extends StatefulWidget {
  final buCode;
  final buLogo;
  final buName;
  final buAcroname;
  GlobalCat({Key key, @required this.buLogo,this.buName,this.buCode, this.buAcroname}) : super(key: key);
  @override
  _GlobalCat createState() => _GlobalCat();
}

class _GlobalCat extends State<GlobalCat>{
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final db = RapidA();
  List listProfile;
  List loadTenants;
  int gridCount;
  List listCounter;
  List globalCat;
  List buData;

  var isLoading = true;
  var cartLoading = true;
  var profileLoading = true;
  var cartCount;
  var profilePicture = "";

  List listSubtotal;
  var subtotal;


//   Future loadTenant() async {
// //    var res = await db.getTenants(widget.buCode);
//     var res = await db.getTenantsCi(widget.buCode);
//     if (!mounted) return;
//     setState(() {
//       isLoading = false;
//       loadTenants = res['user_details'];
//     });
//   }

  Future getGlobalCat() async{
    var res = await db.getGlobalCat();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      globalCat = res['user_details'];
      print(globalCat);
    });
  }

  Future loadProfilePic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status  = prefs.getString('s_status');
    if(status != null) {
      var res = await db.loadProfile();
      if (!mounted) return;
      setState(() {
        listProfile = res['user_details'];
        profilePicture = listProfile[0]['d_photo'];
        profileLoading = false;
      });
    }
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

  Future loadBu() async {
    var res = await db. getBusinessUnitsCi();
    if (!mounted) return;
    setState(() {
      buData = res['user_details'];
    });
  }


  String status;
  Future loadProfile() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status  = prefs.getString('s_status');
  }

  @override
  void initState() {
    super.initState();
    getGlobalCat();
    getCounter();
   print(widget.buAcroname);
    loadProfile();
    loadProfilePic();
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/png/alturush_text_logo.png',
                fit: BoxFit.contain,
                height: 30,
              ),
              // Container(
              //   padding: const EdgeInsets.all(8.0), child: Text("Categories",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),)
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black54,size: 20,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search_outlined, color: Colors.black54, size: 25,),
                onPressed: () async {
                  Navigator.of(context).push(_search());
                }
            ),
            status == null ? TextButton(
              onPressed: () async {
                await Navigator.of(context).push(_signIn());
                getCounter();
                loadProfile();
              },
              child: Text("Login",style: GoogleFonts.openSans(color:Colors.deepOrange,fontWeight: FontWeight.bold,fontSize: 16.0),),
            ):        InkWell(
              customBorder: CircleBorder(),
              onTap: () async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String username = prefs.getString('s_customerId');
                if(username == null){
                  await Navigator.of(context).push(_signIn());
                  getCounter();
                  loadProfile();
                  loadProfilePic();
                }else{
                  await Navigator.of(context).push(profile());
                  getCounter();
                  loadProfile();
                  loadProfilePic();
                }
              },
              child: Container(
                width: 50.0,
                height: 50.0,
                child: Padding(
                  padding:EdgeInsets.all(5.0),
                  child: profileLoading ? CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                  ) : CircleAvatar(
                    backgroundImage: NetworkImage(profilePicture),
                  ),
                ),
              ),
            ),
            IconButton(
                icon: Icon(Icons.receipt_long_rounded, color: Colors.black54, size: 25.0,),
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
                onRefresh: getGlobalCat,
                child: Scrollbar(
                  child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      SizedBox(
                        height: 120.0,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 20.0),
                                  ),
                                  // subtitle: Text(
                                  //   'Select Categories',
                                  //   style: GoogleFonts.openSans(
                                  //       color: Colors.black,
                                  //       fontStyle: FontStyle.normal,
                                  //       fontSize: 13.0),
                                  // ),
                                  dense: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 5, 0, 20),
                        child: Text('CATEGORIES',style: GoogleFonts.openSans(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            fontSize: 18.0)),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),

                      ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: globalCat == null ? 0 : globalCat.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () async{
                                if (globalCat[index]['id'] != '2'){
                                  await Navigator.of(context).push(_gotoTenants(
                                      widget.buLogo,
                                      widget.buName,
                                      widget.buAcroname,
                                      widget.buCode,
                                      globalCat[index]['cat_picture'],
                                      globalCat[index]['category'],
                                      globalCat[index]['id']
                                  ));
                                } else {
                                  print('unya naka');
                                  // Navigator.of(context).push(_loadGC(
                                  //     widget.buLogo,
                                  //     globalCat[index]['category'],
                                  //     globalCat[index]['id'],
                                  //     widget.buName,
                                  //     widget.buCode
                                  // ));
                                }


                                // selectCategory(context,widget.buCode,loadTenants[index]['logo'], loadTenants[index]['tenant_id'], loadTenants[index]['d_tenant_name']);
                              },
                              child:Container(
                                height: 100.0,
                                width: 30.0,

                                child: Card(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      ListTile(
                                        leading:Container(
                                          width: 50.0,
                                          height: 50.0,
                                          decoration: new BoxDecoration(
                                            image: new DecorationImage(
                                              image: new NetworkImage(globalCat[index]['cat_picture']),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                            border: new Border.all(
                                              color: Colors.black54,
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        title: Text(globalCat[index]['category'].toString(),style: GoogleFonts.openSans(color: Colors.black54,fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 18.0),),
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
                          rounded: true,
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

Route _search() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Search(),
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

Route _gotoTenants(buLogo, buName, buAcroname, buCode, globalPic, globalCat, globalID) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => LoadTenants(buLogo:buLogo, buName:buName, buAcroname:buAcroname, buCode:buCode, globalPic:globalPic, globalCat:globalCat, globalID:globalID),
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

Route _loadGC(logo,categoryName,categoryNo,businessUnit,bUnitCode){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GcLoadStore(logo:logo,categoryName:categoryName,categoryNo:categoryNo,businessUnit:businessUnit,bUnitCode:bUnitCode),
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