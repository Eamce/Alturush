import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../db_helper.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:nice_button/nice_button.dart';
import '../create_account_signin.dart';
import '../track_order.dart';
import '../load_bu.dart';
import 'package:loading_gifs/loading_gifs.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'gcview_item.dart';
import 'gc_cart.dart';

class GcLoadStore extends StatefulWidget {
  final logo;
  final categoryName;
  final categoryNo;
  final businessUnit;
  final bUnitCode;

  GcLoadStore({Key key, @required this.logo,this.categoryName,this.categoryNo,this.businessUnit,this.bUnitCode}) : super(key: key);
  @override
  _GcLoadStore createState() => _GcLoadStore();
}

class _GcLoadStore extends State<GcLoadStore> {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final _search = TextEditingController();
  List loadStoreData = List();
  List loadStoreDataTemp = List();
  List getItemsByCategoriesListTemp = List();
  List loadCategory;
  List loadSubtotal;
  var isLoading = true;
  var cartLoading = true;
  var cartCount;
  var subTotal;
  String categoryId = "";
  int gridCount;
  List listCounter;
  List listSubtotal;
  var checkIfEmptyStore;
  var offset = 0;
  String categoryName = "";

  ScrollController scrollController;
  ScrollController  _categoryController;
  bool cat = false;

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      elevation: 0.1,
      iconTheme: new IconThemeData(color: Colors.black),
//          title: Text("Menu",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
      title: Row(
        children: [
          Container(
            width: 30.0,
            height: 30.0,
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new NetworkImage(widget.logo),
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
          Text("Menu",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        status == null ? TextButton(
          onPressed: () async {
            await Navigator.of(context).push(_signIn());
            loadProfile();
            getGcCounter();
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
                getGcCounter();
              }else{
                await Navigator.of(context).push(_profilePage());
                loadProfile();
                getGcCounter();
              }
            }
        ),
      ],
    );
  }


  Future loadStore() async{
    setState(() {
      isLoading = true;
//      cartLoading = true;
    });
    Map res = await db.getGcStoreCi(offset.toString(),widget.categoryNo);
    if (!mounted) return;
    setState(() {
      cartLoading = false;
      isLoading = false;
      loadStoreData.clear();
      loadStoreData = res['user_details'];
      offset = 0;
    });
  }

  Future loadStore1() async{
    Map res = await db.getGcStoreCi(offset.toString(),widget.categoryNo);
    if (!mounted) return;
    setState(() {
      cartLoading = false;
      isLoading = false;
      loadStoreDataTemp = res['user_details'];
      // loadStoreData.clear();
      for(int q = 0;q < loadStoreDataTemp.length;q++){
        loadStoreData.add(loadStoreDataTemp[q]);
        // print(loadStoreDataTemp[q]);
      }
    });
  }

