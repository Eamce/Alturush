import 'package:arush/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'view_item.dart';
import 'db_helper.dart';
import 'package:nice_button/nice_button.dart';
import 'load_cart.dart';
import 'create_account_signin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'track_order.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:loading_gifs/loading_gifs.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'grocery/groceryMain.dart';
import 'search.dart';

class LoadStore extends StatefulWidget {
  final categoryName;
  final categoryId;
  final buCode;
  final storeLogo;
  final tenantCode;
  final tenantName;
  final globalID;
  final buAcroname;

  LoadStore({Key key, @required this.categoryName, this.categoryId, this.buCode,this.storeLogo, this.tenantCode, this.tenantName, this.globalID, this.buAcroname}) : super(key: key);
  @override
  _LoadStore createState() => _LoadStore();
}

class _LoadStore extends State<LoadStore> {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
//  bool _isLogged = false;
  List loadStoreData;
  List loadCategory;
  List listProfile;
  var profilePicture = "";
  var profileLoading = false;
  var isLoading = false;
  var cartLoading = true;
  var cartCount;
  int gridCount;
  List listCounter;
  List listSubtotal;
  List buData;
  var checkIfEmptyStore;
  var subtotal;
  Timer timer;
  String categoryName = "";
  String acro;
  List<String> buCo = [];

  Future checkEmptyStore() async{
    var res = await db.checkEmptyStore(widget.tenantCode);
    if (!mounted) return;
     if(res == "true"){
       checkIfEmptyStore = true;
     }else{
       checkIfEmptyStore = false;
     }
  }

  Future loadBu() async{
    var res = await db.getBusinessUnitsCi();
    if (!mounted) return;
    setState(() {
      buData = res['user_details'];

      for (int i=0;i<buData.length;i++){
        if (buData[i]['bunit_code'] == widget.buCode){
          acro = buData[i]['acroname'];
        }
      }

      print(acro);
    });
  }

