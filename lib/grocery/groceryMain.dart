import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../db_helper.dart';
import 'package:intl/intl.dart';
import '../create_account_signin.dart';
import '../track_order.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:nice_button/nice_button.dart';
import '../main.dart';
import 'gc_loadStore.dart';
import 'gc_cart.dart';
import 'package:arush/idmasterfile.dart';
import 'package:arush/showDpn2.dart';
import '../load_bu.dart';
//paul jearic

class GroceryMain extends StatefulWidget {
  @override
  _GroceryMain createState() => _GroceryMain();
}

class _GroceryMain extends State<GroceryMain> with SingleTickerProviderStateMixin{
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  List loadProfileData;
  List buData;
  List loadSubtotal;
  List listCounter;
  String firstName = "";
  String quotes = "";
  String author = "";
  String profilePhoto;
  String status;
  var isLoading = true;
  var cartLoading = true;
  var isLoading1 = true;
  var cartCount = 0;
  var subTotal ;


  Future loadBu() async{
//    await db.init();
//    var res = await db.getBusinessUnits();
//    getGcCounter();
//    getCounter();
    listenCartCount();
    setState(() {
      isLoading = true;
      isLoading1 = false;
      cartLoading = true;
    });
    var res = await db.getBusinessUnitsCi();
    if (!mounted) return;
    setState(() {
      cartLoading = false;
      isLoading = false;
      buData = res['user_details'];
    });
  }

