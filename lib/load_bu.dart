import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'create_account_signin.dart';
import 'load_tenants.dart';
import 'db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'track_order.dart';
import 'load_cart.dart';
import 'dart:async';
import 'package:sleek_button/sleek_button.dart';
import 'package:intl/intl.dart';
import 'package:nice_button/nice_button.dart';
import 'grocery/groceryMain.dart';
import 'package:arush/idmasterfile.dart';
import 'main.dart';


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage>  {

  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final db = RapidA();
  final province = TextEditingController();
  final town = TextEditingController();
  List listCounter;
  List buData;
  List loadProfileData;
  List listSubtotal;
  List loadLocationData;
  List loadQuotesData;
  var isLoading = true;
  var isVisible = true;
  var cartCount;
  var subtotal;
  var locationString;
  var cartLoading = true;
  String firstName="";
  String profilePhoto;
  String placeRemark;
  String quotes = "";
  String author = "";
  int counter;
  int provinceId;
  int townID;

  Future loadBu() async{

    var res = await db.getBusinessUnitsCi();
    if (!mounted) return;
    setState(() {
      buData = res['user_details'];
    });
    Timer(Duration(milliseconds:500), () {
      _needsScroll = true;
      _scrollToEnd();
    });
  }

  _scrollToEnd() async{
    if (_needsScroll) {
      _needsScroll = false;
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
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

  String status;
  Future loadProfile() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status  = prefs.getString('s_status');
    if(status != null) {
      var res = await db.loadProfile();
      if (!mounted) return;
      setState(() {
        loadProfileData = res['user_details'];
        firstName = loadProfileData[0]['d_fname'];
        isLoading = false;
        isVisible = true;
      });
    }
    else{
      locationString = "Location";
      firstName = "";
      profilePhoto = "";
      isVisible = false;
      isLoading = false;
    }
  }

  Future getCounter() async {
    var res = await db.getCounter();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      listCounter = res['user_details'];
    });
  }

  Future listenCartCount() async{
    var res = await db.getCounter();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      cartLoading = false;
      listCounter = res['user_details'];
      cartCount = listCounter[0]['num'];
    });
  }

 List getProvinceData;
  selectProvince() async{
    var res = await db.getProvince();
    if (!mounted) return;
    setState(() {
      getProvinceData = res['user_details'];
    });
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text('Select Province',),
          content: Container(
            height: 90.0,
            width: 300.0,
            child: Scrollbar(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: getProvinceData == null ? 0 : getProvinceData.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap:(){
                      province.text = getProvinceData[index]['prov_name'];
                      provinceId = int.parse(getProvinceData[index]['prov_id']);
                      town.clear();
                      Navigator.of(context).pop();
                    },
                    child: ListTile(
                      title: Text(getProvinceData[index]['prov_name']),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Clear',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // province.clear();
                // town.clear();
                // barangay.clear();
              },
            ),
          ],
        );
      },
    );
  }

  List getTownData;
  selectTown() async{
    var res = await db.selectTown(provinceId.toString());
    if (!mounted) return;
    setState(() {
      getTownData = res['user_details'];
    });
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text('Select Town',),
          content: Container(
            height: 300.0,
            width: 300.0,
            child: Scrollbar(
              child:ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: getTownData == null ? 0 : getTownData.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap:(){
                      town.text = getTownData[index]['town_name'];
                      townID = int.parse(getTownData[index]['town_id']);
                      Navigator.of(context).pop();
                    },
                    child: ListTile(
                      title: Text(getTownData[index]['town_name']),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Clear',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                town.clear();
              },
            ),
          ],
        );
      },
    );
  }

  ScrollController _scrollController = new ScrollController();
  bool _needsScroll = false;

  @override
  void initState(){
    futureLoadQuotes();
    listenCartCount();
    loadProfile();
    // loadBu();
    super.initState();
  }

  @override
  void dispose() {
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
            style: TextButton.styleFrom(
              primary: Colors.red,
              onSurface: Colors.red,
            ),
            onPressed: () async {
              await Navigator.of(context).push(_signIn());
              listenCartCount();
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
                  listenCartCount();
                  loadProfile();
                }else{
                  await Navigator.of(context).push(_profilePage());
                  listenCartCount();
                  loadProfile();
                }
              }
          ),
        ],
        title: Text("Order Food",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
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
                        height: 30.0,
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
                        text: "Order groceries",
                        gradientColors: [Colors.green, Colors.lightGreen],
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(_loadGrocery());
                        },
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                      ListTile(
                          leading: Icon(Icons.person,size: 30.0,),
                          title: Text('Profile',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 16.0),),
                          onTap: () async{
                            Navigator.of(context).pop();
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String status  = prefs.getString('s_status');
                            status != null ? await Navigator.of(context).push(_profilePage()) : await Navigator.of(context).push(_signIn());
                            // await Navigator.of(context).push(_loadCart());
                            getCounter();
                            listenCartCount();
                          }
                      ),
                      ListTile(
                          leading: Icon(Icons.add,size: 30.0,),
                          title: Text('Manage discount',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 16.0),),
                          onTap: () async{
                            Navigator.of(context).pop();
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String username = prefs.getString('s_customerId');
                            if(username == null){
                              await Navigator.of(context).push(_signIn());
                              getCounter();
                              listenCartCount();
                              loadProfile();
                            }else{
                              await Navigator.of(context).push(_loadCart());
                              getCounter();
                              listenCartCount();
                              loadProfile();
                            }
                          }
                      ),
                      // ListTile(
                      //   leading: Icon(Icons.info_outline,size: 30.0,color: Colors.deepOrange,),
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
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
      ):  Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Scrollbar(
                child:ListView(
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
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
                      height: 20.0,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Card(
                        elevation: 0.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(40, 10, 5, 15),
                              child: new Text(
                                "You don't need a silver fork to eat good food.",
                                style: GoogleFonts.openSans(
                                    fontStyle: FontStyle.normal,fontWeight: FontWeight.bold, fontSize: 45.0),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(40, 10, 5, 5),
                              child: new Text(
                                "Select Povince",
                                style: GoogleFonts.openSans(
                                    fontStyle: FontStyle.normal, fontSize: 18.0),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 5.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30.0),
                                onTap: (){
                                  selectProvince();
                                },
                                child: IgnorePointer(
                                  child: new TextFormField(
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange.withOpacity(0.8),
                                      controller: province,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.deepOrange.withOpacity(0.8),
                                              width: 2.0),
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(30.0)),
                                      )
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(40, 10, 5, 5),
                              child: new Text(
                                "Select town",
                                style: GoogleFonts.openSans(
                                    fontStyle: FontStyle.normal, fontSize: 18.0),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 5.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30.0),
                                onTap: (){
                                  selectTown();
                                },
                                child: IgnorePointer(
                                  child: new TextFormField(
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange.withOpacity(0.8),
                                      controller:town,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.deepOrange.withOpacity(0.8),
                                              width: 2.0),
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(30.0)),
                                      )
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 5.0),
                              child: Container(
                                height: 50.0,
                                child: OutlinedButton(
                                  onPressed: (){
                                    loadBu();
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.deepOrangeAccent,
                                    primary: Colors.white,
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                  ),
                                  child: Text("Go"),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                      ),
                    ),

                    ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: buData == null ? 0: buData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () async{
                              await Navigator.of(context).push(_gotoTenants(buData[index]['logo'],buData[index]['business_unit'],buData[index]['bunit_code']));
                              getCounter();
                              listenCartCount();
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
                                elevation: 0.1,
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

            Visibility(
              visible:cartCount == 0 ? false : true,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: SleekButton(
                        onTap: () async{
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String username = prefs.getString('s_customerId');
                          if(username == null){
                            await Navigator.of(context).push(_signIn());
                            getCounter();
                            listenCartCount();
                          }else{
                            await Navigator.of(context).push(_loadCart());
                            getCounter();
                            listenCartCount();
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
                                  fontSize: 13.0),),
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
      ),
    );
  }
}

Route _gotoTenants(buLogo,buName,buCode) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => LoadTenants(buLogo:buLogo,buName:buName,buCode:buCode),
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

Route _loadCart(){
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

Route _loadGrocery(){
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

Route _mainPage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MyApp(),
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