  Future loadStore() async {
    setState(() {
      isLoading = true;
    });
    var res = await db.getStoreCi(widget.categoryId);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      loadStoreData = res['user_details'];
      // print(loadStoreData);
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

  @override
  void initState() {
    super.initState();
    getCounter();
    loadBu();
    loadProfile();
    loadProfilePic();
    if(widget.categoryName == 'All items'){
      getItemsByCategoriesAll();
    }else{
      loadStore();
    }
    checkEmptyStore();
    categoryName = widget.categoryName;
  }


  void displayCategory(BuildContext context) async{
    List categoryData;
    var res = await db.selectCategory(widget.tenantCode);
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
            height: MediaQuery.of(context).size.height/1.5,
            child: Scrollbar(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 20.0, 20.0, 20.0),
                    child:Text("Category",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
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
                                    onTap: () {
                                      Navigator.pop(context);
                                      if(index == 0){
                                        categoryName = 'All items';
                                        getItemsByCategoriesAll();
                                      }else{
                                        categoryName = categoryData[index]['category'];
                                        getItemsByCategories(categoryData[index]['category_id']);
                                      }

                                      // Navigator.of(context).push(_loadStore(categoryData[index]['category_id'],buCode,logo,tenantId,tenantName));
                                    },
                                    child:Container(
                                      height: 120.0,
                                      width: 30.0,
                                      child: Card(
                                        color: Colors.white,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            index == 0 ? ListTile(
                                          leading:Container(
                                          width: 50.0,
                                          height: 50.0,
                                          decoration: new BoxDecoration(
                                            image: new DecorationImage(
                                              image: new NetworkImage(categoryData[index]['image']),
                                              fit: BoxFit.contain,
                                            ),
                                            borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                            border: new Border.all(
                                              color: Colors.black54,
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        title: Text("All items",style: GoogleFonts.openSans(color: Colors.black54,fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 18.0),),
                                      ) : ListTile(
                                              leading:Container(
                                                width: 50.0,
                                                height: 50.0,
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
                                              title: Text(categoryData[index]['category'].toString(),style: GoogleFonts.openSans(color: Colors.black54,fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 18.0),),
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

  bool cat = false;
  List getItemsByCategoriesList;
  getItemsByCategories(categoryId) async{
    cat = false;
    var res = await db.getItemsByCategories(categoryId);
    if (!mounted) return;
    setState(() {
      getItemsByCategoriesList = res['user_details'];
      cat = true;
    });
  }

  getItemsByCategoriesAll() async{
    cat = false;
    var res = await db.getItemsByCategoriesAll(widget.tenantCode);
    if (!mounted) return;
    setState(() {
      getItemsByCategoriesList = res['user_details'];
      cat = true;
      print(getItemsByCategoriesList);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    screenWidth >= 600 ? gridCount = 3 : gridCount = 2;
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
          iconTheme: new IconThemeData(color: Colors.black, size: 20),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/png/alturush_text_logo.png',
                fit: BoxFit.contain,
                height: 30,
              ),
              // Container(
              //   padding: const EdgeInsets.all(8.0), child: Text("Store",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),)
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black54,size: 20,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.search_outlined, color: Colors.black54, size: 25),
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
            ): InkWell(
              customBorder: CircleBorder(),
              onTap: () async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String username = prefs.getString('s_customerId');
                if(username == null){
                  await Navigator.of(context).push(_signIn());
                  loadProfile();
                  getCounter();

                }else{
                  await Navigator.of(context).push(profile());
                  loadProfile();
                  getCounter();
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
         ) : Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: loadStore,
                child:Scrollbar(
                  child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          // image: DecorationImage(
                          //   image: AssetImage("assets/png/contact-chow-king-grill-and-buffet.jpg"),
                          //   fit: BoxFit.cover,
                          // ),
                          image: new DecorationImage(
                            image: new NetworkImage(widget.storeLogo),
                            fit: BoxFit.none,
                            opacity: 65.0,
                          ),
                        ),
                        child: SizedBox(
                          height: 200.0,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(25, 55, 25, 55),
                            child: Card(
                              color: Colors.transparent,
                              child: new Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ListTile(
//                                      leading: CircleAvatar(
//                                        backgroundImage: NetworkImage(widget.storeLogo),
//                                        backgroundColor: Colors.transparent,
//                                        radius: 25.0,
//                                      ),
                                    leading:Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: new BoxDecoration(
                                        image: new DecorationImage(
                                          image: new NetworkImage(widget.storeLogo),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                        border: new Border.all(
                                          color: Colors.black54,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      '${widget.tenantName} - ${acro}',
                                      style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 20.0),
                                    ),
                                    // subtitle: Text(
                                    //   'Welcome! Select your best choice',
                                    //   style: GoogleFonts.openSans(
                                    //       color: Colors.white,
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
                      ),
                      // Padding(
                      //   padding: EdgeInsets.fromLTRB(1, 20, 1, 5),
                      //   child:  Container(
                      //     child: NiceButton(
                      //       width: screenWidth,
                      //       background:Colors.redAccent ,
                      //       radius: 20,
                      //       padding: const EdgeInsets.all(15),
                      //       text: "Order groceries here",
                      //       gradientColors: [Colors.green, Colors.lightGreen],
                      //       onPressed: () {
                      //         Navigator.of(context).push(_loadGrocery());
                      //       },
                      //     ),
                      //   ),
                      // ),
                      Visibility(
                        visible: checkIfEmptyStore == false ? false : true,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 15, 5, 15),
                          child: new Text(categoryName, style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                        ),
                      ),
                      Visibility(
                        visible: checkIfEmptyStore == false ? false : true,
                        replacement: Container(
                          child: Column(
                            children: [
                              Center(
                                child:Image.asset('assets/png/alturush_text_logo.png',height: 100.0,width: 130.0,),
                              ),
                              Center(
                                child: SignInButton(
                                  Buttons.Facebook,
                                  text: "Alturas food delivery",
                                  onPressed: () {

                                  },
                                ),
                              ),
                              Center(
                                child: SizedBox(
                                  width: 220.0,
                                  height: 40.0,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      primary: Colors.blue,
                                      onSurface: Colors.red,
                                    ),
                                    icon: FaIcon(FontAwesomeIcons.viber), label: Text("Alturas food delivery",style: TextStyle(color: Colors.white),),
                                    onPressed: (){

                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 7.0,
                              ),
                              Center(
                                child: SizedBox(
                                  width: 220.0,
                                  height: 40.0,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      primary: Colors.blue,
                                      onSurface: Colors.red,
                                    ),
                                    icon: FaIcon(FontAwesomeIcons.phone), label: Text("Tele +63 385013020",style: TextStyle(color: Colors.white),),
                                    onPressed: (){

                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 7.0,
                              ),
                              Center(
                                child: SizedBox(
                                  width: 220.0,
                                  height: 40.0,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      primary: Colors.blue,
                                      onSurface: Colors.red,
                                    ),
                                    icon: FaIcon(FontAwesomeIcons.phone), label: Text("Smart +639209012028",style: TextStyle(color: Colors.white),),
                                    onPressed: (){
                                      launch("tel://+639209012028");
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 7.0,
                              ),
                              Center(
                                child: SizedBox(
                                  width: 220.0,
                                  height: 40.0,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      primary: Colors.blue,
                                      onSurface: Colors.red,
                                    ),
                                    icon: FaIcon(FontAwesomeIcons.phone), label: Text("Smart +639190796520",style: TextStyle(color: Colors.white),),
                                    onPressed: (){
                                      launch("tel://+639190796520");
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 7.0,
                              ),
                              Center(
                                child: SizedBox(
                                  width: 220.0,
                                  height: 40.0,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      primary: Colors.blue,
                                      onSurface: Colors.red,
                                    ),
                                    icon: FaIcon(FontAwesomeIcons.phone), label: Text("Globe +639173113609",style: TextStyle(color: Colors.white),),
                                    onPressed: (){
                                      launch("tel://+639173113609");
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 7.0,
                              ),
                              Center(
                                child: SizedBox(
                                  width: 220.0,
                                  height: 40.0,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      primary: Colors.blue,
                                      onSurface: Colors.red,
                                    ),
                                    icon: FaIcon(FontAwesomeIcons.phone), label: Text("Globe +639178444672",style: TextStyle(color: Colors.white),),
                                    onPressed: (){
                                      launch("tel://+639178444672");
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                            ],
                          ),
                        ),
                        child: cat == false ?  GridView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: loadStoreData == null ? 0 : loadStoreData.length,
                            gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridCount,
                              childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height / 1.5),
                            ),
                            itemBuilder: (BuildContext context, int index) {

                              return GestureDetector(
                                onTap: () async{
                                await Navigator.of(context).push(_viewItem(
                                      widget.buCode,
                                      loadStoreData[index]['tenant_id'],
                                      loadStoreData[index]['product_id'],
                                      loadStoreData[index]['product_uom'],
                                      loadStoreData[index]['unit_measure'],
                                      loadStoreData[index]['price'],
                                      widget.globalID
                                  ));
                                  getCounter();
                                },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(width: 1.0, color: Colors.black12),
                                        right: BorderSide(width: 1.0, color: Colors.black12),
//                                          left: BorderSide(width: 1.0, color: Colors.black12),
//                                          bottom: BorderSide(width: 1.0, color: Colors.black12)
                                      ),
                                      color: Colors.transparent,
                                    ),
                                    margin: EdgeInsets.all(1),
                                    child: Column(
                                      children: <Widget>[
                                        new Expanded(
                                          child: FadeInImage.assetNetwork(
                                            placeholder: cupertinoActivityIndicatorSmall,
                                            image:loadStoreData[index]['image'],fit: BoxFit.scaleDown,
                                          ),
//                                          child: Image.network(loadStoreData[index]['image'],
//                                            fit: BoxFit.scaleDown,
//                                            alignment: Alignment.center,
//                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        ListTile(
                                          title: Text(loadStoreData[index]['product_name'],
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87),
                                          ),
                                          subtitle: Text('₱ ${loadStoreData[index]['price']}  ${loadStoreData[index]['unit_measure'] == null ? "" : loadStoreData[index]['unit_measure']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                  ),


                              );
                            }) : GridView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: getItemsByCategoriesList == null ? 0 : getItemsByCategoriesList.length,
                            gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridCount,
                              childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height / 1.2),
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () async{
                                  // print(getItemsByCategoriesList[index]['product_id'],);
                                  await Navigator.of(context).push(_viewItem(
                                      widget.buCode,
                                      getItemsByCategoriesList[index]['tenant_id'],
                                      getItemsByCategoriesList[index]['product_id'],
                                      getItemsByCategoriesList[index]['product_uom'],
                                      getItemsByCategoriesList[index]['unit_measure'],
                                      getItemsByCategoriesList[index]['price'],
                                      widget.globalID
                                  ));
                                  getCounter();
                                },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(width: 1.0, color: Colors.black12),
                                        right: BorderSide(width: 1.0, color: Colors.black12),
//                                          left: BorderSide(width: 1.0, color: Colors.black12),
//                                          bottom: BorderSide(width: 1.0, color: Colors.black12)
                                      ),
                                      color: Colors.transparent,
                                    ),
                                    margin: EdgeInsets.all(1),
                                    child: Column(
                                      children: <Widget>[
                                        new Expanded(
                                          child: FadeInImage.assetNetwork(
                                            placeholder: cupertinoActivityIndicatorSmall,
                                            image:getItemsByCategoriesList[index]['image'],fit: BoxFit.scaleDown,
                                          ),
//                                          child: Image.network(loadStoreData[index]['image'],
//                                            fit: BoxFit.scaleDown,
//                                            alignment: Alignment.center,
//                                          ),
                                        ),
                                        SizedBox(
                                          height: 25,
                                        ),
                                        ListTile(
                                          title: Text(getItemsByCategoriesList[index]['product_name'],
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87),
                                          ),
                                          subtitle: Text('₱ ${getItemsByCategoriesList[index]['price']} ${getItemsByCategoriesList[index]['unit_measure'] == null ? "" : getItemsByCategoriesList[index]['unit_measure']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 25,
                                        ),
                                      ],
                                    ),
                                  ),
                              );
                            }) ,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding:EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SleekButton(
                    onTap: () {
                      //viewCartTenants();
                      displayCategory(context);
                    },
                    style: SleekButtonStyle.outlined(
                      color: Colors.deepOrange,
                      inverted: false,
                      rounded: true,
                      size: SleekButtonSize.normal,
                      context: context,
                    ),
                    child: Center(
                      child:Text("CATEGORIES",style: TextStyle(fontSize: 14.0),)
                    ),
                  ),
                  SizedBox(
                    width: 2.0,
                  ),
                  Visibility(
                    visible: cartCount == 0 ? false : true,
                    child: Flexible(
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
                          size: SleekButtonSize.normal,
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
                          ) : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Text("VIEW CART ${cartCount.toString()}",style: TextStyle(
                                  shadows: [
                                    Shadow(
                                      blurRadius: 1.0,
                                      color: Colors.black54,
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0)
                                ),
                              )
//                              Text("₱ ${oCcy.format(num.parse(subtotal.toString()))}",style: TextStyle(
//                                  shadows: [
//                                    Shadow(
//                                      blurRadius: 1.0,
//                                      color: Colors.black54,
//                                      offset: Offset(1.0, 1.0),
//                                    ),
//                                  ],
//                                  fontStyle: FontStyle.normal,
//                                  fontWeight: FontWeight.bold,
//                                  fontSize: 13.0),),
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

Route _viewItem(buCode, tenantCode, prodId,productUom,unitOfMeasure,price, globalID) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        ViewItem(buCode: buCode, tenantCode: tenantCode, prodId: prodId,productUom:productUom,unitOfMeasure:unitOfMeasure,price:price,globalID:globalID),
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