  Future getCounter() async {
    var res = await db.getGcCounter();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      listCounter = res['user_details'];
    });
  }

  Future listenCartCount() async{
    var res = await db.getGcCounter();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      cartLoading = false;
      listCounter = res['user_details'];
      cartCount = listCounter[0]['num'];
    });
  }


  Future loadGcSubTotal() async{
    var res = await db.loadGcSubTotal();
    if (!mounted) return;
    setState(() {
      isLoading1 = false;
      loadSubtotal = res['user_details'];
      if(loadSubtotal[0]['d_subtotal'] == null){
        subTotal = 0;
      }else{
        subTotal = loadSubtotal[0]['d_subtotal'].toString();
      }
    });
  }

  Future loadProfile() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status  = prefs.getString('s_status');
    if(status != null) {
      var res = await db.loadProfile();
      loadGcSubTotal();
      // getCounter();
      // timer = Timer.periodic(Duration(seconds: 5), (Timer t) => loadGcSubTotal());
      if (!mounted) return;
      setState(() {
        loadProfileData = res['user_details'];
        firstName = loadProfileData[0]['d_fname'];
//          profilePhoto = loadProfileData[0]['d_photo'];
        isLoading = false;
      });
    }
    else{
      firstName = "";
      profilePhoto = "";
      isLoading = false;
    }
  }

  Future futureLoadQuotes() async{
    var res = await db.futureLoadQuotes();
    if (!mounted) return;
    setState(() {
      quotes = res["content"];
      author = "-"+res["author"];
    });
  }

  selectGcCategory1() async{

  }
  void selectGcCategory(BuildContext context,logo,businessUnit,bUnitCode) async{
    List categoryData;
    var res = await db.getGcCategories();
    if (!mounted) return;
    setState(() {
      categoryData = res['user_details'];
      print(categoryData);
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
            height: MediaQuery.of(context).size.height/1.5,
            child: Scrollbar(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 20.0, 20.0, 20.0),
                    child:Text("Category",style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),),
                  ),

                  Expanded(
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
                                    onTap: () async{
                                      Navigator.pop(context);
                                      await Navigator.of(context).push(_loadGC(logo,categoryData[index]['category_name'],categoryData[index]['category_no'],businessUnit,bUnitCode));
                                      listenCartCount();
                                      loadProfile();
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
                                              title: Text(categoryData[index]['category_name'].toString(),style: GoogleFonts.openSans(color: Colors.black54,fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 22.0),),
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
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    selectGcCategory1();
    futureLoadQuotes();
    loadProfile();
    loadBu();
    listenCartCount();
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
        iconTheme: new IconThemeData(color: Colors.black),
        actions: [
          status == null ? TextButton(
            onPressed: () async {
              await Navigator.of(context).push(_signIn());
              loadProfile();
              getCounter();
              listenCartCount();
            },
            child: Text("Login",style: GoogleFonts.openSans(color:Colors.deepOrange,fontWeight: FontWeight.bold,fontSize: 18.0),),
          ): IconButton(
              icon: Icon(Icons.person, color: Colors.black),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String username = prefs.getString('s_customerId');
                if(username == null){
                  await Navigator.of(context).push(_signIn());
                  loadProfile();
                  getCounter();
                  listenCartCount();
                }else{
                  await Navigator.of(context).push(_profilePage());
                  loadProfile();
                  getCounter();
                  listenCartCount();
                }
              }
          ),
        ],
        title: Text("Grocery Home",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
      ),
      drawer:Container(
        color: Colors.deepOrange,
        width: 280,
        child: Drawer(
          child: Container(
            color: Colors.white,
            child:ListView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  child:Column(
                    children: <Widget>[
                      SizedBox(
                        height: 70.0,
                      ),
                      SizedBox(
                        height: 35.0,
                      ),
                      Center(
                        child: Text("Sign up/Log in",style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 23.0),),
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                      NiceButton(
                        background:Colors.redAccent ,
                        radius: 20,
                        padding: const EdgeInsets.all(15),
                        text: "Order Food",
                        gradientColors: [Colors.redAccent, Colors.deepOrangeAccent],
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(_loadFood());
                        },
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                      // ListTile(
                      //     leading: Icon(Icons.home_outlined,size: 30.0,),
                      //     title: Text('Home',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 16.0),),
                      //     onTap: () async{
                      //       Navigator.of(context).pop();
                      //       Navigator.of(context).push(_mainPage());
                      //     }
                      // ),
                      ListTile(
                          leading: Icon(Icons.person,size: 30.0,),
                          title: Text('Profile',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 16.0),),
                          onTap: () async{
                            Navigator.of(context).pop();
                            // SharedPreferences prefs = await SharedPreferences.getInstance();
                            // String status  = prefs.getString('s_status');
                            // status != null ? Navigator.of(context).push(_profilePage()) : Navigator.of(context).push(_signIn());

                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String username = prefs.getString('s_customerId');
                            if(username == null){
                              await Navigator.of(context).push(_signIn());
                              getCounter();
                              listenCartCount();
                              loadProfile();
                            }else{
                              await Navigator.of(context).push(_signIn());
                              getCounter();
                              listenCartCount();
                              loadProfile();
                            }
                          }
                      ),
                      ListTile(
                          leading: Icon(Icons.add,size: 30.0,),
                          title: Text('Add discount',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 16.0),),
                          onTap: () async{
                            Navigator.of(context).pop();
                            // SharedPreferences prefs = await SharedPreferences.getInstance();
                            // String status  = prefs.getString('s_status');
                            // status != null ? Navigator.of(context).push(viewIds()) : Navigator.of(context).push(_signIn());
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String username = prefs.getString('s_customerId');
                            if(username == null){
                              await Navigator.of(context).push(_signIn());
                              getCounter();
                              listenCartCount();
                              loadProfile();
                            }else{
                              await Navigator.of(context).push(_signIn());
                              getCounter();
                              listenCartCount();
                              loadProfile();
                            }
                          }
                      ),
                      // ListTile(
                      //   leading: Icon(Icons.info_outline,size: 30.0,color: Colors.green,),
                      //   title: Text('About',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 16.0),),
                      // ),
                      ListTile(
                        leading: Icon(Icons.info_outline,size: 30.0,),
                        title: Text('Data privacy',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 16.0),),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(showDpn2());
                          }
                      ),
//                      ListTile(
//                            leading: Icon(Icons.help_outline,size: 30.0,color: Colors.deepOrange,),
//                            title: Text('Log out',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 16.0),),
//                            onTap: () async{
//                                Navigator.of(context).pop();
//                                _googleSignIn.signOut();
//                                SharedPreferences prefs = await SharedPreferences.getInstance();
//                                prefs.clear();
//                            }
//                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body:  Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: loadBu,
                child:Scrollbar(
                  child:ListView(
                    // physics: AlwaysScrollableScrollPhysics(),
                    // physics:  BouncingScrollPhysics(),
                    children: <Widget>[
                      SizedBox(
                        height: 35.0,
                      ),
                      Center(
                        child:Text("Howdy ${firstName.toString()}",style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 23.0),),
                      ),
                      Center(
                        child:Text(quotes,style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                      ),
                      Center(
                        child:Text(author,style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                      isLoading
                          ? Center(
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      ): ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: buData == null ? 0: buData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () async{
                                selectGcCategory(context,buData[index]['logo'],buData[index]['business_unit'],buData[index]['bunit_code']);
                                // await Navigator.of(context).push(_loadGC(buData[index]['logo'],buData[index]['business_unit'],buData[index]['bunit_code']));
                                // listenCartCount();
                                // loadProfile();
                              },
                              child:Container(
                                height: 120.0,
                                width: 30.0,
                                child: Card(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
//                                  crossAxisAlignment: CrossAxisAlignment.center,
//                                  mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading:Container(
                                          width: 60.0,
                                          height: 60.0,
                                          decoration: new BoxDecoration(
                                            image: new DecorationImage(
                                              image: new NetworkImage(buData[index]['logo']),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                            border: new Border.all(
                                              color: Colors.black54,
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        title: Text(buData[index]['business_unit'],style: GoogleFonts.openSans(color: Colors.black54,fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 22.0),),
                                      ),
                                    ],
                                  ),
                                  elevation: 0.2,
                                  margin: EdgeInsets.all(3),
                                ),
                              ),
                            );
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Row(
                children: <Widget>[

                  Visibility(
                    visible: cartCount == 0 ? false : true,
                    child: Flexible(
                      child: SleekButton(
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String username = prefs.getString('s_customerId');
                          if(username == null){
                            await Navigator.of(context).push(_signIn());
                            listenCartCount();
                            loadProfile();
                          }else{
                            await Navigator.of(context).push(_gcViewCart());
                            listenCartCount();
                            loadProfile();
                          }

                        },
                        style: SleekButtonStyle.flat(
                          color: Colors.green,
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
                          ) : Row(
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
                                  fontSize: 13.0),
                              ),
                               isLoading1
                                  ? Center(
                                child:Container(
                                  height:16.0 ,
                                  width: 16.0,
                                  child: CircularProgressIndicator(
//                                          strokeWidth: 1,
                                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              ) :
                              Text("₱ ${subTotal.toString()}",style: TextStyle(
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Route _gcViewCart(){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GcLoadCart(),
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



Route _loadFood(){
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

Route showDpn2() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ShowDpn2(),
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