  itemSearch(itemSearch) async{
    setState((){
      isLoading = true;
    });
    Map res = await db.getGcStoreCi(offset.toString(),itemSearch);
    if (!mounted) return;
    setState(() {
      cartLoading = false;
      isLoading = false;
      loadStoreData.clear();
      loadStoreData = res['user_details'];
      offset = 0;
      if(loadStoreData.length == 0){
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
              title: Padding(
                padding: EdgeInsets.fromLTRB(1.0, 0.0, 20.0, 0.0),
                child: Text(
                  'Sorry',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              content: Container(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(30.0, 0.0, 20.0, 0.0),
                    child: Text("No item found")),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.green.withOpacity(0.8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    loadStore();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  String status;
  Future loadProfile() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status  = prefs.getString('s_status');
    if(status != null) {
      loadGcSubTotal();
    }
  }

  Future loadGcSubTotal() async{
    var res = await db.loadGcSubTotal();
    if (!mounted) return;
    setState(() {
//      cartLoading = false;
      loadSubtotal = res['user_details'];
      if(loadSubtotal[0]['d_subtotal'].toString().isEmpty){
        subTotal = 0;
      }else{
        subTotal = loadSubtotal[0]['d_subtotal'].toString();
      }
    });
  }

  void selectGcCategory(BuildContext context) async{
    List categoryData;
    var res = await db.getGcCategories();
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
                                      categoryId = categoryData[index]['category_no'];
                                      categoryName = categoryData[index]['category_name'];
                                      getItemsByCategories();
                                      Navigator.pop(context);
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

  List getItemsByCategoriesList = List();
  getItemsByCategories() async{
    var res = await db.getItemsByGcCategories(categoryId,offset);
    if (!mounted) return;
    setState(() {
      scrollController.animateTo(0.0, duration: Duration(seconds: 1), curve: Curves.ease);
      getItemsByCategoriesList.clear();
      getItemsByCategoriesList = res['user_details'];
      cat = true;
      offset = 0;
    });
  }

  getItemsByCategories1() async{
    var res = await db.getItemsByGcCategories(categoryId,offset);
    if (!mounted) return;
    setState(() {
      // offset =;
      getItemsByCategoriesListTemp = res['user_details'];
      for(int q = 0;q < getItemsByCategoriesListTemp.length; q++){
        getItemsByCategoriesList.add(getItemsByCategoriesListTemp[q]);
        // print(loadStoreDataTemp[q]);
      }
    });
  }

  Future getGcCounter() async {
    var res = await db.getGcCounter();
    if (!mounted) return;
    setState(() {
//      cartLoading = false;
      listCounter = res['user_details'];
      cartCount = listCounter[0]['num'];

    });
  }

  @override
  void initState() {
    super.initState();
    print(widget.categoryName);
    categoryName = widget.categoryName;
    loadStore();
    getGcCounter();
    loadProfile();
    isLoading = true;
    scrollController=ScrollController();
    scrollController.addListener(() {
      FocusScope.of(context).unfocus();
      // _search.clear();
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {

          setState(() {
            offset += 10;
            if(cat == false){
              loadStore1();
              // print(offset);
            }else{
               getItemsByCategories1();
            }
          });
        }
      }
    });
    // timer = Timer.periodic(Duration(seconds: 5), (Timer t) => loadProfile());
  }

  @override
  void dispose() {
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
        appBar: buildAppBar(context),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: loadStore,
                child:Scrollbar(
                  child: ListView(
                    controller: scrollController,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/jpg/grocerybg.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: SizedBox(
                          height: 200.0,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(30, 55, 30, 55),
                            child: Card(
                              color: Colors.transparent,
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
                                          image: new NetworkImage(widget.logo),
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
                                      widget.businessUnit,
                                      style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 15.0),
                                    ),
                                    dense: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(30, 20, 30, 5),
                        child: Container(
                          child: new TextFormField(
                            textInputAction: TextInputAction.search,
                            cursorColor: Colors.green.withOpacity(0.8),
                            controller: _search,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(Icons.search_outlined,color: Colors.green,),
                                onPressed: (){
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  itemSearch(_search.text);
                                },
                              ),
                              hintText: "Search",
                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                    color: Colors.green.withOpacity(0.8),
                                    width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
                            ),
                            onFieldSubmitted: (searchText){
                              itemSearch(searchText);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(1, 20, 1, 5),
                        child:  NiceButton(
                          width: screenWidth,
                          background:Colors.redAccent ,
                          radius: 20,
                          padding: const EdgeInsets.all(15),
                          text: "We also deliver food",
                          gradientColors: [Colors.redAccent, Colors.deepOrangeAccent],
                          onPressed: () {
                            Navigator.of(context).push(_loadFood());
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 20, 5, 5),
                        child: new Text(categoryName, style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 20.0),),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      isLoading
                          ? Center(
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      ) : cat == false ?
                      GridView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: loadStoreData == null ? 0 : loadStoreData.length,
                          gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridCount,
                            childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height / 1.2),
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () async{
                               SharedPreferences prefs = await SharedPreferences.getInstance();
                               String username = prefs.getString('s_customerId');
                               await Navigator.of(context).push(_gcVieItem(
                                    loadStoreData[index]['prod_id'],
                                    loadStoreData[index]['product_name'],
                                    loadStoreData[index]['image'],
                                    loadStoreData[index]['itemcode'],
                                    loadStoreData[index]['price'],
                                    loadStoreData[index]['uom'],
                                    loadStoreData[index]['uom_id'],
                                    widget.bUnitCode
                                ));
                               getGcCounter();
                               loadProfile();
                               if(username != null){
                                 loadGcSubTotal();
                               }

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
                                        child:loadStoreData[index]['image'] == 'https://admin.alturush.com/ITEM-IMAGES/' ? FadeInImage.assetNetwork(
                                          placeholder: cupertinoActivityIndicatorSmall,
                                          image:'https://dummyimage.com/400x400/ffffff/040405.png&text=+No+image',fit: BoxFit.scaleDown,
                                        ) : FadeInImage.assetNetwork(
                                          placeholder: cupertinoActivityIndicatorSmall,
                                          image:loadStoreData[index]['image'],fit: BoxFit.scaleDown,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      ListTile(
                                        title: Text(loadStoreData[index]['product_name'],
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black87),
                                        ),
                                        subtitle: Text('₱ ${loadStoreData[index]['price']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.green,
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
                          }) :
                      GridView.builder(
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
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String username = prefs.getString('s_customerId');
                              await Navigator.of(context).push(_gcVieItem(
                                    getItemsByCategoriesList[index]['product_id'],
                                    getItemsByCategoriesList[index]['product_name'],
                                    getItemsByCategoriesList[index]['image'],
                                    getItemsByCategoriesList[index]['itemcode'],
                                    getItemsByCategoriesList[index]['price'],
                                    getItemsByCategoriesList[index]['uom'],
                                    getItemsByCategoriesList[index]['uom_id'],
                                    widget.bUnitCode
                                ));
                                getGcCounter();
                                loadProfile();
                                if(username != null){
                                  loadGcSubTotal();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(width: 1.0, color: Colors.black12),
                                    right: BorderSide(width: 1.0, color: Colors.black12),
                                  ),
                                  color: Colors.transparent,
                                ),
                                margin: EdgeInsets.all(1),
                                child: Column(
                                  children: <Widget>[
                                    new Expanded(
                                      child: getItemsByCategoriesList[index]['image'] == 'https://admin.alturush.com/ITEM-IMAGES/' ? FadeInImage.assetNetwork(
                                        placeholder: cupertinoActivityIndicatorSmall,
                                        image:'https://dummyimage.com/400x400/ffffff/040405.png&text=+No+image',fit: BoxFit.scaleDown,
                                      ) : FadeInImage.assetNetwork(
                                        placeholder: cupertinoActivityIndicatorSmall,
                                        image:getItemsByCategoriesList[index]['image'],fit: BoxFit.scaleDown,
                                      ),
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
                                      subtitle: Text('₱ ${getItemsByCategoriesList[index]['price']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.green,
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

                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding:EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Row(
                children: <Widget>[
                  SleekButton(
                    onTap:(){
                      selectGcCategory(context);
                    },
                    style: SleekButtonStyle.outlined(
                      color: Colors.green,
                      inverted: false,
                      rounded: false,
                      size: SleekButtonSize.big,
                      context: context,
                    ),
                    child: Center(
                      child: Center(
                          child:Text("Categories",style: TextStyle(fontSize: 14.0),)
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 2.0,
                  ),
                  Visibility(
                    visible: cartCount == 0 ? false : true,
                    child: Flexible(
                      child: SleekButton(
                        onTap: () async{
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String username = prefs.getString('s_customerId');
                          if(username == null){
                            await Navigator.of(context).push(_signIn());
                            getGcCounter();
                            // loadGcSubTotal();
                            loadProfile();
                          }else{
                            await Navigator.of(context).push(_gcViewCart());
                            getGcCounter();
                            // loadGcSubTotal();
                            loadProfile();
                          }
                        },
                        style: SleekButtonStyle.flat(
                          color: Colors.green,
                          inverted: false,
                          rounded: true,
                          size: SleekButtonSize.big,
                          context: context,
                        ),
                        child: Center(
                          child: cartLoading
                              ? Center(
                            child:Container(
                              height:16.0,
                              width: 16.0,
                              child: CircularProgressIndicator(
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
//                              Text("₱ ${oCcy.format(num.parse(subTotal.toString()))}",style: TextStyle(
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
                                  fontSize: 13.0),
                              ),
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

Route _gcVieItem(prodId,prodName,image,itemCode,price,uom,uomId,buCode){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ViewItem(prodId:prodId,prodName:prodName,image:image,itemCode:itemCode,price:price,uom:uom,uomId:uomId,buCode:buCode),
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